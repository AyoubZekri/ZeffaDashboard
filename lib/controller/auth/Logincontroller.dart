import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/core/constant/routes.dart';
import 'package:zeffa/core/functions/Snacpar.dart';
import 'package:zeffa/core/functions/handlingdatacontroller.dart';
import 'package:zeffa/core/services/Services.dart';
import 'package:zeffa/data/datasource/Remote/Auth/logen_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/datasource/Remote/Auth/Forgetpassword/checkemail.dart';

class Logincontroller extends GetxController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  late TextEditingController Email;
  late TextEditingController Password;
  bool issobscureText = true;
  showPassword() {
    issobscureText = issobscureText == true ? false : true;
    update();
  }

  Checkemaildata checkemaildata = Checkemaildata(Get.find());
  Myservices myServices = Get.find();
  LoginData logenData = LoginData(Get.find());
  List data = [];
  Statusrequest statusrequest = Statusrequest.none;

  Login() async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      statusrequest = Statusrequest.loadeng;
      update();
      // String? fcmToken = await FirebaseMessaging.instance.getToken();
      // print("FCM Token: $fcmToken");
      var response = await logenData.postdata(
        Password.text,
        Email.text,
        // fcmToken!,
      );
      if (response == Statusrequest.serverfailure) {
        showSnackbar("error".tr, "noInternet".tr, Colors.red);
      }
      statusrequest = handlingData(response);
      print("=============================== Controller $response ");
      if (statusrequest == Statusrequest.success) {
        if (response["status"] == 1) {
          if (response["data"]["user"]["user"]["role_id"] != null) {
            Get.offNamed(Approutes.mobileOnly);
            return;
          }
          print(response["data"]["user"]["token"]);
          myServices.sharedPreferences!.setInt(
            "id",
            response['data']["user"]["user"]['id'],
          );
          myServices.sharedPreferences!.setString(
            "email",
            response['data']["user"]["user"]['email'],
          );
          myServices.sharedPreferences!.setString(
            "username",
            response["data"]["user"]["user"]["username"],
          );
          myServices.sharedPreferences!.setString(
            "numperPhone",
            response["data"]["user"]["user"]["numperPhone"],
          );
          myServices.sharedPreferences!.setString(
            "hallname",
            response["data"]["user"]["user"]["hallname"],
          );
          myServices.sharedPreferences!.setInt(
            "user_notify_status",
            response["data"]["user"]["user"]["user_notify_status"],
          );
          if (response["data"]["user"]["user"]["adresse"] != null) {
            myServices.sharedPreferences!.setString(
              "adresse",
              response["data"]["user"]["user"]["adresse"],
            );
          }

          if (response["data"]["user"]["user"]["image"] != null) {
            myServices.sharedPreferences!.setString(
              "image",
              response["data"]["user"]["user"]["image"],
            );
          }

          myServices.sharedPreferences!.setInt(
            "status",
            response["data"]["user"]["user"]["status"],
          );
          if (response["data"]["user"]["user"]["date_experiment"] != null) {
            myServices.sharedPreferences!.setString(
              "date_experiment",
              response["data"]["user"]["user"]["date_experiment"],
            );
          }
          myServices.sharedPreferences!.setString(
            "token",
            response["data"]["user"]["token"],
          );
          myServices.sharedPreferences!.setString("step", "2");
          DateTime? experimentDate;

          final experimentDateStr =
              response["data"]["user"]["user"]["date_experiment"];

          if (experimentDateStr != null &&
              experimentDateStr.toString().isNotEmpty) {
            try {
              experimentDate = DateTime.parse(experimentDateStr);
            } catch (e) {
              experimentDate = null;
            }
          }

          final today = DateTime.now();
          final status = response['data']["user"]["user"]['status'];
          print("===========$status");

          if (status == 0) {
            print("===========ok1");

            Get.offNamed(
              Approutes.VerifiycodeSignUp,
              arguments: {"email": Email.text},
            );
            reset();
          } else if (status == 1) {
            print("===========ok2");
            Get.offNamed(Approutes.accountActivation);
          } else if (status == 4) {
            print("===========ok3");
            Get.offNamed(Approutes.HomeScreen, arguments: {"fromlogin": 1});
          } else if (status == 2 || status == 3) {
            print("===========ok4");
            if (experimentDate != null) {
              DateTime now = DateTime.now();
              bool isValid = now.isBefore(experimentDate);
              if (isValid) {
                Get.offNamed(Approutes.HomeScreen, arguments: {"fromlogin": 1});
              } else {
                Get.offNamed(Approutes.accountActivation);
              }
            } else {
              Get.offNamed(Approutes.accountActivation);
            }
          } else {
            print("===========ok5");
            showSnackbar("error".tr, "contact_admin".tr, Colors.red);
          }
        }
      } else {
        showSnackbar("Warning".tr, "email_password_wrong".tr, Colors.orange);
      }
      update();
    } else {
      print("Not valid");
    }
  }

  GoToSignUp() {
    Get.offNamed(Approutes.SignUp);
  }

  GoToForgenPassword() {
    Get.offNamed(Approutes.forgenPassword);
  }

  reset() async {
    statusrequest = Statusrequest.loadeng;
    update();
    var response = await checkemaildata.postdata(Email.text);
    statusrequest = handlingData(response);
    if (Statusrequest.success == statusrequest) {
      if (response["status"] == 1) {
        showSnackbar("success".tr, "code_sent".tr, Colors.green);
      } else {
        showSnackbar("Warning".tr, "email_not_found".tr, Colors.orange);

        statusrequest = Statusrequest.failure;
      }
    }
    update();
  }

  // getUser() async {
  //   statusrequest = Statusrequest.loadeng;
  //   update();
  //   var response = await logenData.getUser();
  //   print("==============================$response");
  //   statusrequest = handlingData(response);
  //   // if (statusrequest == Statusrequest.success) {
  //   //   if (response["status"] == 1) {
  //   //     final model = Categoris_Model.fromJson(response);
  //   //     Categoris = model.data?.catdata ?? [];
  //   //     if (Categoris.isEmpty) {
  //   //       statusrequest = Statusrequest.failure;
  //   //     }
  //   //   }
  //   // }

  //   update();
  // }

  @override
  void onInit() {
    // FirebaseMessaging.instance.getToken().then((value) {
    //   String? token = value;
    //   print("token:$token");
    // });

    Email = TextEditingController();
    Password = TextEditingController();
    // getUser();
    super.onInit();
  }

  @override
  void dispose() {
    Email.dispose();
    Password.dispose();
    super.dispose();
  }
}
