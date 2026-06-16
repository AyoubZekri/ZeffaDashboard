import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/core/constant/routes.dart';
import 'package:zeffa/core/functions/handlingdatacontroller.dart';
import 'package:zeffa/core/functions/Snacpar.dart';
import 'package:zeffa/data/datasource/Remote/Auth/verfiycode_signup_data.dart';
import 'package:zeffa/core/services/Services.dart';

abstract class VerfiycodeSignUpController extends GetxController {
  checkCode(String verifycode);
  resendCode();
  goToSuccessSignUp();
}

class VerfiycodeSignUpControllerImp extends VerfiycodeSignUpController {
  String? email;
  VerfiycodeSignUpData verfiycodeSignUpData = VerfiycodeSignUpData(Get.find());
  Myservices myServices = Get.find();
  Statusrequest statusrequest = Statusrequest.none;

  Timer? _timer;
  int countdown = 60;
  bool canResend = false;

  @override
  void onInit() {
    email = Get.arguments['email'];
    startTimer();
    super.onInit();
  }

  void startTimer() {
    countdown = 60;
    canResend = false;
    update();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        countdown--;
        update();
      } else {
        canResend = true;
        _timer?.cancel();
        update();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  checkCode(String verifycode) async {
    statusrequest = Statusrequest.loadeng;
    update();

    var response = await verfiycodeSignUpData.postdata(email!, verifycode);

    if (response == Statusrequest.serverfailure) {
      showSnackbar("error".tr, "noInternet".tr, Colors.red);
      statusrequest = Statusrequest.serverfailure;
      update();
      return;
    }

    statusrequest = handlingData(response);

    if (Statusrequest.success == statusrequest) {
      if (response['status'] == 1) {
        // Save token and login user if the API returns token, otherwise just show success
        if (response['data'] != null && response['data']['token'] != null) {
          myServices.sharedPreferences!.setString(
            "token",
            response['data']['token'],
          );
          myServices.sharedPreferences!.setInt("status", 1);
        }
        showSnackbar("success".tr, "success_verification".tr, Colors.green);
        goToSuccessSignUp();
      } else {
        showSnackbar("error".tr, "verify_error".tr, Colors.red);
        statusrequest = Statusrequest.failure;
      }
    } else {
      showSnackbar("error".tr, "verify_error".tr, Colors.red);
    }
    update();
  }

  @override
  resendCode() async {
    if (!canResend) return;

    statusrequest = Statusrequest.loadeng;
    update();

    var response = await verfiycodeSignUpData.resendCode(email!);

    statusrequest = handlingData(response);

    if (Statusrequest.success == statusrequest) {
      if (response['status'] == 1) {
        showSnackbar("success".tr, "code_resent".tr, Colors.green);
        startTimer();
      } else {
        showSnackbar("error".tr, "try_again_later".tr, Colors.orange);
        statusrequest = Statusrequest.failure;
      }
    } else {
      showSnackbar("error".tr, "noInternet".tr, Colors.red);
    }
    update();
  }

  @override
  goToSuccessSignUp() {
    Get.offAllNamed(Approutes.HomeScreen, arguments: {"fromlogin": 1});
  }
}
