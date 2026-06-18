import 'package:zeffa/core/functions/Snacpar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

validInput(String val, int max, int min, String type, {bool? empty = false}) {
  if (val.isEmpty && empty!) {
    return null;
  }
  if (type == 'username') {
    if (!GetUtils.isUsername(val)) {
      return "not valid username".tr;
    }
  }
  if ((type == 'email' || type == 'Email')) {
    if (!GetUtils.isEmail(val)) {
      return "not valid Email".tr;
    }
  }
  if (type == 'phone') {
    if (!GetUtils.isPhoneNumber(val)) {
      return "not valid phone".tr;
    }
  }
  if (type == 'number') {
    if (!GetUtils.isNum(val)) {
      return "not valid number".tr;
    }
  }
  if (type == 'integer') {
    if (int.tryParse(val) == null) {
      return "not valid integer".tr;
    }
  }
  if (type == 'decimal') {
    if (!GetUtils.isNum(val)) {
      return "not valid decimal".tr;
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
    showSnackbar("error".tr, 'field_cannot_be_empty'.tr, Colors.red);
    return false;
  }

  if (val.length > max) {
    showSnackbar("error".tr, 'field_max_length_error'.tr, Colors.red);
    return false;
  }

  if (val.length < min) {
    showSnackbar("error".tr, 'field_min_length_error'.tr, Colors.red);
    return false;
  }

  if (type == 'username' && !GetUtils.isUsername(val)) {
    showSnackbar("error".tr, 'invalid_username'.tr, Colors.red);
    return false;
  }

  if (type == 'email' && !GetUtils.isEmail(val)) {
    showSnackbar("error".tr, 'invalid_email_address'.tr, Colors.red);
    return false;
  }

  if (type == 'phone' && !GetUtils.isPhoneNumber(val)) {
    showSnackbar("error".tr, 'invalid_phone_number'.tr, Colors.red);
    return false;
  }

  return true;
}
