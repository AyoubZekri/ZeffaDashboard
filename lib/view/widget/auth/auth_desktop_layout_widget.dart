import 'package:flutter/material.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/view/widget/auth/auth_forms_widget.dart';
import 'package:zeffa/view/widget/auth/auth_info_panel_widget.dart';

class AuthDesktopLayoutWidget extends StatelessWidget {
  final Size screenSize;
  final Animation<double> animation;
  final bool isLogin;

  const AuthDesktopLayoutWidget({
    super.key,
    required this.screenSize,
    required this.animation,
    required this.isLogin,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color containerColor = isDark ? AppColor.surfaceDark : Colors.white;

    double width = 900;
    double height = 550;

    if (screenSize.width < width + 40) width = screenSize.width - 40;
    if (screenSize.height < height + 40) height = screenSize.height - 40;

    double halfWidth = width / 2;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                double leftOffset = halfWidth * (1 - animation.value);
                return Positioned(
                  left: leftOffset,
                  top: 0,
                  bottom: 0,
                  width: halfWidth,
                  child: Container(
                    color: containerColor,
                    child: AuthFormsWidget(isLogin: isLogin),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                double leftOffset = halfWidth * animation.value;
                return Positioned(
                  left: leftOffset,
                  top: 0,
                  bottom: 0,
                  width: halfWidth,
                  child: const AuthInfoPanelWidget(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

