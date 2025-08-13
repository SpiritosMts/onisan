// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:onisan/components/localStorage/prefs.dart';
// import 'package:onisan/refs/refs.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// typedef ConditionCallback = bool Function();

// /// Enhanced GeneralMiddleware with better error handling and safe navigation
// class GeneralMiddleware extends GetMiddleware {
//   final bool active;
//   final bool usePrefsKeyAsCondition;
//   final String? prefsKey;
//   final ConditionCallback? condition;
//   final String redirectRoute;
//   final int? middlewarePriority;
//   final String fallbackRoute;

//   // Cache for storing preloaded preferences
//   static final Map<String, bool> _prefsCache = {};
  
//   // Track navigation attempts for debugging
//   static final List<String> _navigationLog = [];
//   static const int _maxLogEntries = 50;

//   GeneralMiddleware({
//     this.active = true,
//     this.prefsKey,
//     this.usePrefsKeyAsCondition = true,
//     this.condition,
//     required this.redirectRoute,
//     this.middlewarePriority,
//     this.fallbackRoute = '/splash', // Safe fallback route
//   });

//   @override
//   int? get priority => middlewarePriority ?? 1;

//   @override
//   RouteSettings? redirect(String? route) {
//     try {
//       _logNavigation('Checking route: $route');
      
//       if (!active) {
//         _logNavigation('Middleware is disabled, continuing to route: $route');
//         return null;
//       }

//       // Validate context availability
//       if (Get.context == null) {
//         _logNavigation('No context available, redirecting to fallback: $fallbackRoute');
//         return RouteSettings(name: fallbackRoute);
//       }

//       // Validate the target route exists
//       if (route != null && !_isValidRoute(route)) {
//         _logNavigation('Invalid route detected: $route, redirecting to fallback: $fallbackRoute');
//         return RouteSettings(name: fallbackRoute);
//       }

//       // Check cached preference if prefsKey is provided
//       if (usePrefsKeyAsCondition && prefsKey != null) {
//         try {
//           final prefValue = _getPreferenceValue(prefsKey!);
//           _logNavigation('Preference check for $prefsKey: $prefValue');
          
//           if (!prefValue) {
//             _logNavigation('Preference condition not met, redirecting to: $redirectRoute');
//             return RouteSettings(name: redirectRoute);
//           }
//         } catch (e) {
//           _logNavigation('Error checking preferences: $e, allowing navigation');
//           // Continue with navigation if preference check fails
//         }
//       }

//       // Check custom condition if provided
//       if (condition != null) {
//         try {
//           final conditionResult = condition!();
//           _logNavigation('Custom condition result: $conditionResult');
          
//           if (conditionResult) {
//             _logNavigation('Custom condition met, redirecting to: $redirectRoute');
//             return RouteSettings(name: redirectRoute);
//           }
//         } catch (e) {
//           _logNavigation('Error in custom condition: $e, allowing navigation');
//           // Continue with navigation if condition check fails
//         }
//       }

//       _logNavigation('All checks passed, continuing to route: $route');
//       return null; // No redirection, continue to the intended route

//     } catch (e) {
//       _logNavigation('Critical error in redirect: $e');
//       // In case of any critical error, redirect to fallback
//       return RouteSettings(name: fallbackRoute);
//     }
//   }

//   @override
//   GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
//     try {
//       _logNavigation('Page build starting');
//       return page;
//     } catch (e) {
//       _logNavigation('Error in onPageBuildStart: $e');
//       return page;
//     }
//   }

//   @override
//   Widget onPageBuilt(Widget page) {
//     try {
//       _logNavigation('Page built successfully');
      
//       // Wrap page in error boundary for additional safety
//       return _SafePageWrapper(child: page);
      
//     } catch (e) {
//       _logNavigation('Error building page: $e');
//       return _buildErrorPage(e.toString());
//     }
//   }

