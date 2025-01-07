import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:onisan/components/snackbar/topAnimated.dart';



//todo make connection checker for web
class ConnectivityService {

  //************************ Singleton instance *********************
  static ConnectivityService get instance => _instance;

  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();

  // Private internal constructor
  ConnectivityService._internal();


  // **************************************

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;
  bool wentOffline = false;
  bool isConnected() => _isConnected;




  //********************************************************************

  void initialize() {
    if (kIsWeb) {
      _initializeWebConnectivity();
    } else {
      _initializeMobileConnectivity();
    }
  }
  // Web-specific connectivity implementation
  void _initializeWebConnectivity() {
    // Check initial connectivity status
    _isConnected = _checkWebConnection();

    // Add listeners for connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _isConnected = results.contains(ConnectivityResult.none);
      _handleConnectivityChange();
    });
  }
  bool _checkWebConnection() {
    // Implement a method to check web connectivity, e.g., by making a simple HTTP request
    // Return true if connected, false otherwise
    // Placeholder implementation:
    return true;
  }
  // Mobile/desktop connectivity implementation
  void _initializeMobileConnectivity() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _isConnected = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
      _handleConnectivityChange();
    });
  }

  void _handleConnectivityChange() {

    print('## connection state changes....');


    if (!_isConnected) {//offline
      print('## user offline');
      animatedSnack(message: 'You are currently offline. Please check your connection.', type: 'err', duration: 3);
      wentOffline=true;
    } else {//online
      if(!wentOffline) {
        return;
      }
      print('## user online');
      animatedSnack(message: 'Back Online', type: 'succ', duration: 3);
    }
  }



}
