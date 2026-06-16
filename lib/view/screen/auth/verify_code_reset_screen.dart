import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/auth/Forgetpassword/VeriFycodecontroller.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/core/constant/Colorapp.dart';

class VerifyCodeResetScreen extends StatelessWidget {
  const VerifyCodeResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? AppColor.white : AppColor.deepPurple;
    Color subtitleColor = isDark ? AppColor.textSecondary : Colors.grey;

    Get.put(VeriFyCodeControllerImp());

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
          child: GetBuilder<VeriFyCodeControllerImp>(
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Zeffa',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColor.deepPurple,
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'verify_email_title'.tr,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'verify_email_subtitle'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          controller.email ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColor.accentPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
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
                              controller.GoToresetPasswored(
                                verificationCode,
                                "resePassword",
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
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
                                  onPressed: () {}, // Handled by onSubmit above
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'didnt_receive_code'.tr,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                controller.reset(); // Send code again
                              },
                              child: Text(
                                'resend_code'.tr,
                                style: const TextStyle(
                                  color: AppColor.deepPurple,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                        Icon(
                          Icons.verified_user_outlined,
                          color: AppColor.primaryPurple.withValues(alpha: 0.5),
                          size: 30,
                        ),
                      ],
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
