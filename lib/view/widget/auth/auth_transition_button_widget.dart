import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/constant/Colorapp.dart';

class AuthTransitionButtonWidget extends StatelessWidget {
  final bool isLogin;
  final VoidCallback toggleMode;

  const AuthTransitionButtonWidget({
    super.key,
    required this.isLogin,
    required this.toggleMode,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color subtitleColor = isDark ? AppColor.textSecondary : Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: toggleMode,
          child: Text(
            isLogin ? 'signup_title'.tr : 'login_here'.tr,
            style: const TextStyle(
              color: AppColor.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          isLogin ? 'no_account'.tr : 'have_account'.tr,
          style: TextStyle(color: subtitleColor, fontSize: 16),
        ),
      ],
    );
  }
}

