import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ConditionCallback = bool Function();

class GeneralMiddleware extends GetMiddleware {
  final bool active;
  final String? prefsKey;
  final ConditionCallback? condition;
  final String redirectRoute;
  final int? middlewarePriority;

  // Cache for storing preloaded preferences
  static final Map<String, bool> _prefsCache = {};

  GeneralMiddleware({
    this.active = true,
    this.prefsKey,
    this.condition,
    required this.redirectRoute,
    this.middlewarePriority,
  });

  @override
  int? get priority => middlewarePriority;

  @override
  RouteSettings? redirect(String? route) {
    if (!active) return null; // Middleware is disabled

    // Check cached preference if prefsKey is provided
    if (prefsKey != null) {
      final prefValue = _prefsCache[prefsKey] ?? false;
      if (!prefValue) {
        return RouteSettings(name: redirectRoute);
      }
    }

    // Check custom condition if provided
    if (condition != null && condition!()) {
      return RouteSettings(name: redirectRoute);
    }

    return null; // No redirection, continue to the intended route
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    print('## (GeneralMiddleware) Page build is starting: $page');
    return page;
  }

  @override
  Widget onPageBuilt(Widget page) {
    print('## (GeneralMiddleware) Page has been built: $page');
    return page;
  }

  @override
  void onPageDispose() {
    print('## (GeneralMiddleware) Page is being disposed');
  }

  // Method to preload preferences into the cache
  static Future<void> preloadPreferences(List<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in keys) {
      _prefsCache[key] = prefs.getBool(key) ?? false;
    }
    print('## Preloaded preferences: $_prefsCache');
  }
}
