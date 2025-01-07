import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService instance = RemoteConfigService._internal();
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Public map to store remote config values for easy access
  final Map<String, dynamic> remoteConfigValues = {};

  RemoteConfigService._internal();

  Future<void> initialize({
    required Map<String, dynamic> defaultValues,
    Duration fetchTimeout = const Duration(seconds: 10),
    Duration minimumFetchInterval = const Duration(minutes: 5),
  }) async {
    // Set Remote Config settings
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: fetchTimeout,
      minimumFetchInterval: minimumFetchInterval,
    ));

    // Set default values
    await _remoteConfig.setDefaults(defaultValues);

    // Fetch and activate remote config values
    await _remoteConfig.fetchAndActivate();

    // Populate remoteConfigValues with the converted values
    final allValues = _remoteConfig.getAll();
    for (var entry in allValues.entries) {
      remoteConfigValues[entry.key] = _convertRemoteConfigValue(entry.value);
    }
  }

  // Helper method to convert RemoteConfigValue to dynamic type
  dynamic _convertRemoteConfigValue(RemoteConfigValue value) {
    if (value.asString() != null && value.asString().isNotEmpty) {
      return value.asString();
    } else if (value.asBool() != null) {
      return value.asBool();
    } else if (value.asInt() != null) {
      return value.asInt();
    } else if (value.asDouble() != null) {
      return value.asDouble();
    }
    return null;
  }
}
