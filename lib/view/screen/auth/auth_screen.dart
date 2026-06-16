import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/auth/Logincontroller.dart';
import 'package:zeffa/controller/auth/Signupcontroller.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/view/widget/auth/auth_desktop_layout_widget.dart';
import 'package:zeffa/view/widget/auth/auth_mobile_layout_widget.dart';
import 'package:zeffa/view/widget/auth/auth_transition_button_widget.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsLogin;
  const AuthScreen({super.key, this.initialIsLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late bool isLogin;
  late AnimationController _animationController;
  late Animation<double> _animation;

  late Logincontroller loginController;
  late SignupControllerImp signupController;

  @override
  void initState() {
    super.initState();
    isLogin = widget.initialIsLogin;

    // Initialize GetX controllers
    loginController = Get.put(Logincontroller());
    signupController = Get.put(SignupControllerImp());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    if (!isLogin) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleMode() {
    if (isLogin) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    bool isMobile = screenSize.width < 800;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColor.backgroundDark
          : AppColor.backgroundLight,
      body: Stack(
        children: [
          Center(
            child: isMobile
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AuthMobileLayoutWidget(isLogin: isLogin),
                        AuthTransitionButtonWidget(
                          isLogin: isLogin,
                          toggleMode: toggleMode,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AuthDesktopLayoutWidget(
                          screenSize: screenSize,
                          animation: _animation,
                          isLogin: isLogin,
                        ),
                        const SizedBox(height: 25),
                        AuthTransitionButtonWidget(
                          isLogin: isLogin,
                          toggleMode: toggleMode,
                        ),
                      ],
                    ),
                  ),
          ),

          // Positioned(
          //   top: 40,
          //   left: Get.locale?.languageCode == 'ar' ? null : 20,
          //   right: Get.locale?.languageCode == 'ar' ? 20 : null,
          //   child: Row(
          //     children: [
          //       IconButton(
          //         icon: Icon(
          //           Theme.of(context).brightness == Brightness.dark
          //               ? Icons.light_mode
          //               : Icons.dark_mode,
          //           color: Theme.of(context).brightness == Brightness.dark
          //               ? Colors.white
          //               : Colors.black,
          //         ),
          //         onPressed: () {
          //           Get.changeThemeMode(
          //             Theme.of(context).brightness == Brightness.dark
          //                 ? ThemeMode.light
          //                 : ThemeMode.dark,
          //           );
          //         },
          //       ),
          //       IconButton(
          //         icon: Icon(
          //           Icons.language,
          //           color: Theme.of(context).brightness == Brightness.dark
          //               ? Colors.white
          //               : Colors.black,
          //         ),
          //         onPressed: () {
          //           if (Get.locale?.languageCode == 'ar') {
          //             Get.updateLocale(const Locale('en'));
          //           } else {
          //             Get.updateLocale(const Locale('ar'));
          //           }
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
