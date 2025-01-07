

import 'package:onisan/onisan.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openInBrowser(String url) async {
  try {
    if (!isValidUrl(url)) {
      print('## Invalid URL format: $url');
      return;
    }

    final Uri uri = Uri.parse(Uri.encodeFull(url));
    print('## Attempting to launch URI: $uri');

    // final canLaunch = await canLaunchUrl(uri);
    // print('## Can launch: $canLaunch');

    if (true) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      print('## Cannot launch URL: $url');
    }
  } catch (e) {
    animatedSnack(message: "Cannot launch url");
    print('## Error opening URL: $e');
  }
}


bool isValidUrl(String url) {
  final Uri? uri = Uri.tryParse(url);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
}
