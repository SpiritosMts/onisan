import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
class DeepLinkConfig {
  final String appUrl;
  final String tagetName; // New field for the post path
  final String dynamicLinkTitle;
  final String dynamicLinkDesc;
  final String sharePreviewMsg;
  final String androidPackageName;
  final String iosBundleId;
  final String appStoreId;
  final String appFeatureGraphic;
  final String failedToOpenMsg;
  bool homeAccessible;

  DeepLinkConfig({
    required this.appUrl,
    required this.tagetName, // Initialize postPath
    required this.dynamicLinkTitle,
    required this.dynamicLinkDesc,
    required this.failedToOpenMsg,
    required this.sharePreviewMsg,
    required this.androidPackageName,
    required this.iosBundleId,
    required this.appStoreId,
    required this.appFeatureGraphic,
    required this.homeAccessible,
  });



  // Method to convert DeepLinkConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'appUrl': appUrl,
      'tagetName': tagetName,
      'dynamicLinkTitle': dynamicLinkTitle,
      'dynamicLinkDesc': dynamicLinkDesc,
      'sharePreviewMsg': sharePreviewMsg,
      'androidPackageName': androidPackageName,
      'iosBundleId': iosBundleId,
      'appStoreId': appStoreId,
      'appFeatureGraphic': appFeatureGraphic,
      'failedToOpenMsg': failedToOpenMsg,
      'homeAccessible': homeAccessible,
    };
  }
}
