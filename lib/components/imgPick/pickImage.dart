


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onisan/components/myTheme/themeManager.dart';



Future<XFile?> showImageDialog({
  String title = "Choose source",
  String galleryText = "Gallery",
  String cameraText = "Camera",
  IconData galleryIcon = Icons.image,
  IconData cameraIcon = Icons.camera,
  Color? iconColor,
  Color? bgColor,
  Color? textColor,
}) async {
  final ImagePicker _picker = ImagePicker();
  print('## picking image ...');

  Future<void> _selectImage(ImageSource source) async {
    XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      print("## Image selected: ${image.name}");
    } else {
      print("## No image selected");
    }
    Get.back(result: image); ///+++ Pass the selected image RETURN
  }

  return await showDialog<XFile?>(
    context: Get.context!,
    builder: (_) {
      return AlertDialog(
        backgroundColor: bgColor ?? Cm.bgCol2,
        title: Text(
          title.tr,
          style: TextStyle(color: textColor ?? Cm.textCol2),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Divider(height: 1),
              ListTile(
                onTap: () => _selectImage(ImageSource.gallery),
                title: Text(
                  galleryText.tr,
                  style: TextStyle(color: textColor ?? Cm.textCol2),
                ),
                leading: Icon(galleryIcon, color: iconColor ?? Cm.primaryColor),
              ),
              const Divider(height: 1),
              ListTile(
                onTap: () => _selectImage(ImageSource.camera),
                title: Text(
                  cameraText.tr,
                  style: TextStyle(color: textColor ?? Cm.textCol2),
                ),
                leading: Icon(cameraIcon, color: iconColor ?? Cm.primaryColor),
              ),
            ],
          ),
        ),
      );
    },
  );
}
Future<List<XFile>?> showImageDialogMulti({
  String title = "Choose source",
  String galleryText = "Gallery",
  String cameraText = "Camera",
  IconData galleryIcon = Icons.image,
  IconData cameraIcon = Icons.camera,
  Color? iconColor,
  Color? bgColor,
  Color? textColor,
}) async {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? selectedImages;

  Future<void> _selectImages(ImageSource source) async {
    if (source == ImageSource.gallery) {
      selectedImages = await _picker.pickMultiImage(); // Pick multiple images
    } else if (source == ImageSource.camera) {
      XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        selectedImages = [image]; // Wrap single image in a list
      }
    }

    if (selectedImages != null && selectedImages!.isNotEmpty) {
      print("## Images selected: ${selectedImages!.map((img) => img.name).join(', ')}");
    } else {
      print("## No images selected");
    }

    Get.back(result: selectedImages); // Pass the selected images
  }

  return await showDialog<List<XFile>?>(
    context: Get.context!,
    builder: (_) {
      return AlertDialog(
        backgroundColor: bgColor ?? Cm.bgCol2,
        title: Text(
          title.tr,
          style: TextStyle(color: textColor ?? Cm.textCol2),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Divider(height: 1),
              ListTile(
                onTap: () => _selectImages(ImageSource.gallery),
                title: Text(
                  galleryText.tr,
                  style: TextStyle(color: textColor ?? Cm.textCol2),
                ),
                leading: Icon(galleryIcon, color: iconColor ?? Cm.primaryColor),
              ),
              const Divider(height: 1),
              ListTile(
                onTap: () => _selectImages(ImageSource.camera),
                title: Text(
                  cameraText.tr,
                  style: TextStyle(color: textColor ?? Cm.textCol2),
                ),
                leading: Icon(cameraIcon, color: iconColor ?? Cm.primaryColor),
              ),
            ],
          ),
        ),
      );
    },
  );
}


//*************************************************************************************************

Future<XFile?> pickImageBottom({
  String title = "Choose source",
  String galleryText = "Gallery",
  String cameraText = "Camera",
  IconData galleryIcon = Icons.photo_library,
  IconData cameraIcon = Icons.camera_alt,
  Color? iconColor,
  Color? bgColor,
  Color? textColor,
}) async {
  final ImagePicker _picker = ImagePicker();
  print('## picking image ...');

  Completer<XFile?> completer = Completer<XFile?>();

  Future<void> selectImage(ImageSource source) async {
    XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      print("## Image selected: ${image.name}");
      Get.back(); // Dismiss the bottom sheet
      completer.complete(image); ///+++ Pass the selected image RETURN
    } else {
      print("## No image selected");
    }

  }

  showModalBottomSheet<void>(
    context: Get.context!,
    builder: (context) => SafeArea(
      child: Container(
        color: bgColor ?? Cm.bgCol2,
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(galleryIcon, color: iconColor ?? Cm.primaryColor),
              title: Text(
                galleryText.tr,
                style: TextStyle(color: textColor ?? Cm.textCol2),
              ),
              onTap: () => selectImage(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(cameraIcon, color: iconColor ?? Cm.primaryColor),
              title: Text(
                cameraText.tr,
                style: TextStyle(color: textColor ?? Cm.textCol2),
              ),
              onTap: () => selectImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    ),
  );

  return await completer.future; // Wait for the user's selection
}
