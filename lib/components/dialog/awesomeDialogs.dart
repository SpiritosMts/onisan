

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:onisan/components/myTheme/themeManager.dart';
import 'package:sizer/sizer.dart';

showVerifyConnexion(){
  AwesomeDialog(
    dialogBackgroundColor: Cm.bgCol2,
    context: Get.context!,

    autoDismiss: true,
    dismissOnTouchOutside: true,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.info,
    btnOkColor: Colors.blueAccent,
    // btnOkColor: yellowColHex

    //showCloseIcon: true,
    padding: EdgeInsets.symmetric(vertical: 15.0),

    title: 'Failed to Connect'.tr,
    desc: 'please verify network'.tr,

    btnOkOnPress: () {

    },
    btnOkText: 'Ok'.tr,
    onDismissCallback: (type) {
      print('Dialog Dissmiss from callback $type');
    },
    //btnOkIcon: Icons.check_circle,

  ).show();
}

showLoading({required String text}) {

  return AwesomeDialog(
    dialogBackgroundColor: Cm.bgCol2,

    dismissOnBackKeyPress: true,
    //change later to false
    autoDismiss: true,
    customHeader: Transform.scale(
      scale: .7,
      child:  LoadingIndicator(
        indicatorType: Indicator.ballClipRotate,
        colors: [Cm.primaryColor],
        strokeWidth: 10,
      ),
    ),

    context: Get.context!,
    dismissOnTouchOutside: false,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.noHeader,

    //padding: EdgeInsets.all(8),
    descTextStyle: GoogleFonts.almarai(
      textStyle: const TextStyle(

          height: 1.5
      ),
    ),
    title: text,
    desc: 'Please wait'.tr,
  ).show();
}

showFailed({String? faiText}) {
  return AwesomeDialog(
      dialogBackgroundColor: Cm.bgCol2,

      autoDismiss: true,
      context: Get.context!,
      dismissOnTouchOutside: false,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      dialogType: DialogType.error,
      //showCloseIcon: true,
      title: 'Failure'.tr,
      btnOkText: 'Ok'.tr,
      descTextStyle: GoogleFonts.almarai(
        height: 1.8,
        textStyle: const TextStyle(fontSize: 14),
      ),
      desc: faiText,
      btnOkOnPress: () {},
      btnOkColor: Colors.red,
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog Dissmiss from callback $type');
      }).show();
  ;
}

showSuccess({String? sucText, Function()? btnOkPress}) {
  return AwesomeDialog(
    dialogBackgroundColor: Cm.bgCol2,

    autoDismiss: true,
    context: Get.context!,
    dismissOnBackKeyPress: false,
    headerAnimationLoop: false,
    dismissOnTouchOutside: false,
    animType: AnimType.leftSlide,
    dialogType: DialogType.success,
    //showCloseIcon: true,
    //title: 'Success'.tr,

    descTextStyle: GoogleFonts.almarai(
      height: 1.8,
      textStyle: const TextStyle(fontSize: 14),
    ),
    desc: sucText,
    btnOkText: 'Ok'.tr,

    btnOkOnPress: () {
      btnOkPress!();
    },
    // onDissmissCallback: (type) {
    //   debugPrint('## Dialog Dissmiss from callback $type');
    // },
    //btnOkIcon: Icons.check_circle,
  ).show();
}
showWarning({String? txt, Function()? btnOkPress}) {
  return AwesomeDialog(
    dialogBackgroundColor: Cm.bgCol2,

    autoDismiss: true,
    context: Get.context!,
    dismissOnBackKeyPress: false,
    headerAnimationLoop: false,
    dismissOnTouchOutside: false,

    animType: AnimType.scale,
    dialogType: DialogType.warning,
    //showCloseIcon: true,
    //title: 'Success'.tr,

    descTextStyle: GoogleFonts.almarai(
      height: 1.8,
      textStyle: const TextStyle(fontSize: 14),
    ),
    btnOkColor: Color(0xFFFEB800),
    desc: txt,
    btnOkText: 'Ok'.tr,

    btnOkOnPress: () {
      btnOkPress!();
    },
    // onDissmissCallback: (type) {
    //   debugPrint('## Dialog Dissmiss from callback $type');
    // },
    //btnOkIcon: Icons.check_circle,
  ).show();
}


Future<bool> showNoHeader({String? txt,String? btnOkText='delete',Color btnOkColor=Colors.red,IconData? icon=Icons.delete}) async {
  bool shouldDelete = false;

  await AwesomeDialog(
    context: Get.context!,
    dialogBackgroundColor: Cm.bgCol2,
    autoDismiss: true,
    isDense: true,
    dismissOnTouchOutside: true,
    showCloseIcon: false,
    headerAnimationLoop: false,
    dialogType: DialogType.noHeader,
    animType: AnimType.scale,
    btnCancelIcon: Icons.close,
    btnCancelColor: Cm.secondaryColor,
    btnOkIcon: icon ?? Icons.check,
    btnOkColor: btnOkColor,
    btnOk: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Cm.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(85),
        ),
      ),
      onPressed: () {
        Get.back();

        shouldDelete = true;

      },
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 15,vertical: 3),
        child: Text(
            btnOkText!.tr,
          style: TextStyle(fontSize: 18,color: Cm.textColPr),
        ),
      ),
    ),
    btnCancel: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Cm.secondaryColor.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(85),
        ),
      ),
      onPressed: () {
        Get.back();
        shouldDelete = false;

      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 3),
        child: Text(
          'cancel'.tr,
          style: TextStyle(fontSize: 18,color: Cm.textColSe),
        ),
      ),
    ),
    buttonsTextStyle: TextStyle(fontSize: 17.sp),
    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
    // texts
    title: 'Verification'.tr,
    desc: txt ?? 'Are you sure you want to delete this image'.tr,





  ).show();
  return shouldDelete;
}
