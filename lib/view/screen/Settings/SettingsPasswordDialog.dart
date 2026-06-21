import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/Settings/SettingsPasswordController.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/view/widget/CustemTextField.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../../../core/functions/valiedinput.dart';

class SettingsPasswordDialog extends StatelessWidget {
  const SettingsPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Get.create(() => SettingsPasswordController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color textColor = isDark ? AppColor.white : AppColor.deepPurple;
    Color cardColor = isDark ? AppColor.surfaceDark : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 450,
        child: GetBuilder<SettingsPasswordController>(
          builder: (controller) {
            String title = 'تعديل كلمة السر'.tr;
            if (controller.mode == PasswordDialogMode.verifyCode) {
              title = 'إدخال الرمز'.tr;
            } else if (controller.mode == PasswordDialogMode.resetPassword) {
              title = 'كلمة سر جديدة'.tr;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 18, color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: controller.formstate,
                      child: _buildFormContent(controller),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormContent(SettingsPasswordController controller) {
    if (controller.mode == PasswordDialogMode.verifyCode) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تم إرسال رمز التحقق إلى بريدك الإلكتروني.'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
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
              fieldWidth: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              borderRadius: BorderRadius.circular(8),
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(Get.context!).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              onSubmit: (String verificationCode) {
                controller.verifyCode.text = verificationCode;
                controller.verifyOtp();
              },
            ),
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            controller,
            'التحقق من الرمز'.tr,
            controller.verifyOtp,
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'didnt_receive_code'.tr,
                style: TextStyle(
                  color: Theme.of(Get.context!).brightness == Brightness.dark
                      ? AppColor.textSecondary
                      : Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  controller.sendForgotPasswordCode();
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
        ],
      );
    } else if (controller.mode == PasswordDialogMode.resetPassword) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustemTextField(
              controller: controller.newPassword,
              label: 'كلمة السر الجديدة'.tr,
              hint: 'أدخل كلمة السر الجديدة'.tr,
              icon: Icons.lock_outline,
              obscureText: controller.obscureNew,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureNew
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.toggleObscureNew,
              ),
              validator: (val) {
                return validInput(val!, 100, 6, "password");
              },
            ),
          ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustemTextField(
              controller: controller.confirmPassword,
              label: 'تأكيد كلمة السر'.tr,
              hint: 'أعد إدخال كلمة السر'.tr,
              icon: Icons.lock_outline,
              obscureText: controller.obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.toggleObscureConfirm,
              ),
              validator: (val) {
                if (val != controller.newPassword.text) {
                  return 'كلمة السر غير متطابقة'.tr;
                }
                return validInput(val!, 100, 6, "password");
              },
            ),
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            controller,
            'إعادة تعيين'.tr,
            controller.resetPasswordForgot,
          ),
        ],
      );
    } else {
      // Edit mode (default)
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustemTextField(
              controller: controller.oldPassword,
              label: 'كلمة السر الحالية'.tr,
              hint: 'أدخل كلمة السر الحالية'.tr,
              icon: Icons.lock_outline,
              obscureText: controller.obscureOld,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureOld
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.toggleObscureOld,
              ),
              validator: (val) {
                return validInput(val!, 100, 6, "password");
              },
            ),
          ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustemTextField(
              controller: controller.newPassword,
              label: 'كلمة السر الجديدة'.tr,
              hint: 'أدخل كلمة السر الجديدة'.tr,
              icon: Icons.lock_outline,
              obscureText: controller.obscureNew,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureNew
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.toggleObscureNew,
              ),
              validator: (val) {
                return validInput(val!, 100, 6, "password");
              },
            ),
          ),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustemTextField(
              controller: controller.confirmPassword,
              label: 'تأكيد كلمة السر'.tr,
              hint: 'أعد إدخال كلمة السر'.tr,
              icon: Icons.lock_outline,
              obscureText: controller.obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.toggleObscureConfirm,
              ),
              validator: (val) {
                if (val != controller.newPassword.text) {
                  return 'كلمة السر غير متطابقة'.tr;
                }
                return validInput(val!, 100, 6, "password");
              },
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                if (controller.statusrequest != Statusrequest.loadeng) {
                  controller.sendForgotPasswordCode();
                }
              },
              child:
                  controller.statusrequest == Statusrequest.loadeng &&
                      controller.oldPassword.text.isEmpty
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'نسيت كلمة المرور؟'.tr,
                      style: TextStyle(
                        color: AppColor.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            controller,
            'حفظ التعديلات'.tr,
            controller.updatePassword,
          ),
        ],
      );
    }
  }

  Widget _buildActionButton(
    SettingsPasswordController controller,
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryPurple,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.statusrequest == Statusrequest.loadeng
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
