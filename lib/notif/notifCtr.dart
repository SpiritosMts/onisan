import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:onisan/assetManager/assetManager.dart';
import 'package:onisan/notif/notifItem.dart';
import 'package:onisan/routing/routingService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../backend/firebaseVoids.dart';
import '../components/dateAndTime/dateAndTime.dart';
import '../refs/refs.dart';

//in main.dart (initilize Fcm)
//after verify user and get its data (get token)
// in api & cre enable "cloud messaging"
// add permission in manifest "<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />" and another thing in services in manifest
//Set streamUserToken in when user data loaded (in authCtr)
// go get "assets/files/service-account.json" file from google cloug - IAM & Admin - Service accounts - select acc - keys then download key json

//update flutter_local_notif pckg

//add to android/app/gradle deendencies for flutter_localnotif pckg
// dependencies {
//     coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.3'

//android {
//     compileOptions {
//         sourceCompatibility JavaVersion.VERSION_17
//         targetCompatibility JavaVersion.VERSION_17
//         coreLibraryDesugaringEnabled true
//
//     }
//
//     kotlinOptions {
//         jvmTarget = JavaVersion.VERSION_17
//     }


//TODO CALL OUTSIDE
//stopNotifsListening() // to stop listening (in signOut ..)
//startNotifsListening() // to start listening (in home init ..)

/*
///initilize notif in main.dart
  if (!kIsWeb) {
    //if mobile
    await setupFlutterNotifications();
  }else{
    // add file "firebase-messaging-sw.js" to /web dir
      FirebaseMessaging.instance.setAutoInitEnabled(true);

  }

  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

 */
class FirebaseMessagingCtr extends GetxController {
  ///************************* PROJECT_INFO ******************************************


  Future<Map<String, dynamic>> _loadServiceAccount() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/service-account.json';

