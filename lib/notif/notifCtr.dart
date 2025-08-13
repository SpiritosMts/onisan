import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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

  Future<void> sendNotifApp({
    required String receiverToken,
    required String title,
    required String body,
    String imageUrl = '',
    Map<String, dynamic> data = const {},
    String? notifId,
  }) async {
    try {
      if (receiverToken.isEmpty) {
        print("## Error: Empty receiver token, cannot send notification");
        return;
      }

      final serviceAccount = await _loadServiceAccount();
      final authClient = await _getAuthClient(serviceAccount);
      String specificID = Uuid().v1();

      final url = 'https://fcm.googleapis.com/v1/projects/${CustomVars.firebaseProjectId}/messages:send';

      // Ensure data values are strings as required by FCM
      Map<String, String> stringData = {};
      data.forEach((key, value) {
        stringData[key] = value.toString();
      });

      final message = {
        "message": {
          "token": receiverToken,
          "notification": {
            "title": title,
            "body": body,
            if (imageUrl.isNotEmpty) "image": imageUrl,
          },
          "data": {
            ...stringData,
            "notifId": notifId ?? specificID,
          },
        }
      };

      print('## Sending FCM notification to token: ${receiverToken.substring(0, 10)}...');

      final response = await authClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('## ✅ FCM notification sent successfully');
        final responseData = jsonDecode(response.body);
        if (responseData['name'] != null) {
          print('## FCM message name: ${responseData['name']}');
        }
      } else {
        print('## ❌ FCM request failed with status code: ${response.statusCode}');
        print('## Error response: ${response.body}');
      }
    } catch (e) {
      print('## ❌ Error sending FCM message: $e');
    }
  }

  Future<void> sendNotifToUsers({required List users, required NotifItem notif, bool addToDb = false}) async {
    if (users.isEmpty) {
      print('## Error: No users provided to send notification to');
      return;
    }

    int successCount = 0;
    int failureCount = 0;
    List<String> successIds = [];
    List<String> failureIds = [];

    print('## Sending notification to ${users.length} users');

    for (var user in users) {
      // Skip users without device tokens
      if (user.deviceToken == null || user.deviceToken.isEmpty) {
        print('## Warning: User ${user.id} has no device token, skipping notification');
        failureCount++;
        failureIds.add(user.id);
        continue;
      }

      try {
        // Send push notification to the user
        await sendNotifApp(
          receiverToken: user.deviceToken, // Use user's device token
          title: notif.title,
          body: notif.body,
          imageUrl: notif.imageUrl,
          notifId: notif.id,
          data: notif.dataPayload,
        );

        successCount++;
        successIds.add(user.id);

        // Optionally add notification to Firestore DB for each user
        if (addToDb) {
          await addNotificationToDb(
            notif,
            userId: user.id,
          );
        }
      } catch (e) {
        print('## Error sending notification to user ${user.id}: $e');
        failureCount++;
        failureIds.add(user.id);
      }
    }

    print('## Notification sending complete - Success: $successCount, Failure: $failureCount');
    if (successCount > 0) {
      print('## Successfully sent to users: ${successIds.join(', ')}');
    }
    if (failureCount > 0) {
      print('## Failed to send to users: ${failureIds.join(', ')}');
    }
  }

  ///************************* TOKEN ******************************************

  String localToken = "";
  late Stream<String> _tokenStream;

  Future<void> streamUserToken() async {
    if (Platform.isIOS) {
      await _handleiOSTokenSetup();
    } else {
      // Android handling
      await _handleAndroidTokenSetup();
    }

    // Set up token refresh listener
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }

  Future<void> _handleiOSTokenSetup() async {
    try {
      print('## Starting iOS notification setup...');

      // Step 1: Request notification permissions first
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );

      print('## iOS permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('## iOS notification permissions denied by user');
        return;
      }

      // Step 2: Wait for APNs token to be available
      await _waitForAPNsToken();

      // Step 3: Get FCM token with retry mechanism
      await _getTokenWithRetry(maxRetries: 5);
    } catch (e) {
      print('## Error in iOS token setup: $e');
      // Fallback - try to get token anyway
      await _getTokenWithRetry(maxRetries: 3);
    }
  }

  Future<void> _handleAndroidTokenSetup() async {
    try {
      print('## Starting Android notification setup...');

      // Step 1: Check Android version and request notification permission if needed
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        // Android 13+ (API level 33+) requires runtime permission for notifications
        if (androidInfo.version.sdkInt >= 33) {
          print('## Android 13+ detected, requesting notification permission...');

          // Request notification permission using permission_handler
          PermissionStatus status = await Permission.notification.request();

          if (status.isGranted) {
            print('## Android notification permission granted');
          } else if (status.isDenied) {
            print('## Android notification permission denied');
            // Still try to get token in case user grants permission later
          } else if (status.isPermanentlyDenied) {
            print('## Android notification permission permanently denied');
            return; // Don't proceed if permanently denied
          }
        } else {
          print('## Android < 13, no runtime permission needed');
        }
      }

      // Step 2: Request FCM permissions (this handles the Firebase-level permissions)
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );

      print('## Android FCM permission status: ${settings.authorizationStatus}');

      // Step 3: Get FCM token
      String? token = await FirebaseMessaging.instance.getToken(vapidKey: CustomVars.vapidKeyNotif);
      if (token != null) {
        setToken(token);
        print('## ✅ Android FCM token obtained successfully');
      } else {
        print('## ⚠️ Android FCM token is null');
      }
    } catch (e) {
      print('## Error getting Android token: $e');
    }
  }

  Future<void> _waitForAPNsToken({int maxWaitTime = 30}) async {
    print('## Waiting for APNs token...');

    int attempts = 0;
    final int maxAttempts = maxWaitTime; // 30 seconds max wait

    while (attempts < maxAttempts) {
      try {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          print('## ✅ APNs token obtained: ${apnsToken.substring(0, 10)}...');
          return;
        }
      } catch (e) {
        print('## APNs token not ready yet (attempt ${attempts + 1}/$maxAttempts): $e');
      }

      await Future.delayed(Duration(seconds: 1));
      attempts++;
    }

    print('## ⚠️  APNs token not obtained after $maxWaitTime seconds, proceeding anyway...');
  }

  Future<void> _getTokenWithRetry({int maxRetries = 5}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('## Token request attempt $attempt/$maxRetries');

        String? token;
        if (Platform.isIOS) {
          // For iOS, don't pass vapidKey
          token = await FirebaseMessaging.instance.getToken();
        } else {
          // For Android, use vapidKey
          token = await FirebaseMessaging.instance.getToken(vapidKey: CustomVars.vapidKeyNotif);
        }

        if (token != null && token.isNotEmpty) {
          print('## ✅ FCM token obtained successfully');
          setToken(token);
          return;
        } else {
          print('## ⚠️  Token is null or empty on attempt $attempt');
        }
      } catch (e) {
        print('## ❌ Token request attempt $attempt failed: $e');

        if (e.toString().contains('apns-token-not-set') && Platform.isIOS) {
          print('## Waiting longer for APNs token...');
          await Future.delayed(Duration(seconds: 3));
        }
      }

      if (attempt < maxRetries) {
        // Exponential backoff: 2s, 4s, 6s, 8s, 10s
        int delaySeconds = attempt * 2;
        print('## Waiting ${delaySeconds}s before next attempt...');
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }

    print('## ❌ Failed to get FCM token after $maxRetries attempts');
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
        updateFieldInFirestore(usersColl, ccUser.id, 'deviceToken', localToken, onSuccess: () {}); //:online
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
    streamUserToken().catchError((e) {
      print('## Error in streamUserToken: $e');
    });

    // When the app is opened via notification click (background or terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('## App was launched from a terminated state by tapping a notification.');
        print('## Notification data: ${message.data}');
        handleNotificationClick(jsonEncode(message.data)).catchError((e) {
          print('## Error handling notification click from terminated state: $e');
        });
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
      handleNotificationClick(jsonEncode(message.data)).catchError((e) {
        print('## Error handling notification click from background: $e');
      });
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

  void startNotifsListening({String showNotifsFromDate = "0001-01-01T00:00:00.000000Z"}) {
    if (ccUser.id.isEmpty || ccUser.id == null) {
      print("## cant start notif listening (no User Id)");
      return;
    }

    //todo select the coll to listen from
    try {
      isLoading(true);

      _notificationSubscription = notifsColl(userID: ccUser.id).orderBy('creationTime', descending: true).where('creationTime', isGreaterThan: showNotifsFromDate).snapshots().listen((snapshot) {
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
    } catch (e) {
      hasNotifError(false);

      print("## error listening to notifs: $e");
    } finally {
      isLoading(false);
    }
  }

  ///***********************************************************************************************************************
  ///************************************************ Firebase Device send notification   *******************************************************************************
  ///*****************************************************************************************************************************

  ///******************************************  firebase function deplayed  *************************************************************************************

  // *******************************  SEND WITH FUNCTIONS ********************************************************

  Future<Map<String, dynamic>> sendNotifFbFunc(NotifItem notif, {bool addToDb = false, required List<String> targetIDs}) async {
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
            "notifId": "notifId**", //fixed
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
        // Add notification to database for each target user
        if (targetIDs.isNotEmpty) {
          for (var userId in targetIDs) {
            await addNotificationToDb(notif, userId: userId);
          }
        } else {
          // If no specific targets, add to current user's notifications
          await addNotificationToDb(notif);
        }
      }

      // Print detailed response information
      print('## Notification function response:');
      print('## Success send Count: ${response.data['successCount'] ?? 0}');
      print('## Failure send Count: ${response.data['failureCount'] ?? 0}');

      if (response.data['failureCount'] > 0 && response.data['errors'] != null) {
        print('## Errors: ${response.data['errors']}');
      }

      return response.data;
    } on FirebaseFunctionsException catch (e) {
      print('## FirebaseFunctionsException: ${e.code} - ${e.message}');
      print('## Function details: ${e.details}');
      throw e;
    } catch (e) {
      print('## Error sending notifications: $e');
      throw e;
    }
  }

  // *******************************  ADD TO FIRESTORE ********************************************************

  Future<void> addNotificationToDb(NotifItem notification, {String? userId}) async {
    // Validate parameters
    if (notification.id.isEmpty) {
      print('## Error: Notification ID is empty');
      return;
    }

    final targetUserId = userId ?? ccUser.id;
    if (targetUserId.isEmpty) {
      print('## Error: User ID is empty');
      return;
    }

    print('## Adding notification to DB - NotifID: ${notification.id}, UserID: $targetUserId');

    try {
      // Reference to the user's notifications subcollection
      CollectionReference notificationsRef = notifsColl(userID: targetUserId);

      print('## Collection path: ${notificationsRef.path}');
      print('## Notification data: ${notification.toJson()}');

      // Add the notification to the subcollection
      await notificationsRef.doc(notification.id).set(notification.toJson()).then((_) {
        print('## ✅ Notification added successfully to DB - NotifID: ${notification.id}');
      }).catchError((error) {
        print('## ❌ Failed to add notification to DB - NotifID: ${notification.id}, Error: $error');
      });
    } catch (e) {
      print('## ❌ Exception in addNotificationToDb: $e');
    }
  }

  void testSendNotifFunc({List<String> specificTargetIDs = const []}) {
    String specificID = Uuid().v1();
    NotifItem _notifExample = NotifItem(
      id: specificID,
      senderId: ccUser.id,
      creationTime: nowToUtc(),
      title: 'Test',
      body: "BL3arabi test notif",
      dataPayload: {
        //must be <string : string >
        "chatroomName": "fsdfsd sdf", //dynamic
        "single": "true", //dynamic
        "postId": "27c0622a-5eae-4a3b-a951-912d7c41a715", //dynamic
        //"notifId": "123",//fixed in functions
      },
      topic: 'Promotions',
      type: 'promotion',
      priority: 'hign',
      status: 'active',
      imageUrl: "https://firebasestorage.googleapis.com/v0/b/belaaraby-61999.appspot.com/o/adminFiles%2FappLogo.png?alt=media&token=91915df6-0ef1-4bd8-9556-e979e0889605",
      read: false,
    );

    // If no specific target IDs are provided, use the current user's ID (if available)
    List<String> targetIDs = specificTargetIDs.isEmpty ? (ccUser.id != null && ccUser.id.isNotEmpty ? [ccUser.id] : []) : specificTargetIDs;

    if (targetIDs.isEmpty) {
      print('## Warning: No target user IDs available for test notification.');
    } else {
      print('## Sending test notification to users: $targetIDs');
    }

    sendNotifFbFunc(_notifExample, targetIDs: targetIDs, addToDb: true);
  }
}

