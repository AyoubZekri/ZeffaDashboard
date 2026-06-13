import 'package:zeffa/core/functions/Snacpar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

validInput(String val, int max, int min, String type) {
  if (Type == 'username') {
    if (GetUtils.isUsername(val)) {
      return "not valid username";
    }
  }
  if (Type == 'Email') {
    if (GetUtils.isUsername(val)) {
      return "not valid Email";
    }
  }
  if (Type == 'phone') {
    if (GetUtils.isUsername(val)) {
      return "not valid phone".tr;
    }
  }
  if (val.isEmpty) {
    return "Can't be Empty".tr;
  }

  if (val.length > max) {
    return "${"Can't be larger than".tr} $max";
  }
  if (val.length < min) {
    return "${"Can't be less than".tr} $min";
  }
}

bool validInputsnak(String val, int min, int max, String type) {
  if (val.isEmpty) {
    showSnackbar("error".tr, "لا يمكن أن يكون الحقل فارغًا".tr, Colors.red);
    return false;
  }

  if (val.length > max) {
    showSnackbar(
      "error".tr,
      "${'لا يمكن أن يكون حقل'.tr} $type ${'أطول من'.tr} $max ${'حرف'.tr}",
      Colors.red,
    );
    return false;
  }

  if (val.length < min) {
    showSnackbar(
      "error".tr,
      "${'لا يمكن أن يكون حقل'.tr} $type ${'أقل من'.tr}  $min ${'حرف'.tr}",
      Colors.red,
    );
    return false;
  }

  if (type == 'username' && !GetUtils.isUsername(val)) {
    showSnackbar("error".tr, "اسم المستخدم غير صالح".tr, Colors.red);
    return false;
  }

  if (type == 'email' && !GetUtils.isEmail(val)) {
    showSnackbar("error".tr, "البريد الإلكتروني غير صالح".tr, Colors.red);
    return false;
  }

  if (type == 'phone' && !GetUtils.isPhoneNumber(val)) {
    showSnackbar("error".tr, "رقم الهاتف غير صالح".tr, Colors.red);
    return false;
  }

  return true;
}
