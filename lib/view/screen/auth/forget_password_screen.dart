import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/auth/Forgetpassword/Forgen_Controller.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/view/widget/CustemTextField.dart';

import '../../../core/functions/valiedinput.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? AppColor.white : AppColor.deepPurple;
    Color subtitleColor = isDark ? AppColor.textSecondary : Colors.grey;

    Get.put(ForgenControllerImp());

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColor.backgroundDark, const Color(0xFF1A1A2E)]
                : [Colors.white, const Color(0xFFF3E8FF)],
          ),
        ),
        child: SafeArea(
          child: GetBuilder<ForgenControllerImp>(
            builder: (controller) {
              return Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const Spacer(),
                  // Main Card
                  Container(
                    width: 400,
                    margin: const EdgeInsets.symmetric(horizontal: 25.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 40.0,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColor.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.deepPurple.withValues(alpha: 0.05),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: controller.formstate,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Zeffa',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColor.deepPurple,
                              
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'forget_password_title'.tr,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'forget_password_subtitle'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 30),
                          CustemTextField(
                            label: 'email_label'.tr,
                            hint: 'email_hint'.tr,
                            icon: Icons.email_outlined,
                            controller: controller.email,
                            validator: (val) {
                              return validInput(val!, 100, 5, "Email");
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: controller.statusrequest == Statusrequest.loadeng
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColor.primaryPurple,
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      controller.CheckEmail("VerFiyCode");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primaryPurple,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'send_code_btn'.tr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 25),
                          Icon(
                            Icons.lock_reset_outlined,
                            color: AppColor.primaryPurple.withValues(alpha: 0.5),
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'copyright_text'.tr,
                      style: TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
