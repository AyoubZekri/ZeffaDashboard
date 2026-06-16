import 'dart:io';

import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> alertExitApp() {
  Get.defaultDialog(
    backgroundColor: AppColor.white,
    title: "Alert".tr,
    titleStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColor.backgroundcolor,
    ),
    middleText: 'do_you_want_to_exit_app'.tr,
    onConfirm: () {
      exit(0);
    },
    onCancel: () {
      Get.back();
    },
    buttonColor: AppColor.backgroundcolor,
    confirmTextColor: AppColor.primarycolor,
    cancelTextColor: AppColor.backgroundcolor,
  );
  return Future.value(true);
}