    if (File(filePath).existsSync()) {
      final file = File(filePath);
      return jsonDecode(await file.readAsString());
    } else {
      // Assuming the service account file is in the assets directory
      final jsonString = await rootBundle.loadString(AssetsManager.filesServiceAccountPath!);
      final file = File(filePath);
      await file.writeAsString(jsonString);
      return jsonDecode(jsonString);
    }
  }

  Future<auth.AuthClient> _getAuthClient(Map<String, dynamic> serviceAccount) async {
    //Load the service account credentials from a JSON file.
    final accountCredentials = auth.ServiceAccountCredentials.fromJson(serviceAccount);
    // Define the access levels your application needs.
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    //create an authenticated HTTP client
    final authClient = await clientViaServiceAccount(accountCredentials, scopes);
    return authClient;
  }

  ///************************* TOKEN ******************************************

  String localToken = "";
  late Stream<String> _tokenStream;

  streamUserToken() {
    FirebaseMessaging.instance.getToken(vapidKey: CustomVars.vapidKeyNotif).then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }

  void setToken(String? _token) {
    if (_token == null) {
      print('## failed to get device token locally');
      return;
    }
    localToken = _token;
    //set tokreeeen must update token
     updateUserTokenOnline();
  }

  // ---- to_update & set in other files ----
  void updateUserTokenOnline() {
    if ((localToken.isNotEmpty && localToken != ccUser.deviceToken) && (ccUser.id != "" && ccUser.id != null)) {
      try {
        updateFieldInFirestore(usersColl, ccUser.id, 'deviceToken', localToken, addSuccess: () {}); //:online
        ccUser.deviceToken = localToken;
        print('## Saved token to user data = <$localToken>');
      } catch (e) {
        print('## cant save user token');
      }
    }
  }

  /// *************************************************************

  @override
  onInit() {
    super.onInit();
    print('## ## onInit FirebaseMessagingCtr');

    // Stream user token and handle FCM token updates
    streamUserToken();

    // When the app is opened via notification click (background or terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('## App was launched from a terminated state by tapping a notification.');
        print('## Notification data: ${message.data}');
        handleNotificationClick(jsonEncode(message.data));
      }
    });

    // Handle notifications receive when the app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('## notif opened from fg: <${message.notification?.title}>');

      showStackNotification(message, payload: jsonEncode(message.data));
      //print('## notif received from fg: ${message.notification?.title}');
    });

    // Handle notification receive when app is opened from background by tapping a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('## notif opened from bg: <${message.notification?.title}>');
      handleNotificationClick(jsonEncode(message.data));
    });

    /// When the app is in the background or terminated and a notification arrives
    // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
    //   showDeviceNotification(message);
    //   print('## notif received from bg: ${message.notification?.title}');
    // });
  }

  @override
  void onClose() {
    print("## ## onClose FirebaseMessagingCtr");
    super.onClose();
  }

  ///************************************************ Notifications LIST & LISTEN  *******************************************************************************

  var notifications = <NotifItem>[].obs;
  var isLoading = true.obs;
  var hasNoNotifications = false.obs;
  var hasNotifError = false.obs;
  var unreadNotifsCount = 0.obs;
  StreamSubscription? _notificationSubscription;

  void stopNotifsListening() {
    _notificationSubscription?.cancel();
  }

  void startNotifsListening({String showNotifsFromDate ="0001-01-01T00:00:00.000000Z"}) {
    if (ccUser.id.isEmpty || ccUser.id == null) {
      print("## cant start notif listening (no User Id)");
      return;
    }




    //todo select the coll to listen from
    try {
      isLoading(true);

      _notificationSubscription = notifsColl(userID: ccUser.id).orderBy('creationTime', descending: true)
          .where('creationTime', isGreaterThan: showNotifsFromDate)
          .snapshots().listen((snapshot) {
        if (snapshot.docs.isEmpty) {
          hasNoNotifications.value = true;
          unreadNotifsCount.value = 0;
        } else {
          List<NotifItem> fetchedNotifications = snapshot.docs.map((doc) => NotifItem.fromJson(doc.data() as Map<String, dynamic>)).toList();

          notifications.value = fetchedNotifications;
          hasNoNotifications.value = false;

          // Calculate unread notifications
          unreadNotifsCount.value = fetchedNotifications.where((NotifItem notification) => !notification.read).length;
        }
      });
    }  catch (e) {
      hasNotifError(false);

      print("## error listening to notifs: $e");
    }finally{
      isLoading(false);

    }
  }



  ///***********************************************************************************************************************
  ///************************************************ Firebase Device send notification   *******************************************************************************
  ///*****************************************************************************************************************************

  ///******************************************  firebase function deplayed  *************************************************************************************


  // *******************************  SEND WITH FUNCTIONS ********************************************************

  Future<void> sendNotifFbFunc(NotifItem notif, {bool addToDb = false, List<String> targetIDs = const []}) async {
    // targetIDs List of userIDs , if empty=send to all
    try {
      final _exampleMessage = {
        "message": {
          "token": "àçjsrt;qetjè)qetgjàerç=",
          "notification": {
            "title": "TITLE**",
            "body": "BODY**",
            "image": "Url**",
          },
          "data": {
           /// ...dataPayload, // dataPayload items are in data- access with message.data['obj'] -
            "notifId": "notifId**",//fixed
          },
        }
      };



      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNotification');
      final response = await callable.call({
        'title': notif.title,
        'body': notif.body,
        'imageUrl': notif.imageUrl,
        'dataPayload': notif.dataPayload, //
        'notifId': notif.id,
        'userIds': targetIDs,
      });

      if (addToDb) {
        addNotificationToDb(notif);//todo make add to each user the same notif in his notif coll- make it in functions add bool addToDb that can can to each one
      }
      final result = response.data;

      //print('## Notifications result: ${result}');
      print('## Success send Count: ${response.data['successCount']}');
      print('## Failure send Count: ${response.data['failureCount']}');
    } on FirebaseFunctionsException catch (e) {
      print('## FirebaseFunctionsException: ${e.code} - ${e.message}');
    } catch (e) {
      print('## Error sending notifications: $e');
    }
  }




  // *******************************  SEND IN APP ********************************************************
  Future<void> sendNotifApp({required String receiverToken, required String title, required String body, String imageUrl = '', Map<String, dynamic> data = const {},String? notifId,}) async {
    try {
      if(receiverToken.isEmpty) {
        //print("## no device token , pushing notif denied");
        return;
      }
      final serviceAccount = await _loadServiceAccount();
      final authClient = await _getAuthClient(serviceAccount);
      String specificID = Uuid().v1();

      final url = 'https://fcm.googleapis.com/v1/projects/${CustomVars.firebaseProjectId}/messages:send';



      final message = {
        "message": {
          "token": receiverToken,
          "notification": {
            "title": title,
            "body": body,
            "image": imageUrl,
          },
          "data": {
            ...data,
            "notifId": notifId??specificID,
            "message": body,//remove
          },
        }
      };
      //print('## FCM request for device sent! - Request : ${message}');

      final response = await authClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message),
      );
      // print('## Response body: ${response.body}');
      print('## ## deviceToken: ${receiverToken}');

      if (response.statusCode == 200) {
        print('## FCM SENT succ Response body: ${response.body}');
      } else {
        print('## Request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('## Error sending FCM message: $e');
    }
  }

  Future<void> sendNotifToUsers({ required List users,required NotifItem notif, bool addToDb = false})async{
    for (var user in users) {
      // Send push notification to the user
      sendNotifApp(
        receiverToken: user.deviceToken, // Use user's device token
        title: notif.title,
        body: notif.body,
        imageUrl: notif.imageUrl,
        notifId: notif.id,
        data: notif.dataPayload,
      );

      // Optionally add notification to Firestore DB for each user
      if (addToDb) {
        addNotificationToDb( notif,userId: user.id,);
      }
    }
  }

  // *******************************  ADD TO FIRESTORE ********************************************************

  Future<void> addNotificationToDb(NotifItem notification, {String? userId}) async {
    // Reference to the user's notifications subcollection
    CollectionReference notificationsRef = notifsColl(userID: userId ?? ccUser.id);

    // Add the notification to the subcollection
    await notificationsRef.doc(notification.id).set(notification.toJson()).then((_) {
      //print('## Notification added successfully');
    }).catchError((error) {
      //print('## Failed to add notification: $error');
    });
  }

  void testSendNotifFunc() {
    String specificID = Uuid().v1();
    NotifItem _notifExample = NotifItem(
      id: specificID,
      senderId: ccUser.id,
      creationTime: nowToUtc(),
      title: 'Special offer just for you!',
      body: 'Get 50% off on your next purchase. Don’t miss out!',
      dataPayload: {
        //must be <string : string >
        "chatroomName": "fsdfsd sdf",//dynamic
        "single": "true",//dynamic
        "postId": "27c0622a-5eae-4a3b-a951-912d7c41a715",//dynamic
        //"notifId": "123",//fixed in functions
      },
      topic: 'Promotions',
      type: 'promotion',
      priority: 'hign',
      status: 'active',
      imageUrl: 'https://i.pinimg.com/originals/95/df/52/95df5222365d97eeedf029f4858d48ed.jpg',
      read: false,
    );

    sendNotifFbFunc(_notifExample,targetIDs:[] , addToDb: false);
  }

}

