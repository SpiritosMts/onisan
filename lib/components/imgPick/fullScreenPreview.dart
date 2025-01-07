import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

enum ImageSourceType {
  local,
  network,
  asset,
}

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;  // Can be a local path, network URL, or asset path
  final ImageSourceType imageSourceType;  // Specify the source type (local, network, asset)

  const FullScreenImageViewer({
    Key? key,
    required this.imagePath,
    this.imageSourceType = ImageSourceType.network,  // Default is network image
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: PhotoView(
              imageProvider: _getImageProvider(),  // Use the appropriate image provider
              backgroundDecoration: BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2.0,
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Get.back();  // Close the full-screen viewer
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to determine the correct image provider
  ImageProvider<Object> _getImageProvider() {
    switch (imageSourceType) {
      case ImageSourceType.local:
        return FileImage(File(imagePath)) as ImageProvider<Object>;
      case ImageSourceType.asset:
        return AssetImage(imagePath);  // Asset image
      case ImageSourceType.network:
      default:
        return NetworkImage(imagePath);  // Network image
    }
  }
}
