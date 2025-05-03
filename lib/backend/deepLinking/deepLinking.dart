


import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:onisan/refs/refs.dart';
import 'package:onisan/routing/routingService.dart';
import 'package:share_plus/share_plus.dart';

import 'deepLinkConfig.dart';
Uri? pendingDeepLink;
DeepLinkConfig? get dlConfig => CustomVars.deepLinkConfig;

//call in main
void initDynamicLinks() async {

  try {
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink?.link != null) {
      savePendingLink(initialLink!.link);
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      Uri link = dynamicLinkData.link;
      savePendingLink(link);
    }).onError((error) {
      print('## ❌ Dynamic Link Failed: $error');
    });
  } catch (e) {
    print('## ❌ Error initializing dynamic links: $e');
  }
}

void savePendingLink(Uri deepLink) {
  print('## Received and saved Deep Link: $deepLink');
  pendingDeepLink = deepLink;
  if (dlConfig!.homeAccessible) {
    checkAndNavigatePendingLink();
  }
}

// open link // call in home initstate
void checkAndNavigatePendingLink() {
  if (pendingDeepLink != null) {
    final Uri deepLink = pendingDeepLink!;
    final path = deepLink.path;

    if (path.startsWith('/${dlConfig!.tagetName}')) { //
      final targetId = deepLink.queryParameters['id'];
      print('## Handle Deep Link Target id= <${targetId}>');
      if (targetId != null && targetId.isNotEmpty) {
        goTargetDetailsID(targetId);
      }
    }

    pendingDeepLink = null; // Clear the pending deep link
  } else {
    print('## pendingDeepLink is null: won’t navigate');
  }
}


// ******************* CREATE **********************

Future<String> createDynamicLink(String id) async {

  String dlPath = '${dlConfig!.appUrl}/${dlConfig!.tagetName}?id=$id';

  final DynamicLinkParameters parameters = DynamicLinkParameters(
    link: Uri.parse(dlPath),
    uriPrefix: dlConfig!.appUrl,
    androidParameters: AndroidParameters(
      packageName: dlConfig!.androidPackageName,
      minimumVersion: 1,
    ),
    iosParameters: IOSParameters(
      bundleId: dlConfig!.iosBundleId,
      appStoreId: dlConfig!.appStoreId,
    ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: dlConfig!.dynamicLinkTitle,
      description: dlConfig!.dynamicLinkDesc,
      imageUrl: Uri.parse(dlConfig!.appFeatureGraphic),
    ),
  );

  final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  print("##  Full link <${dlPath}>");
  print("## ✔ Short link  <${shortLink.shortUrl}>");

  return shortLink.shortUrl.toString();
}

/// ******************* SHARE **********************

void shareLink(String linkToShare) async {

  try {
    await Share.share('${dlConfig!.sharePreviewMsg.tr}: $linkToShare');
    print("## ✔️ link shared ($linkToShare)...");

  } catch (e) {
    // Handle error
    print("## ❌ Error sharing link: $e");
  }
}


///************* open web links ***********