///---------------------------------------- NOtification Permissions -----------------------------------------------

Future<bool> requestNotificationsPermission() async {
  bool access = false;

  try {
    print('## request Notifications Permission....');

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+
        // Handle Android 13 and above (explicit notification permission request)
        final status = await Permission.notification.request();
        if (status == PermissionStatus.granted) {
          print('## User granted notification permission');
          access = true;
        } else if (status == PermissionStatus.denied) {
          print('## User denied notification permission');
          access = false;
        } else if (status == PermissionStatus.permanentlyDenied) {
          print('## User permanently denied notification permission');
          // Optionally, open app settings if permanently denied
          openAppSettings(); // Opens app settings for manual permission change
          access = false;
        } else {
          print('## Unknown permission status');
          access = false;
        }
      } else {
        // For Android versions below 13 (no explicit permission required)
        print('## Android version below 13, notification permission granted by default');
        access = true; // Notifications are implicitly allowed
      }

      settingCtr.saveNotifSetting(access); // Save the permission status
    } else {
      // platform IOS
      // Handle other platforms if needed (e.g., iOS, Web)
      print('## Non-Android platform detected, skipping permission request');
      access = true; // Assume permission for platforms like iOS is granted or handled separately
    }
  } catch (e) {
    print('## Failed to request Notifications Permission: error : $e');
  }

  return access;
}

