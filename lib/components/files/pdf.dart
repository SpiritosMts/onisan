import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';
import 'package:onisan/onisan.dart';
import 'package:path_provider/path_provider.dart';

class PdfIconButton extends StatelessWidget {
  final String? pdfUrl;

  PdfIconButton({this.pdfUrl});

  Future<bool> _isPdfUrl(String? url) async {
    print('## Checking if URL points to a PDF: $url .....');

    if (url == null || url.isEmpty) return false;

    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        print('## Content-Type: $contentType');
        return contentType?.contains('application/pdf') ?? false;
      } else {
        print('## HTTP Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('## Error verifying PDF URL: $e');
      return false;
    }
  }




  Future<bool> _downloadAndOpenPdf(String url) async {
    try {
      // Get the directory to store the file
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/downloaded_file.pdf';

      // Check if the file already exists
      final file = File(filePath);
      if (await file.exists()) {
        print('## PDF already downloaded.');
        return true; // Indicate that navigation can occur
      }

      // If the file doesn't exist, download it
      print('## Downloading PDF...');
      final response = await http.get(Uri.parse(url));
      await file.writeAsBytes(response.bodyBytes);

      print('## PDF downloaded successfully.');
      return true; // Indicate that navigation can occur
    } catch (e) {
      print('## Error downloading or opening PDF: $e');
      animatedSnack(message: "Failed to load PDF");
      return false; // Indicate that navigation cannot occur
    }
  }


  ///************************************************************************
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isPdfUrl(pdfUrl),
      builder: (context, snapshot) {
        return SizedBox(
          width: 50, // Set a consistent width
          height: 50, // Set a consistent height
          child: Center(
            child: snapshot.connectionState == ConnectionState.waiting
                ? SizedBox(
              width: 20, // Adjust the diameter
              height: 20, // Adjust the diameter
              child: CircularProgressIndicator(
                strokeWidth: 2, // Adjust the thickness
                color: Cm.textHintCol2.withOpacity(0.6),
              ),
            )
                : (snapshot.data == true
                ? IconButton(
              icon: Icon(Iconsax.document_1_outline),
              tooltip: "View PFE Book",
              onPressed: () {
                if (pdfUrl == null) {
                            return;
                          }

                          ClickThrottler.execute(() async {
                  bool canNavigate = await _downloadAndOpenPdf(pdfUrl!);

                  if (canNavigate) {

                    ldCtr.hide();
                    final dir = await getTemporaryDirectory();
                    final filePath = '${dir.path}/downloaded_file.pdf';
                    Get.to(() => PdfViewer(filePath: filePath));
                  }
                },
                  throttleDuration: 3000,
                  showLoading: true,
                  loadingMessage: 'Loading PFE Book ...',
                );
              },
            )
                : SizedBox.shrink()), // Hide the icon if it's not a PDF
          ),
        );
      },

    );
  }
}

class PdfViewer extends StatefulWidget {
  final String filePath;

  PdfViewer({required this.filePath});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PFE Book')),
      body: PDFView(
        backgroundColor: Cm.bgCol,
        filePath: widget.filePath,
      ),
    );
  }
}