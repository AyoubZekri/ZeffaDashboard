import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/core/functions/handlingdatacontroller.dart';
import 'package:zeffa/core/functions/Snacpar.dart';
import 'package:zeffa/core/services/Services.dart';
import 'package:zeffa/data/datasource/Remote/Auth/Forgetpassword/resetpassword.dart';
import 'package:zeffa/data/datasource/Remote/Auth/Forgetpassword/checkemail.dart';
import 'package:zeffa/data/datasource/Remote/Auth/Forgetpassword/verifycode.dart';

enum PasswordDialogMode { edit, forgotPassword, verifyCode, resetPassword }

class SettingsPasswordController extends GetxController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late TextEditingController oldPassword;
  late TextEditingController newPassword;
  late TextEditingController confirmPassword;
  late TextEditingController verifyCode;

  PasswordDialogMode mode = PasswordDialogMode.edit;
  Statusrequest statusrequest = Statusrequest.none;
  
  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  late ResetpasswordData resetpasswordData;
  late Checkemaildata checkemaildata;
  late Verifycodedata verifyCodeData;
  Myservices myServices = Get.find();

  String? userEmail;

  @override
  void onInit() {
    oldPassword = TextEditingController();
    newPassword = TextEditingController();
    confirmPassword = TextEditingController();
    verifyCode = TextEditingController();

    resetpasswordData = ResetpasswordData(Get.find());
    checkemaildata = Checkemaildata(Get.find());
    verifyCodeData = Verifycodedata(Get.find());

    userEmail = myServices.sharedPreferences!.getString("email");
    super.onInit();
  }

  void toggleObscureOld() {
    obscureOld = !obscureOld;
    update();
  }

  void toggleObscureNew() {
    obscureNew = !obscureNew;
    update();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    update();
  }

  void changeMode(PasswordDialogMode newMode) {
    mode = newMode;
    formstate = GlobalKey<FormState>(); // reset form state for new view
    statusrequest = Statusrequest.none;
    update();
  }

  void updatePassword() async {
    if (newPassword.text != confirmPassword.text) {
      showSnackbar('تحذير'.tr, 'كلمة السر غير متطابقة'.tr, Colors.orange);
      return;
    }
    if (formstate.currentState!.validate()) {
      statusrequest = Statusrequest.loadeng;
      update();

      var response = await resetpasswordData.Resset(
        oldPassword.text,
        newPassword.text,
        confirmPassword.text,
      );

      statusrequest = handlingData(response);
      if (Statusrequest.success == statusrequest) {
        if (response["status"] == 1) {
          showSnackbar('نجاح'.tr, 'تمت إعادة تعيين كلمة السر بنجاح'.tr, Colors.green);
          Get.back(); // close dialog
        } else {
          showSnackbar('تحذير'.tr, 'حاول مرة أخرى'.tr, Colors.orange);
          statusrequest = Statusrequest.failure;
        }
      } else {
        showSnackbar('خطأ'.tr, 'حدث خطأ أثناء التحديث'.tr, Colors.red);
      }
      update();
    }
  }

  void sendForgotPasswordCode() async {
    if (userEmail == null || userEmail!.isEmpty) {
      showSnackbar('خطأ'.tr, 'بريد إلكتروني غير صالح'.tr, Colors.red);
      return;
    }

    statusrequest = Statusrequest.loadeng;
    update();

    var response = await checkemaildata.postdata(userEmail!);
    statusrequest = handlingData(response);

    if (Statusrequest.success == statusrequest) {
      if (response["status"] == 1) {
        showSnackbar('نجاح'.tr, 'تم إرسال الرمز'.tr, Colors.green);
        changeMode(PasswordDialogMode.verifyCode);
      } else {
        showSnackbar('تحذير'.tr, 'البريد الإلكتروني غير موجود'.tr, Colors.orange);
        statusrequest = Statusrequest.failure;
      }
    }
    update();
  }

  void verifyOtp() async {
    if (verifyCode.text.isEmpty) {
      showSnackbar('تحذير'.tr, 'هذا الحقل مطلوب'.tr, Colors.orange);
      return;
    }
    
    statusrequest = Statusrequest.loadeng;
    update();

    var response = await verifyCodeData.postdata(verifyCode.text, userEmail!);
    statusrequest = handlingData(response);

    if (Statusrequest.success == statusrequest) {
      if (response["status"] == 1) {
        changeMode(PasswordDialogMode.resetPassword);
      } else {
        showSnackbar('تحذير'.tr, 'الرمز غير صحيح'.tr, Colors.orange);
        statusrequest = Statusrequest.failure;
      }
    }
    update();
  }

  void resetPasswordForgot() async {
    if (newPassword.text != confirmPassword.text) {
      showSnackbar('تحذير'.tr, 'كلمة السر غير متطابقة'.tr, Colors.orange);
      return;
    }
    if (formstate.currentState!.validate()) {
      statusrequest = Statusrequest.loadeng;
      update();

      var response = await resetpasswordData.postdata(
        newPassword.text,
        confirmPassword.text,
        userEmail!,
      );

      statusrequest = handlingData(response);
      if (Statusrequest.success == statusrequest) {
        if (response["status"] == 1) {
          showSnackbar('نجاح'.tr, 'تمت إعادة تعيين كلمة السر بنجاح'.tr, Colors.green);
          Get.back(); // close dialog and return to start
        } else {
          showSnackbar('تحذير'.tr, 'حاول مرة أخرى'.tr, Colors.orange);
          statusrequest = Statusrequest.failure;
        }
      }
      update();
    }
  }

  @override
  void dispose() {
    oldPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    verifyCode.dispose();
    super.dispose();
  }
}
