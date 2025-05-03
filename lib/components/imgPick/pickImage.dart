


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onisan/components/myTheme/themeManager.dart';

///CALL
// List<XFile>? images = await showImageDialogMulti(
// title: "Select an Image",
// selectMulti: false, // Single image selection
// );
Future<List<XFile>?> showImageDialog({
  String title = "Choose source",
  String galleryText = "Gallery",
  String cameraText = "Camera",
  IconData galleryIcon = Icons.image,
  IconData cameraIcon = Icons.camera,
  Color? iconColor,
  Color? bgColor,
  Color? textColor,
  bool selectMulti = false, // Parameter to choose multi-image or single-image selection
}) async {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? selectedImages;

  Future<void> _selectImages(ImageSource source) async {
    if (source == ImageSource.gallery) {
      if (selectMulti) {
        selectedImages = await _picker.pickMultiImage(); // Pick multiple images if selectMulti is true
      } else {
        XFile? image = await _picker.pickImage(source: source); // Single image if selectMulti is false
        if (image != null) {
          selectedImages = [image]; // Wrap single image in a list
        }
      }
    } else if (source == ImageSource.camera) {
      XFile? image = await _picker.pickImage(source: source); // Always single image for camera
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
          style: TextStyle(color: textColor ?? Cm.textCol2.withOpacity(0.9)),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
               Divider(height: 1,color: Cm.textHintCol2,),
              ListTile(
                onTap: () => _selectImages(ImageSource.gallery),
                title: Text(
                  galleryText.tr,
                  style: TextStyle(color: textColor ?? Cm.textCol2),
                ),
                leading: Icon(galleryIcon, color: iconColor ?? Cm.primaryColor),
              ),
              Divider(height: 1,color: Cm.textHintCol2,),
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

Future<List<XFile>?> pickImagesBottom({
  String title = "Choose source",
  String galleryText = "Gallery",
  String cameraText = "Camera",
  IconData galleryIcon = Icons.photo_library,
  IconData cameraIcon = Icons.camera_alt,
  Color? iconColor,
  Color? bgColor,
  Color? textColor,
  bool selectMulti = false, // Parameter to choose multi-image or single-image selection

}) async {
  final ImagePicker _picker = ImagePicker();
  print('## picking image ...');


  Completer<List<XFile>?> completer = Completer<List<XFile>?>();

  Future<void> selectImages(ImageSource source) async {
    List<XFile>? images;
    if (source == ImageSource.gallery) {
      if (selectMulti) {
        images = await _picker.pickMultiImage(); // Multi-image selection for gallery
      } else {
        XFile? image = await _picker.pickImage(source: source); // Single-image selection for gallery
        if (image != null) {
          images = [image];
        }
      }
    } else if (source == ImageSource.camera) {
      XFile? image = await _picker.pickImage(source: source); // Single-image selection for camera
      if (image != null) {
        images = [image];
      }
    }

    if (images != null && images.isNotEmpty) {
      print("## Images selected: ${images.map((img) => img.name).join(', ')}");
      Get.back(); // Dismiss the bottom sheet
      completer.complete(images); // Complete with the selected images
    } else {
      print("## No images selected");
      completer.complete(null); // Complete with null if no images are selected
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
              onTap: () => selectImages(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(cameraIcon, color: iconColor ?? Cm.primaryColor),
              title: Text(
                cameraText.tr,
                style: TextStyle(color: textColor ?? Cm.textCol2),
              ),
              onTap: () => selectImages(ImageSource.camera),
            ),
          ],
        ),
      ),
    ),
  );

  return await completer.future; // Wait for the user's selection
}
