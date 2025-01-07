
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  /// Log custom events
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    // Safely cast parameters to Map<String, Object> if not null
    await analytics.logEvent(
      name: name,
      parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
    );
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    await analytics.setUserId(id: userId);
  }

  /// Set user property
  Future<void> setUserProperty({required String name, required String value}) async {
    await analytics.setUserProperty(name: name, value: value);
  }

/// Other analytics methods can be added here as needed...
}
