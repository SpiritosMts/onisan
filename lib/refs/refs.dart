
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/backend/deepLinking/deepLinkConfig.dart';
import 'package:onisan/backend/pagination/paginationCtr.dart';
import 'package:onisan/components/appInfo/appInfo.dart';
import 'package:onisan/components/connection/connectivity.dart';
import 'package:onisan/components/deviceInfo/deviceInfoService.dart';
import 'package:onisan/components/json/jsonFormat.dart';
import 'package:onisan/components/loading/loadingCtr.dart';
import 'package:onisan/notif/notifCtr.dart';
import 'package:onisan/settings/settingsCtr.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../backend/remoteConfig/remoteConfig.dart';
import '../components/myTheme/themeManager.dart';

RemoteConfigService get remoteConfigServ => RemoteConfigService.instance;
DeviceInfoService get deviceInfoServ => DeviceInfoService.instance;
ConnectivityService get connectivityServ => ConnectivityService.instance;
AppInfo get appInfoServ => AppInfo.instance;
User? get fAuthcUser => FirebaseAuth.instance.currentUser;
FirebaseAuth get fAuth => FirebaseAuth.instance;
FirebaseDatabase? get database => FirebaseDatabase.instance;//real time database


String snapshotErrorMsg = 'check Connexion'.tr;


// onisan ctrs ***********
LoadingService get ldCtr => Get.find<LoadingService>();
PaginationCtr get pagCtr => Get.find<PaginationCtr>();
SettingsCtr get settingCtr => Get.find<SettingsCtr>();
FirebaseMessagingCtr get ntfCtr => Get.find<FirebaseMessagingCtr>();





String usersCollName = 'users';
CollectionReference prDataColl = FirebaseFirestore.instance.collection('prData');
CollectionReference usersColl = FirebaseFirestore.instance.collection('users');
CollectionReference notificationsColl = FirebaseFirestore.instance.collection('notifications');

CollectionReference notifsColl({String? userID,bool specificColl = true}) {

  if(!specificColl) return notificationsColl;


  if (userID == null || userID.isEmpty) {
    throw ArgumentError('## UserID cannot be null or empty to get notifs');
  }
   return usersColl.doc(userID).collection('notifications');
}



///**************** NavigatorService
// class NavigatorService {
//   static GlobalKey<NavigatorState>? _navigatorKey;
//
//   // Getter to access the navigator key
//   static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey!;
//
//   // Setter to initialize the navigator key
//   static set navigatorKey(GlobalKey<NavigatorState> key) {
//     _navigatorKey = key;
//   }
// }

class NavigatorService {
  static GlobalKey<NavigatorState>? navigatorKey;
}




///************************** CustomVars


dynamic get ccUser => CustomVars.getUser();


class CustomVars {
  //collections names
  static late String usersCollName;
  static late List<String> availableLangs;


  static late String monochromeNotifIcon;//"@drawable/logo_mono"
  static late String normalNotifIcon;//'@mipmap/launcher_icon'

  //firebase

  static late FirebaseOptions firebaseOptions;

  static  DeepLinkConfig? deepLinkConfig;
  static late String vapidKeyNotif;
  static late String firebaseProjectId;



  // Static variables for palettes and Firebase options
  static late Map<String, ColorPalette> paletteMap;
  static late ThemeData Function() getAppTheme;
  static late List<GetPage> routes; // Static list for storing app routes
  // Binding function to call project-specific dependencies
  static late void Function() projectBindings;
  // Reactive cUser in onisan
  static late dynamic Function() getUser;
  static void initializeUser({required dynamic Function() userGetter}) {
    getUser = userGetter;
  }
  // Single method to initialize all custom variables
  static void initialize({
    required FirebaseOptions firebaseOpts,
     String cvUsersCollName="users",
    required Map<String, ColorPalette> palettes,
    required ThemeData Function() themeGetter,
    required List<GetPage> appRoutes,
     DeepLinkConfig? deepLinkCfg,
    required void Function() cvProjectBindings, // Required project bindings

    required String cvVapidKeyNotif,
    required String cvFirebaseProjectId,
    required String cvMonochromeNotifIcon,
    required String cvNormalNotifIcon,
     List<String> cvAvailableLangs= const ["en"],
  }) {
    projectBindings = cvProjectBindings;
    availableLangs = cvAvailableLangs;
    vapidKeyNotif = cvVapidKeyNotif;
    firebaseProjectId = cvFirebaseProjectId;
    monochromeNotifIcon = cvMonochromeNotifIcon;
    normalNotifIcon = cvNormalNotifIcon;

    usersCollName = cvUsersCollName;
    routes = appRoutes;
    firebaseOptions = firebaseOpts;
    paletteMap = palettes;
    getAppTheme = themeGetter;
    deepLinkConfig = deepLinkCfg;
  }

  // Method to print all CustomVars properties
  static void printAll() {
    print('## CustomVars Details:');

    // print('- Firebase Options:');
    // print('  Project ID: ${firebaseOptions.projectId}');
    // print('  API Key: ${firebaseOptions.apiKey}');
    // print('  App ID: ${firebaseOptions.appId}');

    // print('- Palette Map:');
    // paletteMap.forEach((key, value) {
    //   print('  $key: ${value.runtimeType}');
    // });

   // print('- Theme Getter: Exists? ${getAppTheme != null}');

    print('- Routes:');
    for (var route in routes) {
      print('  Route Name: ${route.name}');
    }

    print('- Deep Link Config:');
    printJson(deepLinkConfig!.toJson());


    printGetUser();
  }

 static void printGetUser() {
    try {
      if (CustomVars.getUser != null) {
        var user = CustomVars.getUser(); // Call the dynamic function

        if (user != null && user is! String && user.toJson != null) {
          printJson(user.toJson()); // Pretty print the JSON
        } else {
          print('## getUser result: $user'); // Fallback for non-JSON output
        }
      } else {
        print('## getUser is not initialized');
      }
    } catch (e) {
      print('## Error calling getUser: $e');
    }
  }



  // Setters for updating individual variables dynamically

  // Setter for firebaseOptions
  static void setFirebaseOptions(FirebaseOptions opts) {
    firebaseOptions = opts;
    print('## Firebase options updated');
  }

  // Setter for paletteMap
  static void setPaletteMap(Map<String, ColorPalette> palettes) {
    paletteMap = palettes;
    print('## Palette map updated');
  }

  // Setter for themeGetter
  static void setThemeGetter(ThemeData Function() themeGetter) {
    getAppTheme = themeGetter;
    print('## Theme getter updated');
  }

  // Setter for routes
  static void setRoutes(List<GetPage> appRoutes) {
    routes = appRoutes;
    print('## Routes updated');
  }

  // Setter for deepLinkConfig
  static void setDeepLinkConfig(DeepLinkConfig deepLinkCfg) {
    deepLinkConfig = deepLinkCfg;
    print('## Deep link config updated');
  }

  // Setter for getUser
  static void setUserGetter(dynamic Function() userGetter) {
    getUser = userGetter;
    print('## User getter updated');
  }
}
