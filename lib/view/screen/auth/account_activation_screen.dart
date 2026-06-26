import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/core/constant/routes.dart';

class AccountActivationScreen extends StatelessWidget {
  const AccountActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? AppColor.white : AppColor.deepPurple;
    Color subtitleColor = isDark ? AppColor.textSecondary : Colors.grey;

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
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                  onPressed: () => Get.offAllNamed(Approutes.Login),
                ),
              ),
              const Spacer(),
              // Main Card
              Container(
                width: 450,
                margin: const EdgeInsets.symmetric(horizontal: 25.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 40.0,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColor.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.deepPurple.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pending_actions_rounded,
                        size: 60,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'account_not_activated'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'account_not_activated_desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: subtitleColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed(Approutes.Login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'back_to_login'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
          ),
        ),
      ),
    );
  }
}
