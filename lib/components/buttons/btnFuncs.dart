



import 'package:onisan/refs/refs.dart';

class ClickThrottler {
  static bool _isThrottled = false;

  static void execute(
      Function action, {
        int throttleDuration = 2000,
        bool showLoading = false,
        String? loadingMessage,
      }) async {
    if (_isThrottled) return;

    _isThrottled = true;

    //it must not contain routing get.to or smth it cz ldCtr to not hide


    try {
      if (showLoading) {
        ldCtr.show(loadingMessage:loadingMessage?? "loading.." );

        await Future.delayed(const Duration(milliseconds: 500), () async {});

      }
      await action();
    } finally {
      if (showLoading) {
        ldCtr.hide();
      }
      _isThrottled = false;
    }
  }
}
