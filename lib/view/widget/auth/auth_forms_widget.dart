import 'package:flutter/material.dart';
import 'package:zeffa/view/widget/auth/login_form_widget.dart';
import 'package:zeffa/view/widget/auth/signup_form_widget.dart';

class AuthFormsWidget extends StatelessWidget {
  final bool isLogin;

  const AuthFormsWidget({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const LoginFormWidget(),
      secondChild: const SignupFormWidget(),
      crossFadeState: isLogin
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 600),
      layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              key: bottomChildKey,
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: bottomChild,
            ),
            Positioned(
              key: topChildKey,
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: topChild,
            ),
          ],
        );
      },
    );
  }
}
