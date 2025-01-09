import 'package:flutter/widgets.dart';

// AppLifecycleService().initialize(
// resumedCallback: () => print("## General app resumed"),
// inactiveCallback: () => print("## General app inactive"),
// pausedCallback: () => print("## General app paused"),
// );


class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService._privateConstructor();

  static final AppLifecycleService _instance = AppLifecycleService._privateConstructor();

  factory AppLifecycleService() {
    return _instance;
  }

  // Callback functions for lifecycle states
  Function()? onResumed;
  Function()? onInactive;
  Function()? onPaused;
  Function()? onDetached;
  Function()? onHidden;

  void initialize({
    Function()? resumedCallback,
    Function()? inactiveCallback,
    Function()? pausedCallback,
    Function()? detachedCallback,
    Function()? hiddenCallback,
  }) {
    onResumed = resumedCallback;
    onInactive = inactiveCallback;
    onPaused = pausedCallback;
    onDetached = detachedCallback;
    onHidden = hiddenCallback;

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('## AppLifecycleState ##: resumed');
        onResumed?.call();
        break;

      case AppLifecycleState.inactive:
        print('## AppLifecycleState ##: inactive');
        onInactive?.call();
        break;

      case AppLifecycleState.paused:
        print('## AppLifecycleState ##: paused');
        onPaused?.call();
        break;

      case AppLifecycleState.detached:
        print('## AppLifecycleState ##: detached');
        onDetached?.call();
        break;

      case AppLifecycleState.hidden:
        print('## AppLifecycleState ##: hidden');
        onHidden?.call();
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