///---------------------------------------- NOtification Permissions -----------------------------------------------

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

  if (notification != null && !kIsWeb) {
    flutterLocalNotificationsPlugin!.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: android != null
            ? AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                importance: Importance.max,
                priority: Priority.max,
                icon: CustomVars.monochromeNotifIcon,
                playSound: true,
                enableVibration: true,
                styleInformation: bigPictureStyleInformation, // Show image if available
              )
            : null,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          attachments: notificationImageUrl.isNotEmpty ? [DarwinNotificationAttachment(notificationImageUrl)] : null,
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

  if (notification != null && !kIsWeb) {
    print('## showing Notification On Device...  ( ${payload != null ? "with payload" : "with NO payload"})  ##');
    flutterLocalNotificationsPlugin!.show(
      notificationId, // Use chatId hash as the notification ID to group notifications
      notification.title,
      notification.body, // You can omit this if you're using the inbox style to show the messages
      payload: payload,

      ///set THE PAYLOAD which i get later ****************************
      NotificationDetails(
        android: android != null
            ? AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                importance: Importance.max,
                priority: Priority.max,
                icon: CustomVars.monochromeNotifIcon,
                playSound: true,
                enableVibration: true,
                styleInformation: single ? bigTextStyleInformation : inboxStyleInformation, // Inbox style for showing multiple lines
              )
            : null,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          subtitle: single ? null : '${messages.length} messages',
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

/// Handles notification click and navigates to the appropriate screen
///
/// Expected payload format (JSON string):
/// For Store navigation:
/// {
///   "type": "store",
///   "targetId": "store_id_here",
///   "storeId": "store_id_here" // optional, will use targetId if missing
/// }
///
/// For Category navigation:
/// {
///   "type": "category",
///   "targetId": "category_id_here",
///   "storeId": "store_id_here" // required
/// }
///
/// For Product navigation:
/// {
///   "type": "product",
///   "targetId": "product_id_here",
///   "storeId": "store_id_here", // required
///   "categoryId": "category_id_here" // required
/// }
///
/// Legacy support:
/// {
///   "type": "post",
///   "postId": "id_here" // will be treated as targetId
/// }
Future<void> handleNotificationClick(String? payload) async {
  print("## handleNotificationClick called with payload: $payload");

  if (payload == null || payload.isEmpty) {
    print("## No payload found in notification.");
    return;
  }

  try {
    final Map<String, dynamic> data = jsonDecode(payload);
    print("## Parsed notification data: $data");

    final type = data['type'];
    final targetId = data['targetId']; // Support both targetId and legacy postId
    final storeId = data['storeId'];

    print("## Notification type: $type, targetId: $targetId, storeId: $storeId");

    if (targetId != null && type != null) {
      print("## Navigating to $type with targetId: $targetId");

      // Determine target route
      String targetRoute;
      if (type == 'store') {
        final storeIdToUse = storeId ?? targetId;
        targetRoute = '/store/$storeIdToUse';
      } else if (type == 'product' && storeId != null) {
        final categoryId = data['categoryId'];
        if (categoryId != null) {
          targetRoute = '/store/$storeId/category/$categoryId/product/$targetId';
        } else {
          targetRoute = '/store/$storeId';
        }
      } else if (type == 'category' && storeId != null) {
        targetRoute = '/store/$storeId/category/$targetId';
      } else {
        targetRoute = '/store/$targetId';
      }

      // Check if we're already on the target route
      final currentRoute = Get.currentRoute;
      print("## Current route: $currentRoute, Target route: $targetRoute");

      if (currentRoute == targetRoute) {
        print("## Already on target route, skipping navigation");
        return;
      }

      // Remove any existing store routes from navigation stack before navigating
      Get.until((route) => !route.settings.name!.contains('/store'));

      // Pre-load data before navigation to prevent "not found" errors
      await _preloadDataForNavigation(type, targetId, storeId, data['categoryId']);

      // Navigate to the target route
      Get.toNamed(targetRoute);

      if (type == 'store') {
        final storeIdToUse = storeId ?? targetId;
        print("## Navigated to store: $storeIdToUse (removed existing store routes)");
      } else if (type == 'product' && storeId != null) {
        final categoryId = data['categoryId'];
        if (categoryId != null) {
          print("## Navigated to product: $targetId in store: $storeId, category: $categoryId (removed existing store routes)");
        } else {
          print("## Missing categoryId for product, navigated to store: $storeId (removed existing store routes)");
        }
      } else if (type == 'category' && storeId != null) {
        print("## Navigated to category: $targetId in store: $storeId (removed existing store routes)");
      } else {
        print("## Used fallback navigation to store: $targetId (removed existing store routes)");
      }
    } else {
      print("## Notification payload is invalid - missing required fields: $data");
    }
  } catch (e) {
    print("## Error parsing notification payload: $e");
    print("## Raw payload was: $payload");
  }
}

/// Pre-load data before navigation to prevent "not found" errors
Future<void> _preloadDataForNavigation(String type, String targetId, String? storeId, String? categoryId) async {
  try {
    print("## Pre-loading data for $type navigation");

    if (type == 'store' && targetId.isNotEmpty) {
      // For store navigation, ensure store data is loaded
      final storeIdToUse = storeId ?? targetId;
      print("## Pre-loading store data for: $storeIdToUse");

      // Import and use SelectedStCtr if available
      try {
        final ssCtr = Get.find<dynamic>(); // Generic find to avoid import issues
        if (ssCtr.toString().contains('SelectedStCtr')) {
          await ssCtr.fetchStoreById(storeIdToUse, setAsSelected: true);
          print("## Store data pre-loaded successfully");
        }
      } catch (e) {
        print("## Could not pre-load store data: $e");
      }
    } else if (type == 'category' && storeId != null && targetId.isNotEmpty) {
      // For category navigation, ensure store and category data is loaded
      print("## Pre-loading store and category data for store: $storeId, category: $targetId");

      try {
        final ssCtr = Get.find<dynamic>();
        if (ssCtr.toString().contains('SelectedStCtr')) {
          await ssCtr.fetchStoreById(storeId, setAsSelected: true);
          await ssCtr.loadCategoryById(targetId);
          print("## Store and category data pre-loaded successfully");
        }
      } catch (e) {
        print("## Could not pre-load store/category data: $e");
      }
    } else if (type == 'product' && storeId != null && categoryId != null && targetId.isNotEmpty) {
      // For product navigation, ensure store, category, and product data is loaded
      print("## Pre-loading store, category, and product data for store: $storeId, category: $categoryId, product: $targetId");

      try {
        final ssCtr = Get.find<dynamic>();
        if (ssCtr.toString().contains('SelectedStCtr')) {
          await ssCtr.fetchStoreById(storeId, setAsSelected: true);
          await ssCtr.loadCategoryById(categoryId);
          await ssCtr.loadProductById(targetId);
          print("## Store, category, and product data pre-loaded successfully");
        }
      } catch (e) {
        print("## Could not pre-load store/category/product data: $e");
      }
    }

    // Add a small delay to ensure data is properly set
    await Future.delayed(Duration(milliseconds: 100));
  } catch (e) {
    print("## Error in _preloadDataForNavigation: $e");
    // Continue anyway - navigation should still work even if pre-loading fails
  }
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

//*************************************************************** */

Future<bool> requestNotificationsPermission() async {
  try {
    print('## Requesting notifications permission...');

    if (Platform.isIOS) {
      return await _requestiOSNotificationPermission();
    } else if (Platform.isAndroid) {
      return await _requestAndroidNotificationPermission();
    }

    return false;
  } catch (e) {
    print('## Error requesting notification permission: $e');
    return false;
  }
}

/// Test notification permissions and debug information
Future<void> testNotificationPermissions() async {
  if (kIsWeb) {
    print('🌐 Web platform - skipping permission test');
    return;
  }

  try {
    print('🧪 Testing notification permissions...');

    // Test Firebase messaging permissions
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();

    print('📊 === NOTIFICATION PERMISSION TEST RESULTS ===');
    print('🔔 User granted permission: ${settings.authorizationStatus}');
    print('🔔 Authorization Status: ${settings.authorizationStatus.name}');
    print('🔔 Alert: ${settings.alert}');
    print('🔔 Badge: ${settings.badge}');
    print('🔔 Sound: ${settings.sound}');
    print('🔔 Announcement: ${settings.announcement}');
    print('🔔 Car Play: ${settings.carPlay}');
    print('🔔 Critical Alert: ${settings.criticalAlert}');

    // Get FCM token
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        print('🔑 FCM Token: ${token.substring(0, 20)}...');
      } else {
        print('❌ FCM Token is null');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }

    // Platform-specific checks
    if (Platform.isIOS) {
      print('🍎 iOS-specific checks:');

      // Check APNs token
      try {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          print('🔑 APNs Token: ${apnsToken.substring(0, 20)}...');
        } else {
          print('⚠️ APNs Token is null - this might be the issue!');
        }
      } catch (e) {
        print('❌ Error getting APNs token: $e');
      }
    } else if (Platform.isAndroid) {
      print('🤖 Android-specific checks:');

      // Check Android notification permission
      PermissionStatus notificationStatus = await Permission.notification.status;
      print('🔔 Android notification permission: $notificationStatus');
    }

    print('📊 === END TEST RESULTS ===');
  } catch (e) {
    print('❌ Error in notification permission test: $e');
  }
}

Future<bool> _requestiOSNotificationPermission() async {
  try {
    print('## 🍎 Requesting iOS notification permissions...');

    // Request permissions through Firebase Messaging (more reliable for iOS)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      announcement: false,
    );

    bool granted = settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional;

    print('## 🔔 iOS notification permission: ${settings.authorizationStatus}');
    print('## 🔔 Alert setting: ${settings.alert}');
    print('## 🔔 Badge setting: ${settings.badge}');
    print('## 🔔 Sound setting: ${settings.sound}');

    if (granted) {
      print('## ✅ iOS notification permissions granted');

      // Also request through flutter_local_notifications for local notifications
      await _requestLocalNotificationPermission();

      // Force APNs token refresh for production
      try {
        await FirebaseMessaging.instance.getAPNSToken();
        print('## 🔑 APNs token refresh requested');
      } catch (e) {
        print('## ⚠️ APNs token refresh failed: $e');
      }

      // Get and log FCM token for debugging
      try {
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          print('## 🔑 FCM Token obtained: ${fcmToken.substring(0, 20)}...');
        } else {
          print('## ❌ FCM Token is null');
        }
      } catch (e) {
        print('## ❌ Error getting FCM token: $e');
      }
    } else {
      print('## ❌ iOS notification permissions denied');

      // Log detailed reason for denial
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.denied:
          print('## 🚫 User explicitly denied permissions');
          break;
        case AuthorizationStatus.notDetermined:
          print('## ❓ Permission not determined - this shouldn\'t happen after request');
          break;
        default:
          print('## ❓ Unknown authorization status: ${settings.authorizationStatus}');
      }
    }

    settingCtr.saveNotifSetting(granted);
    return granted;
  } catch (e) {
    print('## ❌ Error requesting iOS notification permission: $e');
    settingCtr.saveNotifSetting(false);
    return false;
  }
}

