import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/auth/Signupcontroller.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/view/widget/CustemTextField.dart';

import '../../../core/functions/valiedinput.dart';

class SignupFormWidget extends StatelessWidget {
  const SignupFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? AppColor.white : AppColor.deepPurple;
    Color subtitleColor = isDark ? AppColor.textSecondary : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Center(
        child: SingleChildScrollView(
          child: GetBuilder<SignupControllerImp>(
            builder: (controller) {
              return Form(
                key: controller.formstate,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'signup_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'signup_subtitle'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: subtitleColor),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: CustemTextField(
                            label: 'hall_name_label'.tr,
                            hint: 'hall_name_hint'.tr,
                            icon: Icons.business_outlined,
                            controller: controller.hallname,
                            validator: (val) {
                              return validInput(val!, 100, 1, "username");
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: CustemTextField(
                            label: 'owner_name_label'.tr,
                            hint: 'owner_name_hint'.tr,
                            icon: Icons.person_outline,
                            controller: controller.Username,
                            validator: (val) {
                              return validInput(val!, 100, 1, "username");
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    CustemTextField(
                      label: 'phone_label'.tr,
                      hint: 'phone_hint'.tr,
                      icon: Icons.phone_android_outlined,
                      controller: controller.Phone,
                      validator: (val) {
                        return validInput(val!, 13, 10, "phone");
                      },
                    ),
                    const SizedBox(height: 15),
                    CustemTextField(
                      label: 'email_label'.tr,
                      hint: 'email_hint'.tr,
                      icon: Icons.email_outlined,
                      controller: controller.Email,
                      validator: (val) {
                        return validInput(val!, 100, 6, "Email");
                      },
                    ),
                    const SizedBox(height: 15),
                    CustemTextField(
                      label: 'hall_address_label'.tr,
                      hint: 'hall_address_hint'.tr,
                      icon: Icons.location_on_outlined,
                      controller: controller.Adresse,
                      validator: (val) {
                        return validInput(val!, 100, 1, "address");
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: CustemTextField(
                            label: 'confirm_password_label'.tr,
                            hint: 'password_hint'.tr,
                            icon: Icons.verified_user_outlined,
                            controller: controller.confermPassword,
                            obscureText: controller.obscureText2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureText2
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                controller.showPassword2();
                              },
                            ),
                            validator: (val) {
                              if (val != controller.Password.text)
                                return "password_mismatch".tr;
                              return validInput(val!, 100, 6, "password");
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: CustemTextField(
                            label: 'password_label'.tr,
                            hint: 'password_hint'.tr,
                            icon: Icons.lock_outline,
                            controller: controller.Password,
                            obscureText: controller.obscureText,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureText
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'agree_terms'.tr,
                          style: TextStyle(color: subtitleColor, fontSize: 12),
                        ),
                        Checkbox(
                          value: false,
                          onChanged: (val) {},
                          activeColor: AppColor.primaryPurple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        controller.SignUp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'signup_btn'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
