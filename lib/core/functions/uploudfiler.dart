import 'dart:io';

import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

imageuploadcamera() async {
  final XFile? file = await ImagePicker().pickImage(
    source: ImageSource.camera,
    imageQuality: 90,
  );
  if (file != null) {
    return File(file.path);
  } else {
    return null;
  }
}

fileuploadGallery([isvg = true]) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: isvg
        ? ["svg", "SVG"]
        : ["png", "PNG", "jpg", "JPG", "jpeg", "gif"],
  );

  if (result != null) {
    return File(result.files.single.path!);
  } else {
    return null;
  }
}

showbottom(imageuploadcamera(), fileuploadGallery()) {
  Get.bottomSheet(
    backgroundColor: AppColor.white,
    Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "choose_image".tr,
                style: const TextStyle(
                  fontSize: 22,
                  color: AppColor.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            ListTile(
              onTap: () {
                imageuploadcamera();
                Get.back();
              },
              leading: const Icon(Icons.camera, size: 40),
              title: Text(
                "from_camera".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                fileuploadGallery();
                Get.back();
              },
              leading: const Icon(Icons.image, size: 40),
              title: Text(
                "from_gallery".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

showfile() {
  fileuploadGallery(false);
}

showBottomAddProductOrScanner(
  int catid,
  String uuid,
  void Function(int catid, String uuid) onAddProduct,
  VoidCallback onOpenScanner,
  VoidCallback onOpenScannerfile,
) {
  Get.bottomSheet(
    backgroundColor: AppColor.white,
    Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "choose_action".tr,
              style: const TextStyle(
                fontSize: 22,
                color: AppColor.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () {
                Get.back();
                onAddProduct(catid, uuid);
                // Future.delayed(Duration(milliseconds: 200), onAddProduct);
              },
              leading: const Icon(Icons.add_box_outlined, size: 40),
              title: Text(
                "add_product_manual".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.back();
                onOpenScanner();
                // Future.delayed(Duration(milliseconds: 200), onOpenScanner);
              },
              leading: const Icon(Icons.qr_code_scanner, size: 40),
              title: Text(
                "open_camera_scanner".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.back();
                onOpenScannerfile();
                // Future.delayed(Duration(milliseconds: 200), onOpenScanner);
              },
              leading: const Icon(Icons.upload_file, size: 40),
              title: Text(
                "choose_from_files".tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
