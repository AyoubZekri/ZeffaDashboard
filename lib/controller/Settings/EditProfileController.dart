import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/core/functions/handlingdatacontroller.dart';
import 'package:zeffa/core/functions/uploudfiler.dart';
import 'package:zeffa/controller/SiedBarController.dart';
import 'package:zeffa/core/services/Services.dart';
import 'package:zeffa/data/datasource/Remote/Auth/Userdata.dart';
import 'package:zeffa/core/functions/Snacpar.dart';

class EditProfileController extends GetxController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late TextEditingController username;
  late TextEditingController phone;
  late TextEditingController fieldPhone;
  late TextEditingController adresse;
  late TextEditingController hallname;

  File? profileImage;
  Statusrequest statusrequest = Statusrequest.none;
  Myservices myServices = Get.find();
  late Userdata userdata;

  String? get currentImagePath =>
      myServices.sharedPreferences!.getString("image");

  @override
  void onInit() {
    userdata = Userdata(Get.find());

    username = TextEditingController(
      text: myServices.sharedPreferences!.getString("username"),
    );
    phone = TextEditingController(
      text: myServices.sharedPreferences!.getString("numperPhone"),
    );
    fieldPhone = TextEditingController(
      text: myServices.sharedPreferences!.getString("fieldPhone") ?? "",
    );
    adresse = TextEditingController(
      text: myServices.sharedPreferences!.getString("adresse") ?? "",
    );
    hallname = TextEditingController(
      text: myServices.sharedPreferences!.getString("hallname"),
    );
    super.onInit();
  }

  void pickImage() async {
    // using fileuploadGallery(false) to pick image from gallery (false means not restricted to svg)
    File? pickedFile = await fileuploadGallery(false);
    if (pickedFile != null) {
      profileImage = pickedFile;
      update();
    }
  }

  void updateProfile() async {
    if (formstate.currentState!.validate()) {
      // 1. Save changes locally immediately (Optimistic local update)
      myServices.sharedPreferences!.setString("username", username.text);
      myServices.sharedPreferences!.setString("numperPhone", phone.text);
      myServices.sharedPreferences!.setString("fieldPhone", fieldPhone.text);
      myServices.sharedPreferences!.setString("adresse", adresse.text);
      myServices.sharedPreferences!.setString("hallname", hallname.text);

      if (profileImage != null) {
        try {
          String? oldImagePath = myServices.sharedPreferences!.getString(
            "image",
          );
          final directory = await getApplicationDocumentsDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final baseName = profileImage!.path.replaceAll(r'\', '/').split('/').last;
          final fileName = "${timestamp}_$baseName";
          final filePath = "${directory.path}/$fileName";
          File newFile = await profileImage!.copy(filePath);
          myServices.sharedPreferences!.setString("image", newFile.path);
          print("Sucssed saving local image");

          if (oldImagePath != null && oldImagePath != newFile.path) {
            File oldFile = File(oldImagePath);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
          }
        } catch (e) {
          print("Error saving local image: $e");
        }
      }

      if (Get.isRegistered<Siedbarcontroller>()) {
        Get.find<Siedbarcontroller>().loadProfileData();
      }

      statusrequest = Statusrequest.loadeng;
      update();

      var response = await userdata.updateuser(
        username.text,
        phone.text,
        adresse.text,
        hallname.text,
        fieldPhone.text,
        profileImage,
      );

      statusrequest = handlingData(response);
      if (Statusrequest.success == statusrequest) {
        if (response['status'] == 1 || response['status'] == "success") {
          Get.back();
        } else {
          showSnackbar(
            'خطأ'.tr,
            'حدث خطأ أثناء التحديث على الخادم'.tr,
            Colors.red,
          );
        }
      } else {
        showSnackbar(
          'تنبيه'.tr,
          'تم الحفظ محلياً، فشل المزامنة مع الخادم'.tr,
          Colors.orange,
        );
      }
      update();
    }
  }

  @override
  void dispose() {
    username.dispose();
    phone.dispose();
    fieldPhone.dispose();
    adresse.dispose();
    hallname.dispose();
    super.dispose();
  }
}
