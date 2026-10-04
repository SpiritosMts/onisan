import 'dart:async';

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
  // Optimistic until the first check completes: a false "offline" blocks app start.
  bool _isConnected = true;
  bool wentOffline = false;
  bool _initialized = false;
  bool isConnected() => _isConnected;

  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  /// Emits true/false whenever the connection status changes.
  Stream<bool> get onStatusChange => _statusController.stream;

  /// Any transport except `none` counts as connected (wifi, mobile, ethernet, vpn, other...).
  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);

  /// Checks the current status now (instead of waiting for a change event).
  Future<bool> checkNow() async {
    try {
      _isConnected = _hasConnection(await _connectivity.checkConnectivity());
    } catch (e) {
      print('## connectivity check failed: $e');
    }
    return _isConnected;
  }




  //********************************************************************

  void initialize() {
    if (_initialized) return;
    _initialized = true;
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
      _isConnected = _hasConnection(results);
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
    checkNow();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _isConnected = _hasConnection(results);
      _handleConnectivityChange();
    });
  }

  void _handleConnectivityChange() {

    print('## connection state changes....');
    _statusController.add(_isConnected);


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
