import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:onisan/components/myTheme/themeManager.dart';

enum LoadingType { overlay, dialog }

class LoadingService extends GetxService {
  var isLoading = false.obs;
  var message = ''.obs;
  var currentType = LoadingType.overlay.obs;

  // Store current awesome dialog reference
  AwesomeDialog? _currentAwesomeDialog;

  @override
  void onInit() {
    super.onInit();
    print("## ## onInit LoadingService");
  }

  @override
  void onClose() {
    hide(); // Clean up any active loading
    print('## ## onClose LoadingService');
    super.onClose();
  }

  /// Show overlay loading (original method)
  void showOverlay({String? loadingMessage}) {
    try {
      if (!isLoading.value && Get.context != null) {
        message.value = loadingMessage ?? '';
        currentType.value = LoadingType.overlay;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          GlobalLoadingWidget.show(Get.context!, loadingMessage: message.value);
          isLoading.value = true;
        });
      } else {
        print("## Overlay loading is already active or context is null");
      }
    } catch (e) {
      print("## Error showing overlay loading: $e");
      // Don't throw, just log the error
    }
  }

  /// Show awesome dialog loading
  void showDialog({
    String? loadingMessage,
    Color? primaryColor,
    Color? backgroundColor,
    bool dismissible = false,
  }) {
    try {
      // Prevent multiple dialogs
      if (isLoading.value || Get.isDialogOpen == true) {
        print("## Dialog loading is already active or another dialog is open");
        return;
      }
      
      if (Get.context != null) {
        message.value = loadingMessage ?? 'Loading...'.tr;
        currentType.value = LoadingType.dialog;

        _currentAwesomeDialog = AwesomeDialog(
          context: Get.context!,
          dialogType: DialogType.noHeader,
          dialogBackgroundColor: backgroundColor ?? Cm.bgCol2,
          dismissOnBackKeyPress: dismissible,
          dismissOnTouchOutside: dismissible,
          autoDismiss: true, // Important: let AwesomeDialog handle auto dismiss
          animType: AnimType.scale,
          headerAnimationLoop: false,
          customHeader: Transform.scale(
            scale: 0.7,
            child: LoadingIndicator(
              indicatorType: Indicator.ballClipRotate,
              colors: [primaryColor ?? Cm.primaryColor],
              strokeWidth: 10,
            ),
          ),
          title: message.value,
          desc: 'Please wait'.tr,
          descTextStyle: GoogleFonts.almarai(
            textStyle: const TextStyle(height: 1.5),
          ),
          onDismissCallback: (DismissType type) {
            print('## Awesome dialog dismissed: $type');
            _resetDialogState();
          },
        );

        // Show the dialog and track the result
        _currentAwesomeDialog!.show().then((result) {
          print("## Dialog show completed with result: $result");
          // Ensure state is reset when dialog completes
          if (isLoading.value) {
            _resetDialogState();
          }
        }).catchError((error) {
          print("## Error showing dialog: $error");
          _resetDialogState();
        });
        
        isLoading.value = true;
      } else {
        print("## Context is null, cannot show dialog");
      }
    } catch (e) {
      print("## Error showing dialog loading: $e");
      // Reset state on error
      _resetDialogState();
    }
  }

  /// Helper method to reset dialog state
  void _resetDialogState() {
    isLoading.value = false;
    message.value = '';
    _currentAwesomeDialog = null;
  }

  /// Generic show method (defaults to overlay)
  void show({
    String? loadingMessage,
    LoadingType type = LoadingType.overlay,
    Color? primaryColor,
    Color? backgroundColor,
    bool dismissible = false,
  }) {
    switch (type) {
      case LoadingType.overlay:
        showOverlay(loadingMessage: loadingMessage);
        break;
      case LoadingType.dialog:
        showDialog(
          loadingMessage: loadingMessage,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          dismissible: dismissible,
        );
        break;
    }
  }

  /// Hide any active loading
  void hide() {
    try {
      if (isLoading.value) {
        print("## Hiding loading indicator - Type: ${currentType.value}");

        switch (currentType.value) {
          case LoadingType.overlay:
            GlobalLoadingWidget.hide();
            break;
          case LoadingType.dialog:
            _hideAwesomeDialog();
            break;
        }

        isLoading.value = false;
        message.value = '';
      } else {
        print("## No active loading to hide");
      }
    } catch (e) {
      print("## Error hiding loading: $e");
      // Force reset state even on error
      isLoading.value = false;
      message.value = '';
      _currentAwesomeDialog = null;
    }
  }

  /// Enhanced method to hide AwesomeDialog with multiple fallback strategies
  void _hideAwesomeDialog() {
    try {
      if (_currentAwesomeDialog != null) {
        print("## Attempting to dismiss AwesomeDialog");
        
        // Strategy 1: Try normal dismiss first
        try {
          _currentAwesomeDialog!.dismiss();
        } catch (e) {
          print("## Error in normal dismiss: $e");
        }
        
        // Strategy 2: Force close using Navigator.pop if dialog is still open
        Future.delayed(const Duration(milliseconds: 50), () {
          if (Get.isDialogOpen == true && isLoading.value) {
            print("## Force closing dialog with Navigator.pop");
            try {
              Navigator.of(Get.context!, rootNavigator: false).pop();
            } catch (e) {
              print("## Error with Navigator.pop: $e");
              // Try with root navigator as fallback
              try {
                Navigator.of(Get.context!, rootNavigator: true).pop();
              } catch (e2) {
                print("## Error with root Navigator.pop: $e2");
              }
            }
          }
          
          // Ensure state is reset regardless
          _resetDialogState();
        });
        
        // Reset reference immediately
        _currentAwesomeDialog = null;
      }
    } catch (e) {
      print("## Error hiding AwesomeDialog: $e");
      // Force cleanup
      _resetDialogState();
      
      // Emergency close any open dialogs
      if (Get.isDialogOpen == true) {
        try {
          Navigator.of(Get.context!, rootNavigator: false).pop();
        } catch (e2) {
          try {
            Navigator.of(Get.context!, rootNavigator: true).pop();
          } catch (e3) {
            print("## All Navigator.pop attempts failed: $e3");
          }
        }
      }
    }
  }

  /// Force hide any active loading (emergency method)
  void forceHide() {
    try {
      print("## Force hiding all loading indicators");
      
      // Force hide overlay
      GlobalLoadingWidget.hide();
      
      // Force hide awesome dialog
      if (_currentAwesomeDialog != null) {
        try {
          _currentAwesomeDialog!.dismiss();
        } catch (e) {
          print("## Error dismissing dialog: $e");
        }
      }
      
      // Aggressively close any open dialogs using Navigator
      int attempts = 0;
      while (Get.isDialogOpen == true && attempts < 5) {
        try {
          print("## Force closing dialog attempt ${attempts + 1}");
          Navigator.of(Get.context!, rootNavigator: false).pop();
          attempts++;
          
          // Small delay to let the pop complete
          Future.delayed(const Duration(milliseconds: 10));
        } catch (e) {
          print("## Error closing dialog with Navigator.pop: $e");
          try {
            Navigator.of(Get.context!, rootNavigator: true).pop();
          } catch (e2) {
            print("## Error with root Navigator.pop: $e2");
          }
          break;
        }
      }
      
      // Final cleanup - use GetX back as last resort
      if (Get.isDialogOpen == true) {
        try {
          Get.back();
        } catch (e) {
          print("## Error with Get.back(): $e");
        }
      }
      
      // Reset all state
      _resetDialogState();
      
    } catch (e) {
      print("## Error in forceHide: $e");
      // Final cleanup
      _resetDialogState();
    }
  }

  /// Check if loading is currently active
  bool get isActive => isLoading.value;

  /// Get current loading message
  String get currentMessage => message.value;

  /// Get current loading type
  LoadingType get getType => currentType.value;
}