Future<void> checkNotificationPermission() async {
  try {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // For Android 13+ (API level 33), check notification permissions using PermissionHandler
        PermissionStatus status = await Permission.notification.status;
        if (status.isGranted) {
          print('## Notifications are enabled (Android 13+)');
          settingCtr.saveNotifSetting(true);
        } else {
          print('## Notifications are not enabled (Android 13+)');
          settingCtr.saveNotifSetting(false);
        }
      } else {
        // For Android < 13, check notification settings via Firebase Messaging
        NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('## Notifications are enabled (Android < 13)');
          settingCtr.saveNotifSetting(true);
        } else {
          print('## Notifications are not enabled (Android < 13)');
          settingCtr.saveNotifSetting(false);
        }
      }
    } else if (Platform.isIOS) {
      // iOS devices, checking notification settings
      NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('## Notifications are enabled (iOS)');
        settingCtr.saveNotifSetting(true);
      } else {
        print('## Notifications are not enabled (iOS)');
        settingCtr.saveNotifSetting(false);
      }
    } else {
      // Handle other platforms if necessary
      print('## Non-Android/iOS platform detected, assuming notifications are enabled');
      settingCtr.saveNotifSetting(true);
    }
  } catch (e) {
    print('## Failed to check notification permission: $e');
    settingCtr.saveNotifSetting(false);
  }
}

///************************************************************************************************************
///**************************** RECEIVE NOTIF ************************************************************************************
///************************************************************************************************************

//send single
Future<void> showDeviceNotification(RemoteMessage message) async {
  if (!settingCtr.isNotifEnabled.value) {
    print('## (disabled) dont show Notification On Device ##');
    return;
  }

  print('## showing Notification On Device... ##');

  RemoteNotification? notification = message.notification;
  Map<String, dynamic> data = message.data;
  AndroidNotification? android = message.notification?.android;
  String notificationImageUrl = message.notification?.android!.imageUrl ?? '';

  BigPictureStyleInformation? bigPictureStyleInformation;

  // Wrap the image download in a try-catch block to handle errors
  if (notificationImageUrl != '') {
    try {
      final http.Response response = await http.get(Uri.parse(notificationImageUrl));
      bigPictureStyleInformation = BigPictureStyleInformation(ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)));
    } catch (e) {
      print('## Error downloading notification image: $e');
    }
  }

  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin!.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.max,
          icon: CustomVars.monochromeNotifIcon,
          playSound: true,
          enableVibration: true,
          styleInformation: bigPictureStyleInformation, // Show image if available
        ),
      ),
    );
  }
}

