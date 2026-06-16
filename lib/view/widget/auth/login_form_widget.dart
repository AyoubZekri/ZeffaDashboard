import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/auth/Logincontroller.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/view/widget/CustemTextField.dart';

import '../../../core/functions/valiedinput.dart';

class LoginFormWidget extends StatelessWidget {
  const LoginFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? AppColor.white : AppColor.deepPurple;
    Color subtitleColor = isDark ? AppColor.textSecondary : Colors.grey;
    Color labelColor = isDark ? AppColor.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Center(
        child: SingleChildScrollView(
          child: GetBuilder<Logincontroller>(
            builder: (controller) {
              return Form(
                key: controller.formstate,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'login_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'login_subtitle'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: subtitleColor),
                    ),
                    const SizedBox(height: 40),
                    CustemTextField(
                      label: 'email_label'.tr,
                      hint: 'email_hint'.tr,
                      icon: Icons.email_outlined,
                      controller: controller.Email,
                      validator: (val) {
                        return validInput(val!, 100, 10, "Email");
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.GoToForgenPassword();
                          },
                          child: Text(
                            'forgot_password'.tr,
                            style: const TextStyle(
                              color: AppColor.accentPurple,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, right: 5),
                          child: Text(
                            'password_label'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: labelColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    CustemTextField(
                      hint: 'password_hint'.tr,
                      icon: Icons.lock_outline,
                      controller: controller.Password,
                      obscureText: controller.issobscureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.issobscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          controller.showPassword();
                        },
                      ),
                      validator: (val) {
                        return validInput(val!, 100, 6, "password");
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'remember_me'.tr,
                          style: TextStyle(color: subtitleColor),
                        ),
                        Checkbox(
                          value: false,
                          onChanged: (val) {},
                          activeColor: AppColor.primaryPurple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        controller.Login();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'login_btn'.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
