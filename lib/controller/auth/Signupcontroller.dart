import 'package:zeffa/core/constant/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import '../../core/functions/handlingdatacontroller.dart';
import '../../data/datasource/Remote/Auth/Signup_Data.dart';

abstract class SignupController extends GetxController {
  SignUp();
  GoToSignIn();
}

class SignupControllerImp extends SignupController {
  SignupData signupData = SignupData(Get.find());
  late TextEditingController Email;
  late TextEditingController Password;
  late TextEditingController confermPassword;
  late TextEditingController Phone;
  late TextEditingController Username;
  late TextEditingController hallname;
  late TextEditingController Adresse;

  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  List data = [];
  Statusrequest statusrequest = Statusrequest.none;
  bool obscureText = true;
  bool obscureText2 = true;

  showPassword() {
    obscureText = obscureText == true ? false : true;
    update();
  }

  showPassword2() {
    obscureText2 = obscureText2 == true ? false : true;
    update();
  }

  @override
  SignUp() async {
    if (formstate.currentState!.validate()) {
      statusrequest = Statusrequest.loadeng;
      update();
      var response = await signupData.postdata(
        Username.text,
        Password.text,
        Email.text,
        Phone.text,
        confermPassword.text,
        hallname.text,
        Adresse.text,
      );
      if (response == Statusrequest.serverfailure) {
        showSnackbar("error".tr, "noInternet".tr, Colors.red);
      }
      statusrequest = handlingData(response);
      print("=============================== Controller $response ");
      if (Statusrequest.success == statusrequest) {
        if (response["status"] == 1) {
          Get.offNamed(
            Approutes.VerifiycodeSignUp,
            arguments: {"email": Email.text},
          );
        } else {
          showSnackbar("Warning".tr, "email_already_exists".tr, Colors.orange);
          statusrequest = Statusrequest.failure;
        }
      } else {
        showSnackbar("Warning".tr, "email_already_exists".tr, Colors.orange);
      }
      update();
    } else {
      print("Not valid");
    }
  }

  @override
  GoToSignIn() {
    Get.offNamed(Approutes.Login);
  }

  @override
  void onInit() {
    Email = TextEditingController();
    Password = TextEditingController();
    confermPassword = TextEditingController();

    Phone = TextEditingController();
    Username = TextEditingController();
    hallname = TextEditingController();
    Adresse = TextEditingController();

    super.onInit();
  }

  @override
  void dispose() {
    Email.dispose();
    Password.dispose();
    Password.dispose();
    Phone.dispose();
    Username.dispose();
    hallname.dispose();
    Adresse.dispose();

    super.dispose();
  }
}
