import 'package:flutter/material.dart';
import 'package:zeffa/core/constant/Colorapp.dart';

ThemeData themeEn = ThemeData(
  fontFamily: "Cairo",
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: AppColor.primarycolor,
      fontWeight: FontWeight.bold,
      fontFamily: "Cairo",
      fontSize: 20, // كان 25
    ),
    iconTheme: IconThemeData(color: AppColor.primarycolor),
    backgroundColor: AppColor.backgroundcolor,
    elevation: 4,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16, // كان 20
      color: AppColor.black,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20, // كان 26
      color: AppColor.black,
    ),
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16, // كان 20
      color: Color.fromARGB(255, 244, 111, 54),
    ),
    bodyMedium: TextStyle(
      height: 1.6,
      color: Color.fromARGB(255, 97, 97, 97),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      height: 1.6,
      color: AppColor.grey,
      fontWeight: FontWeight.w500,
      fontSize: 13, // كان 24
    ),
  ),
);

ThemeData themeAr = ThemeData(
  fontFamily: "Cairo",
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: AppColor.primarycolor,
      fontWeight: FontWeight.bold,
      fontFamily: "Cairo",
      fontSize: 20, // كان 25
    ),
    iconTheme: IconThemeData(color: AppColor.primarycolor),
    backgroundColor: AppColor.backgroundcolor,
    elevation: 4,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: AppColor.black,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: AppColor.black,
    ),
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Color.fromARGB(255, 244, 111, 54),
    ),
    bodyMedium: TextStyle(
      height: 1.6,
      color: Color.fromARGB(255, 97, 97, 97),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      height: 1.6,
      color: AppColor.grey,
      fontWeight: FontWeight.w500,
      fontSize: 13,
    ),
  ),
);
