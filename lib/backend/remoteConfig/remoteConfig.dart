import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:developer' as developer;

class RemoteConfigService {
  static final RemoteConfigService instance = RemoteConfigService._internal();
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Public map to store remote config values for easy access
  final Map<String, dynamic> remoteConfigValues = {};
  
  // Track initialization status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  RemoteConfigService._internal();

  Future<void> initialize({
    required Map<String, dynamic> defaultValues,
    Duration fetchTimeout = const Duration(seconds: 10),
    Duration minimumFetchInterval = const Duration(minutes: 5),
    int maxRetries = 3,
  }) async {
    try {
      developer.log('Initializing Remote Config...', name: 'RemoteConfig');
      
      // Set default values first
      await _remoteConfig.setDefaults(defaultValues);
      developer.log('Default values set successfully', name: 'RemoteConfig');
      
      // Populate with default values initially
      _populateWithDefaults(defaultValues);
      
      // Set Remote Config settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: fetchTimeout,
        minimumFetchInterval: minimumFetchInterval,
      ));
      developer.log('Remote config settings configured', name: 'RemoteConfig');

      // Try to fetch remote values with retry logic
      bool fetchSuccess = false;
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          developer.log('Fetch attempt $attempt/$maxRetries', name: 'RemoteConfig');
          
          // Try fetch and activate
          bool activated = await _remoteConfig.fetchAndActivate();
          developer.log('Fetch and activate result: $activated', name: 'RemoteConfig');
          
          fetchSuccess = true;
          break;
        } catch (e) {
          developer.log('Fetch attempt $attempt failed: $e', name: 'RemoteConfig');
          
          if (attempt == maxRetries) {
            developer.log('All fetch attempts failed, using default values', name: 'RemoteConfig');
            break;
          }
          
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }

      // Update values from remote config (if fetch was successful)
      if (fetchSuccess) {
        _updateValuesFromRemoteConfig();
        developer.log('Remote config values updated successfully', name: 'RemoteConfig');
      } else {
        developer.log('Using default values due to fetch failure', name: 'RemoteConfig');
      }
      
      _isInitialized = true;
      developer.log('Remote Config initialization completed', name: 'RemoteConfig');
      
    } catch (e) {
      developer.log('Remote Config initialization error: $e', name: 'RemoteConfig');
      
      // Ensure we have at least default values
      _populateWithDefaults(defaultValues);
      _isInitialized = true;
      
      // Don't throw the error, just log it and continue with defaults
      developer.log('Continuing with default values only', name: 'RemoteConfig');
    }
  }
  
  // Populate remoteConfigValues with default values
  void _populateWithDefaults(Map<String, dynamic> defaultValues) {
    remoteConfigValues.clear();
    remoteConfigValues.addAll(defaultValues);
    developer.log('Populated with ${defaultValues.length} default values', name: 'RemoteConfig');
  }
  
  // Update values from remote config
  void _updateValuesFromRemoteConfig() {
    try {
      final allValues = _remoteConfig.getAll();
      for (var entry in allValues.entries) {
        remoteConfigValues[entry.key] = _convertRemoteConfigValue(entry.value);
      }
      developer.log('Updated ${allValues.length} remote config values', name: 'RemoteConfig');
    } catch (e) {
      developer.log('Error updating values from remote config: $e', name: 'RemoteConfig');
    }
  }

  // Helper method to convert RemoteConfigValue to dynamic type
  dynamic _convertRemoteConfigValue(RemoteConfigValue value) {
    try {
      final stringValue = value.asString();
      
      // Try to parse as different types
      if (stringValue.toLowerCase() == 'true') return true;
      if (stringValue.toLowerCase() == 'false') return false;
      
      // Try to parse as int
      final intValue = int.tryParse(stringValue);
      if (intValue != null) return intValue;
      
      // Try to parse as double
      final doubleValue = double.tryParse(stringValue);
      if (doubleValue != null) return doubleValue;
      
      // Return as string if no other type matches
      return stringValue;
    } catch (e) {
      developer.log('Error converting remote config value: $e', name: 'RemoteConfig');
      return null;
    }
  }
  
  // Safe getter methods
  String getString(String key, {String defaultValue = ''}) {
    if (!_isInitialized) {
      developer.log('RemoteConfig not initialized, returning default for $key', name: 'RemoteConfig');
      return defaultValue;
    }
    return remoteConfigValues[key]?.toString() ?? defaultValue;
  }
  
  bool getBool(String key, {bool defaultValue = false}) {
    if (!_isInitialized) {
      developer.log('RemoteConfig not initialized, returning default for $key', name: 'RemoteConfig');
      return defaultValue;
    }
    final value = remoteConfigValues[key];
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return defaultValue;
  }
  
  int getInt(String key, {int defaultValue = 0}) {
    if (!_isInitialized) {
      developer.log('RemoteConfig not initialized, returning default for $key', name: 'RemoteConfig');
      return defaultValue;
    }
    final value = remoteConfigValues[key];
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
  
  double getDouble(String key, {double defaultValue = 0.0}) {
    if (!_isInitialized) {
      developer.log('RemoteConfig not initialized, returning default for $key', name: 'RemoteConfig');
      return defaultValue;
    }
    final value = remoteConfigValues[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
  
  // Force refresh method
  Future<bool> forceRefresh() async {
    if (!_isInitialized) {
      developer.log('Cannot refresh: RemoteConfig not initialized', name: 'RemoteConfig');
      return false;
    }
    
    try {
      // Force fetch with minimum interval of 0
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));
      
      bool activated = await _remoteConfig.fetchAndActivate();
      if (activated) {
        _updateValuesFromRemoteConfig();
        developer.log('Force refresh successful', name: 'RemoteConfig');
      }
      return activated;
    } catch (e) {
      developer.log('Force refresh failed: $e', name: 'RemoteConfig');
      return false;
    }
  }
}
