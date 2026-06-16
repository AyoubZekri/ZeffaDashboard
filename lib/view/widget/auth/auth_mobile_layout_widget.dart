import 'package:flutter/material.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/view/widget/auth/auth_forms_widget.dart';
import 'package:zeffa/view/widget/auth/auth_info_panel_widget.dart';

class AuthMobileLayoutWidget extends StatelessWidget {
  final bool isLogin;

  const AuthMobileLayoutWidget({
    super.key,
    required this.isLogin,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color containerColor = isDark ? AppColor.surfaceDark : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: const AuthInfoPanelWidget(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: AuthFormsWidget(isLogin: isLogin),
          ),
        ],
      ),
    );
  }
}