Future<void> _requestLocalNotificationPermission() async {
  if (flutterLocalNotificationsPlugin != null) {
    final bool? result = await flutterLocalNotificationsPlugin!.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    print('## Local notification permission result: $result');
  }
}

Future<bool> _requestAndroidNotificationPermission() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;

  if (androidInfo.version.sdkInt >= 33) {
    // Android 13+
    final status = await Permission.notification.request();
    bool granted = status == PermissionStatus.granted;

    if (status == PermissionStatus.permanentlyDenied) {
      print('## Android notification permission permanently denied');
      openAppSettings();
    }

    settingCtr.saveNotifSetting(granted);
    return granted;
  } else {
    // Android < 13
    print('## Android < 13, notification permission granted by default');
    settingCtr.saveNotifSetting(true);
    return true;
  }
}

///************************* ENHANCED NOTIFICATION SETUP ******************************************

///************************* DEBUGGING METHODS ******************************************

Future<void> checkTokenStatus() async {
  try {
    print('## === TOKEN STATUS CHECK ===');

    if (Platform.isIOS) {
      // Check APNs token
      try {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        print('## APNs Token: ${apnsToken != null ? "✅ Available (${apnsToken.substring(0, 10)}...)" : "❌ Not available"}');
      } catch (e) {
        print('## APNs Token: ❌ Error - $e');
      }
    }

    // Check FCM token
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: Platform.isIOS ? null : CustomVars.vapidKeyNotif);
      print('## FCM Token: ${fcmToken != null ? "✅ Available (${fcmToken.substring(0, 10)}...)" : "❌ Not available"}');
    } catch (e) {
      print('## FCM Token: ❌ Error - $e');
    }

    // Check notification settings
    NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
    print('## Authorization Status: ${settings.authorizationStatus}');
    print('## Alert Setting: ${settings.alert}');
    print('## Badge Setting: ${settings.badge}');
    print('## Sound Setting: ${settings.sound}');

    print('## === END TOKEN STATUS ===');
  } catch (e) {
    print('## Error checking token status: $e');
  }
}

