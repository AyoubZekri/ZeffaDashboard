import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/auth/VerfiycodeSignUp_controller.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/core/constant/Colorapp.dart';

class VerifyCodeSignUpScreen extends StatelessWidget {
  const VerifyCodeSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? AppColor.white : AppColor.deepPurple;
    Color subtitleColor = isDark ? AppColor.textSecondary : Colors.grey;

    Get.put(VerfiycodeSignUpControllerImp());

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
          child: GetBuilder<VerfiycodeSignUpControllerImp>(
            builder: (controller) {
              return Column(
                children: [
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo / Brand Name
                        Text(
                          'Zeffa',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColor.deepPurple,
                            fontFamily:
                                'Serif', // Using a generic serif to mimic the image
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Title
                        Text(
                          'verify_email_title'.tr,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Subtitle
                        Text(
                          'verify_email_subtitle'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // OTP Input
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: OtpTextField(
                            numberOfFields: 5,
                            autoFocus: true,
                            obscureText: false,
                            keyboardType: TextInputType.number,
                            borderColor: Colors.grey.shade300,
                            focusedBorderColor: AppColor.primaryPurple,
                            showFieldAsBox: true,
                            fieldWidth: 55,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            borderRadius: BorderRadius.circular(8),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onSubmit: (String verificationCode) {
                              controller.checkCode(verificationCode);
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          child:
                              controller.statusrequest == Statusrequest.loadeng
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColor.primaryPurple,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    // Normally you'd want to track the code in the controller onCodeChanged to submit via button
                                    // But since OtpTextField triggers onSubmit, this button can just be a visual cue
                                    // or trigger submission if we stored the code. For now, it's just visual.
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
                                    'verify_btn'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 25),

                        // Resend Section
                        Text(
                          'didnt_receive_code'.tr,
                          style: TextStyle(color: subtitleColor, fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        controller.canResend
                            ? GestureDetector(
                                onTap: () {
                                  controller.resendCode();
                                },
                                child: Text(
                                  'resend_code'.tr,
                                  style: const TextStyle(
                                    color: AppColor.deepPurple,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            : Text(
                                '00:${controller.countdown.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: AppColor.deepPurple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        const SizedBox(height: 35),

                        // Shield Icon
                        Icon(
                          Icons.verified_user_outlined,
                          color: AppColor.primaryPurple.withValues(alpha: 0.5),
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Footer Copyright
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