//send multiple
Future<void> showStackNotification(RemoteMessage message, {String? payload}) async {
  if (!settingCtr.isNotifEnabled.value) {
    print('## (disabled) dont show Notification On Device ##');
    return;
  }

  RemoteNotification? notification = message.notification;
  Map<String, dynamic> data = message.data;
  AndroidNotification? android = message.notification?.android;

  // Extracting chatId and message list from data payload
  String notifId = data['notifId'] ?? '';
  String notifTitle = notification?.title ?? "";
  String newMessage = data['message'] ?? notification?.body ?? ''; //TODO removed in new version
  //String chatroomName = data['chatroomName'] ?? appDisplayName;
  String type = data['type'] ?? 'normal';
  bool single = (data['single'] == "true");

  // Retrieve previous messages for this chat from local storage (e.g., shared preferences)
  List<String> messages = await _getStoredMessages(notifId); // Implement this method to get stored messages
  messages.add(newMessage); // Add the new message to the list

  // Use chatId as the notification ID (ensures it updates the same notification)
  int notificationId = notifId.hashCode;

  //for single big msg
  BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
    newMessage, // Full message here
    contentTitle: notifTitle,
    //summaryText: '${messages.length} new messages',
  );
  //for multi msgs
  InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
    messages.map((msg) => msg).toList(), // Each message will be added as a line
    contentTitle: notifTitle, // the animated title
    summaryText: '${messages.length} messages',
  );

  // Save the updated messages back to local storage
  await _storeMessages(notifId, messages); // Implement this method to store messages

  if (notification != null && android != null && !kIsWeb) {
    print('## showing Notification On Device...  ( ${payload!=null? "with payload":"with NO payload"})  ##');
    flutterLocalNotificationsPlugin!.show(
      notificationId, // Use chatId hash as the notification ID to group notifications
      notification.title,
      notification.body, // You can omit this if you're using the inbox style to show the messages
      payload: payload ,///set THE PAYLOAD which i get later ****************************
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.max,
          icon: CustomVars.monochromeNotifIcon,
          playSound: true,
          enableVibration: true,
          styleInformation: single ? bigTextStyleInformation : inboxStyleInformation, // Inbox style for showing multiple lines
        ),
      ),
    );
  }
}

///---------------------------------------- NOtification SETUP -----------------------------------------------
///--------------------------------------------------------------------------------------------------------------------

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false; // flutter notif initalized state
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

Future<void> setupFlutterNotifications() async {
  print('## setupFlutterNotifications ## ');

  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
      'Notif-ID', // id
      'Notif-Channel', // title
      description: 'This channel is used for notAlone',
      importance: Importance.max,
      // sound: RawResourceAndroidNotificationSound('notif_sound'),//android/app/src/main/res/raw
      showBadge: true,
      playSound: true,
      enableVibration: true);

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin!
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
   AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(CustomVars.normalNotifIcon);
   InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  //--- initialization ---
  await flutterLocalNotificationsPlugin!.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      handleNotificationClick(response.payload);
    },
    onDidReceiveBackgroundNotificationResponse: _handleBackgroundNotificationClick,
  );
  isFlutterLocalNotificationsInitialized = true;
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await tryInitFirebase();
  //await setupFlutterNotifications();
  //showDeviceNotification(message);
  showStackNotification(message, payload: jsonEncode(message.data));
  print('## Handling background/terminated message: ${message.notification?.title}');
}

void handleNotificationClick(String? payload) {
  if (payload == null || payload.isEmpty) {
    print("## No payload found in notification.");
    return;
  }

  try {
    // Assuming the payload is a JSON string with a structure like:
    // { "type": "post", "id": "POST_ID_HERE" }
    final Map<String, dynamic> data = jsonDecode(payload);

    final type = data['type'];
    final postId = data['postId'];

    if (postId != null) {
      goTargetDetailsID(postId); // Navigate to post details screen
    } else {
      print("## Notification payload is invalid: $data");
    }
  } catch (e) {
    print("## Error parsing notification payload: $e");
  }
}

@pragma('vm:entry-point') // Ensure the callback is not removed by Dart
void _handleBackgroundNotificationClick(NotificationResponse response) {
  // Handle background notification click event
  print('## Background notification clicked');
  handleNotificationClick(response.payload);
}

//********************* PREFS notif saves *******************************************************
Future<List<String>> _getStoredMessages(String notifId) async {
  // Implement this to retrieve messages stored in local storage (SharedPreferences, etc.)
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('notif_messages_$notifId') ?? [];
}

Future<void> _storeMessages(String notifId, List<String> messages) async {
  // Implement this to store messages in local storage (SharedPreferences, etc.)
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('notif_messages_$notifId', messages);
}

Future<void> clearStoredMessages(String notifId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('notif_messages_$notifId');
}