//   @override
//   GetPage? onPageCalled(GetPage? page) {
//     try {
//       _logNavigation('Page called: ${page?.name}');
//       return super.onPageCalled(page);
//     } catch (e) {
//       _logNavigation('Error in onPageCalled: $e');
//       return page;
//     }
//   }

//   @override
//   void onPageDispose() {
//     try {
//       _logNavigation('Page disposing');
//       super.onPageDispose();
//     } catch (e) {
//       _logNavigation('Error in onPageDispose: $e');
//     }
//   }

//   // Helper method to get preference value with fallback
//   bool _getPreferenceValue(String key) {
//     try {
//       // Try cache first
//       if (_prefsCache.containsKey(key)) {
//         return _prefsCache[key]!;
//       }
      
//       // Try SharedPreferences
//       final value = PreferencesService.prefs.getBool(key) ?? false;
//       _prefsCache[key] = value; // Cache the value
//       return value;
      
//     } catch (e) {
//       _logNavigation('Error getting preference $key: $e');
//       return false; // Safe default
//     }
//   }

//   // Helper method to validate if a route exists
//   bool _isValidRoute(String route) {
//     try {
//       // Check if route exists in the route tree
//       final routeExists = Get.routeTree.routes.any((r) => r.name == route);
      
//       // Also check common valid routes
//       final validRoutes = [
//         '/splash', '/home', '/login', '/onboarding',
//         AppRoutes.splash, AppRoutes.home, AppRoutes.loginScreen, AppRoutes.onboarding
//       ];
      
//       return routeExists || validRoutes.contains(route) || route == '/';
//     } catch (e) {
//       _logNavigation('Error validating route $route: $e');
//       return false; // Assume invalid if we can't validate
//     }
//   }

//   // Helper method to log navigation events
//   static void _logNavigation(String message) {
//     final logEntry = '## (GeneralMiddleware) ${DateTime.now().toIso8601String().substring(11, 19)}: $message';
//     print(logEntry);
    
//     // Maintain a limited log for debugging
//     _navigationLog.add(logEntry);
//     if (_navigationLog.length > _maxLogEntries) {
//       _navigationLog.removeAt(0);
//     }
//   }

//   // Helper method to build error page
//   Widget _buildErrorPage(String error) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.red),
//             SizedBox(height: 16),
//             Text('Navigation Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text('Something went wrong', style: TextStyle(fontSize: 14)),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => Get.offAllNamed(fallbackRoute),
//               child: Text('Go to Safe Page'),
//             ),
//             if (error.isNotEmpty) ...[
//               SizedBox(height: 16),
//               Text('Error: $error', style: TextStyle(fontSize: 10, color: Colors.grey)),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // Method to preload preferences into the cache
//   static Future<void> preloadPreferences(List<String> keys) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       for (var key in keys) {
//         _prefsCache[key] = prefs.getBool(key) ?? false;
//       }
//       _logNavigation('Preloaded preferences: $_prefsCache');
//     } catch (e) {
//       _logNavigation('Error preloading preferences: $e');
//     }
//   }

//   // Method to clear cache if needed
//   static void clearPreferencesCache() {
//     _prefsCache.clear();
//     _logNavigation('Preferences cache cleared');
//   }

//   // Method to get navigation log for debugging
//   static List<String> getNavigationLog() {
//     return List.from(_navigationLog);
//   }

//   // Method to clear navigation log
//   static void clearNavigationLog() {
//     _navigationLog.clear();
//     _logNavigation('Navigation log cleared');
//   }
// }

// /// Safe page wrapper to catch any runtime errors
// class _SafePageWrapper extends StatelessWidget {
//   final Widget child;

//   const _SafePageWrapper({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (context) {
//         try {
//           return child;
//         } catch (e) {
//           print('## SafePageWrapper: Runtime error: $e');
//           return Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.warning, size: 64, color: Colors.orange),
//                   SizedBox(height: 16),
//                   Text('Page Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 8),
//                   Text('This page encountered an error', style: TextStyle(fontSize: 14)),
//                   SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => Get.offAllNamed('/home'),
//                     child: Text('Go Home'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }