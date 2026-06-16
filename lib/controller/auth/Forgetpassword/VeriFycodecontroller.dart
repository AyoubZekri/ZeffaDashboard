import 'package:zeffa/core/constant/routes.dart';
import 'package:zeffa/core/functions/handlingdatacontroller.dart';
import 'package:zeffa/data/datasource/Remote/Auth/Forgetpassword/verifycode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/Statusrequest.dart';
import '../../../core/functions/Snacpar.dart';
import '../../../data/datasource/Remote/Auth/Forgetpassword/checkemail.dart';

abstract class VeriFyCodeController extends GetxController {
  CheckCode();
  GoToresetPasswored(String verifycode, String to);
}

class VeriFyCodeControllerImp extends VeriFyCodeController {
  String? email;

  Verifycodedata verifycodedata = Verifycodedata(Get.find());
  Checkemaildata checkemaildata = Checkemaildata(Get.find());
  Statusrequest statusrequest = Statusrequest.none;
  @override
  CheckCode() {}

  @override
  // ignore: non_constant_identifier_names
  GoToresetPasswored(verifycode, to) async {
    statusrequest = Statusrequest.loadeng;
    update();
    var response = await verifycodedata.postdata(verifycode, email!);
    if (response == Statusrequest.serverfailure) {
      showSnackbar("error".tr, "noInternet".tr, Colors.red);
    }

    print("===================================$response");
    print("===================================$verifycode");
    print("===================================$email");
    statusrequest = handlingData(response);
    if (Statusrequest.success == statusrequest && response["status"] == 1) {
      if (to == "resePassword") {
        Get.offNamed(Approutes.resePassword, arguments: {'email': email});
      } else {
        Get.offNamed(
          Approutes.resetpasswordsetting,
          arguments: {'email': email},
        );
      }
    } else {
      showSnackbar("warning".tr, "verifyCodeIncorrect".tr, Colors.orange);
      statusrequest = Statusrequest.failure;
    }

    update();
  }

  reset() async {
    statusrequest = Statusrequest.loadeng;
    update();
    var response = await checkemaildata.postdata(email!);
    if (response == Statusrequest.serverfailure) {
      showSnackbar("error".tr, "noInternet".tr, Colors.red);
    }

    statusrequest = handlingData(response);
    if (Statusrequest.success == statusrequest && response["status"] == 1) {
      showSnackbar("success".tr, "code_sent".tr, Colors.green);
    } else {
      showSnackbar("warning".tr, "Email Not Found".tr, Colors.orange);
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  @override
  void onInit() {
    email = Get.arguments['email'];
    super.onInit();
  }
}