// Enhanced GlobalLoadingWidget with better error handling
class GlobalLoadingWidget {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, {String? loadingMessage}) {
    try {
      if (_currentOverlay != null) {
        print("## Overlay already exists, preventing duplicate.");
        return;
      }

      final overlay = Overlay.of(context);
      if (overlay == null) {
        debugPrint('## Overlay is not available.');
        return;
      }

      final overlayEntry = OverlayEntry(
        builder: (_) {
          return Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: LoadingIndicator(
                            indicatorType: Indicator.ballTrianglePath,
                            colors: [Colors.white.withOpacity(.8)],
                            strokeWidth: 2,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        if (loadingMessage != null && loadingMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              loadingMessage,
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      _currentOverlay = overlayEntry;
      overlay.insert(overlayEntry);
    } catch (e) {
      print("## Error showing overlay: $e");
      // Clean up on error
      _currentOverlay = null;
    }
  }

  static void hide() {
    try {
      if (_currentOverlay != null) {
        _currentOverlay?.remove();
        _currentOverlay = null;
      }
    } catch (e) {
      print("## Error hiding overlay: $e");
      // Force cleanup even on error
      _currentOverlay = null;
    }
  }
}

// Global instance for easy access
LoadingService get ldCtr => Get.find<LoadingService>();

// Extension for easier usage
extension LoadingExtension on GetInterface {
  LoadingService get loading => Get.find<LoadingService>();
}

// Usage Examples:
/*

// 1. Using the global instance
ldCtr.show(
  loadingMessage: 'Updating profile...'.tr,
  type: LoadingType.dialog,
);

// Later hide it
ldCtr.hide();

// Emergency hide (if dialog won't dismiss normally)
ldCtr.forceHide();

// 2. Using GetX extension
Get.loading.showDialog(loadingMessage: 'Processing payment...'.tr);
Get.loading.hide();

// 3. In your pricing page:
onPressed: () async {
  HapticFeedback.mediumImpact();
  if (selectedPlan == 0) {
    Get.back();
  } else {
    print('Upgrade to VIP - ${isYearly ? "Yearly" : "Monthly"}');
    
    // Show loading
    Get.loading.showDialog(loadingMessage: 'Upgrading to VIP'.tr);
    
    try {
      await updateFieldInFirestore(
        collRef(CustomVars.usersCollName),
        authCtr.cUser.value.id,
        'subscriptionPlan',
        'vip',
        onSuccess: () async {
          // Hide loading immediately
          Get.loading.hide();
          
          // Show success message
          showSnack('Congratulations! You are now a VIP member'.tr, type: 'succ');
          
          // Navigate back
          Get.back();
          
          // Refresh user data in background
          try {
            await authCtr.getUserData(withCheckVerification: false);
          } catch (e) {
            print('Background user data refresh error: $e');
          }
        },
        onError: (error) {
          Get.loading.hide();
          showSnack('Error upgrading to VIP. Please try again'.tr);
          print('Detailed error: $error');
        },
      );
    } catch (e) {
      Get.loading.hide();
      showSnack('Error upgrading to VIP. Please try again'.tr);
      print('Error upgrading to VIP: $e');
    }
  }
},

// 4. Register the service in your main.dart:
void main() {
  Get.put(LoadingService(), permanent: true);
  runApp(MyApp());
}

*/