/// Enhanced notification initialization ****************************************************
Future<void> initializeNotifications() async {
  try {
    print('## Initializing notifications...');

    if (!kIsWeb) {
      // Mobile platform (iOS/Android)
      await setupFlutterNotifications();

      // Set up FCM for mobile
      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      // Configure foreground notification presentation (important for iOS)
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else {
      // Web platform
      // Make sure you have firebase-messaging-sw.js in your /web directory
      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      // For web, you might want to request permission here
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('## Web notification permissions granted');
      } else {
        print('## Web notification permissions denied');
      }
    }

    // Register the background message handler (IMPORTANT: This must be called at top level)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    print('## ✅ Notification initialization complete');
  } catch (e) {
    print('## ❌ Error initializing notifications: $e');
    // Don't let notification errors crash the app
  }
}

/// Background message handler - MUST be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in the background isolate
  await Firebase.initializeApp();

  // Initialize local notifications if needed
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  print('## Handling background message: ${message.notification?.title}');

  // Show notification
  if (!kIsWeb) {
    await showStackNotification(message, payload: jsonEncode(message.data));
  }
}

/// Alternative initialization if you want more control
Future<void> initializeNotificationsWithPermissions() async {
  try {
    print('## 🚀 Initializing notifications with permission check...');

    if (!kIsWeb) {
      // Mobile platform

      // Step 1: Setup flutter local notifications
      await setupFlutterNotifications();

      // Step 2: Request permissions first (especially important for iOS)
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );

      bool permissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional;

      if (permissionGranted) {
        print('## ✅ Mobile notification permissions granted');

        // Step 3: Enable FCM auto-init after permissions are granted
        await FirebaseMessaging.instance.setAutoInitEnabled(true);

        // Step 4: Configure foreground presentation
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // Step 5: For iOS production, ensure APNs token is available
        if (Platform.isIOS) {
          try {
            String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            if (apnsToken != null) {
              print('## 🍎 APNs token available for production');
            } else {
              print('## ⚠️ APNs token not available - may affect production notifications');
              // Try to refresh token
              await Future.delayed(Duration(seconds: 2));
              apnsToken = await FirebaseMessaging.instance.getAPNSToken();
              if (apnsToken != null) {
                print('## 🍎 APNs token obtained after retry');
              }
            }
          } catch (e) {
            print('## ❌ Error checking APNs token: $e');
          }
        }
      } else {
        print('## ❌ Mobile notification permissions denied');
        print('## 🔔 Authorization status: ${settings.authorizationStatus}');
        // You might want to show a dialog explaining why notifications are important
      }
    } else {
      // Web platform
      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      // Request web permissions
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
      print('## 🌐 Web notification permission: ${settings.authorizationStatus}');
    }

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    print('## ✅ Enhanced notification initialization complete');
  } catch (e) {
    print('## ❌ Error in enhanced notification initialization: $e');
  }
}

/// Your existing setupFlutterNotifications function should be updated like this:
Future<void> setupFlutterNotifications() async {
  print('## Setting up Flutter Local Notifications...');

  if (isFlutterLocalNotificationsInitialized) {
    print('## Flutter notifications already initialized');
    return;
  }

  try {
    // Create notification channel for Android
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      showBadge: true,
      playSound: true,
      enableVibration: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Create the channel on Android
    await flutterLocalNotificationsPlugin!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    // Initialize the plugin
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll handle this through FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        handleNotificationClick(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: _handleBackgroundNotificationClick,
    );

    isFlutterLocalNotificationsInitialized = true;
    print('## ✅ Flutter Local Notifications setup complete');
  } catch (e) {
    print('## ❌ Error setting up Flutter Local Notifications: $e');
    // Don't let this error crash the app initialization
  }
}

/// Updated background notification handler
@pragma('vm:entry-point')
void _handleBackgroundNotificationClick(NotificationResponse response) {
  print('## Background notification clicked: ${response.payload}');
  handleNotificationClick(response.payload);
}
