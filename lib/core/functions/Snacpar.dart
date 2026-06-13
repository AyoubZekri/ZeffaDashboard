import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:get/get.dart';

Flushbar? _currentFlushbar;

void showSnackbar(String titleKey, String messageKey, Color color) {
  final context = Get.context;
  if (context == null) return;

  // إزالة أي Flushbar حالية
  _currentFlushbar?.dismiss();
  _currentFlushbar = null;

  IconData iconData;
  if (color == Colors.green) {
    iconData = Icons.check_circle;
  } else if (color == Colors.red) {
    iconData = Icons.error;
  } else if (color == Colors.orange) {
    iconData = Icons.warning;
  } else {
    iconData = Icons.info;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _currentFlushbar = Flushbar(
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: color,
      icon: Icon(iconData, color: Colors.white),
      titleText: Text(
        titleKey.tr,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        messageKey.tr,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      isDismissible: true,
    )..show(context).then((_) {
        _currentFlushbar = null; // إعادة تعيين بعد الإغلاق
      });
  });
}
