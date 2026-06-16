import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/core/constant/routes.dart';
import 'package:zeffa/core/functions/handlingdatacontroller.dart';
import 'package:zeffa/data/datasource/Remote/Auth/Forgetpassword/resetpassword.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/Snacpar.dart';

abstract class Resetpasswordcontroler extends GetxController {
  Resetpassword(String to);
  Resetpasswordsetting();
  GoToForgenPassword();
}

class ResetpasswordcontrolerImp extends Resetpasswordcontroler {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late TextEditingController Passwoed;
  late TextEditingController RePasswoed;
  late TextEditingController OldPassword;

  String? email;
  bool obscureText = true;
  bool obscureText2 = true;
  bool obscureText3 = true;

  showPassword() {
    obscureText = obscureText == true ? false : true;
    update();
  }

  showPasswored2() {
    obscureText2 = obscureText2 == true ? false : true;
    update();
  }

  showPasswored3() {
    obscureText3 = obscureText3 == true ? false : true;
    update();
  }

  ResetpasswordData resetpasswordData = ResetpasswordData(Get.find());
  Statusrequest statusrequest = Statusrequest.none;
  @override
  // ignore: non_constant_identifier_names
  Resetpassword(to) async {
    if (Passwoed.text != RePasswoed.text) {
      showSnackbar("warning".tr, "passwordNotMatch".tr, Colors.orange);
    }
    if (formstate.currentState!.validate()) {
      statusrequest = Statusrequest.loadeng;
      update();
      var response = await resetpasswordData.postdata(
        Passwoed.text,
        RePasswoed.text,
        email!,
      );
      if (response == Statusrequest.serverfailure) {
        showSnackbar("error".tr, "noInternet".tr, Colors.red);
      }

      print("==================================$response");

      statusrequest = handlingData(response);
      if (Statusrequest.success == statusrequest) {
        if (response["status"] == 1) {
          if (to == "Login") {
            Get.offNamed(Approutes.Login);
          } else {
            Get.offNamed(Approutes.HomeScreen);
            showSnackbar("success".tr, "passwordResetSuccess".tr, Colors.green);
          }
        } else {
          showSnackbar("warning".tr, "tryAgain".tr, Colors.orange);
          statusrequest = Statusrequest.failure;
        }
      }
      update();
    }
  }

  @override
  Resetpasswordsetting() async {
    if (Passwoed.text != RePasswoed.text) {
      showSnackbar("warning".tr, "passwordNotMatch".tr, Colors.orange);
    }
    if (formstate.currentState!.validate()) {
      statusrequest = Statusrequest.loadeng;
      update();
      var response = await resetpasswordData.Resset(
        OldPassword.text,
        Passwoed.text,
        RePasswoed.text,
      );
      if (response == Statusrequest.serverfailure) {
        showSnackbar("error".tr, "noInternet".tr, Colors.red);
      }

      print("==================================$response");

      statusrequest = handlingData(response);
      if (Statusrequest.success == statusrequest) {
        if (response["status"] == 1) {
          Get.offNamed(Approutes.HomeScreen);
        } else {
          showSnackbar("warning".tr, "tryAgain".tr, Colors.orange);
          statusrequest = Statusrequest.failure;
        }
      }
      update();
    }
  }

  @override
  GoToForgenPassword() {
    Get.offNamed(Approutes.forgenpasswordsetting);
  }

  @override
  void onInit() {
    if (Get.arguments != null) {
      email = Get.arguments['email'];
    }
    Passwoed = TextEditingController();
    RePasswoed = TextEditingController();
    OldPassword = TextEditingController();

    super.onInit();
  }

  @override
  void dispose() {
    Passwoed.dispose();
    RePasswoed.dispose();
    OldPassword.dispose();

    super.dispose();
  }
}
