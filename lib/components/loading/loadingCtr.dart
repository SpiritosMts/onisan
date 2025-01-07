import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingService extends GetxService {
  var isLoading = false.obs;
  var message = ''.obs; // Observable variable for the loading message

  @override
  void onInit() {
    super.onInit();
    print("## ## onInit LoadingService");
  }

  @override
  void onClose() {
    print('## ## onClose LoadingService');
    super.onClose();
  }

  void show({String? loadingMessage}) {
    if (!isLoading.value && Get.context != null) {
      message.value = loadingMessage ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GlobalLoadingWidget.show(Get.context!, loadingMessage: message.value);
        isLoading.value = true;
      });
    } else {
      print("## Loading is already active or context is null");
    }
  }

  void hide() {
    if (isLoading.value) {
      print("## Hiding loading indicator");
      GlobalLoadingWidget.hide();
      isLoading.value = false;
      message.value = '';
    } else {
      print("## No active loading to hide");
    }
  }
}

class GlobalLoadingWidget {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, {String? loadingMessage}) {
    if (_currentOverlay != null) {
      print("## Overlay already exists, preventing duplicate.");
      return; // Prevent duplicate overlays
    }

    final overlay = Overlay.of(context);
    if (overlay == null) {
      debugPrint('## Overlay is not available.');
      return;
    }

    final overlayEntry = OverlayEntry(
      builder: (_) {
        return Stack(
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
        );
      },
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);
    //print("## Overlay inserted");
  }

  static void hide() {
    if (_currentOverlay != null) {
      //print("## Removing overlay");
      _currentOverlay?.remove();
      _currentOverlay = null;
    } else {
      //print("## No overlay to remove");
    }
  }
}
