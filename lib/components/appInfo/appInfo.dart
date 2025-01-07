import 'package:package_info_plus/package_info_plus.dart';


/// call "await appInfoServ.version"
class AppInfo {
  // Singleton instance
  static final AppInfo _instance = AppInfo._internal();

  // Private fields for app info
  String _appName = '';
  String _packageName = '';
  String _version = '';
  String _buildNumber = '';
  bool _isInitialized = false;

  // Private constructor
  AppInfo._internal();

  // Public getter for the singleton instance
  static AppInfo get instance => _instance;

  // Asynchronous getter to fetch app info
  Future<void> _initializeIfNeeded() async {
    if (!_isInitialized) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _packageName = packageInfo.packageName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
      _isInitialized = true;
    }
  }

  // Public getters that ensure initialization
  Future<String> get appName async {
    await _initializeIfNeeded();
    return _appName;
  }

  Future<String> get packageName async {
    await _initializeIfNeeded();
    return _packageName;
  }

  Future<String> get version async {
    await _initializeIfNeeded();
    return _version;
  }

  Future<String> get buildNumber async {
    await _initializeIfNeeded();
    return _buildNumber;
  }

  @override
  String toString() {
    return 'AppInfo(appName: $_appName, packageName: $_packageName, version: $_version, buildNumber: $_buildNumber)';
  }
}
