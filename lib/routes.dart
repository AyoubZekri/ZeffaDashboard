import 'package:get/get.dart';

import 'view/screen/SideBar.dart';
import 'view/screen/SplashScreen.dart';
import 'view/screen/auth/auth_screen.dart';
import 'view/screen/auth/verify_code_signup_screen.dart';
import 'view/screen/auth/forget_password_screen.dart';
import 'view/screen/auth/verify_code_reset_screen.dart';
import 'view/screen/auth/reset_password_screen.dart';
import 'view/screen/auth/account_activation_screen.dart';
import 'view/screen/auth/mobile_only_screen.dart';
import 'core/constant/routes.dart';List<GetPage<dynamic>> routes = [
  GetPage(name: "/", page: () => const SplashScreen()),
  GetPage(name: Approutes.HomeScreen, page: () => const MainLayout()),
  GetPage(
    name: Approutes.Login,
    page: () => const AuthScreen(initialIsLogin: true),
  ),
  GetPage(
    name: Approutes.SignUp,
    page: () => const AuthScreen(initialIsLogin: false),
  ),
  GetPage(
    name: Approutes.VerifiycodeSignUp,
    page: () => const VerifyCodeSignUpScreen(),
  ),
  GetPage(
    name: Approutes.forgenPassword,
    page: () => const ForgetPasswordScreen(),
  ),
  GetPage(
    name: Approutes.VerFiyCode,
    page: () => const VerifyCodeResetScreen(),
  ),
  GetPage(
    name: Approutes.resePassword,
    page: () => const ResetPasswordScreen(),
  ),
  GetPage(
    name: Approutes.accountActivation,
    page: () => const AccountActivationScreen(),
  ),
  GetPage(
    name: Approutes.mobileOnly,
    page: () => const MobileOnlyScreen(),
  ),
];
