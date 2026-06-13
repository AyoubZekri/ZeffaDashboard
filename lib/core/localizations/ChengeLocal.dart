import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/constant/Themdata.dart';
import 'package:zeffa/core/services/Services.dart';

class LocalController extends GetxController {
  Locale? language;
  Myservices myservices = Get.put(Myservices());
  ThemeData themeData = themeAr;
  changeLang(String langcode) {
    Locale locale = Locale(langcode);
    myservices.sharedPreferences!.setString("lang", langcode);
    themeData = langcode == "ar" ? themeAr : themeEn;
    Get.updateLocale(locale);
  }

  @override
  void onInit() {
    String? sharedPreflang = myservices.sharedPreferences!.getString("lang");
    if (sharedPreflang == "ar") {
      language = const Locale("ar");
    } else if (sharedPreflang == "en") {
      language = const Locale("en");
    } else {
      language = const Locale("ar");
    }
    super.onInit();
  }
}
