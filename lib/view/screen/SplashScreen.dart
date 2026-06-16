import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../controller/StartpageContrller.dart';
import '../../core/constant/imageassets.DART';
import '../../core/constant/routes.dart';
import '../../core/functions/CheckInternat.dart';
import '../../core/services/Services.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Startpagecontrller contrller = Get.put(Startpagecontrller());
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  final Myservices myServices = Get.find();

  bool animate = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    String? token = myServices.sharedPreferences?.getString("token");

    if (token != null && token.isNotEmpty) {
      try {
        await Future.microtask(() async {
          if (await checkInternet()) {
            await contrller.getUser();
          }
        }).timeout(const Duration(seconds: 15));
      } catch (e) {
        print("Timeout or no internet in SplashScreen: $e");
      }
    }

    _controller.forward();

    await Future.delayed(const Duration(seconds: 3));
    setState(() => animate = true);

    await Future.delayed(const Duration(milliseconds: 0));

    if (token != null && token.isNotEmpty) {
      String? experimentDateString =
          myServices.sharedPreferences?.getString("date_experiment");

      int status = myServices.sharedPreferences?.getInt("status") ?? 0;

      // الحالة 4 يدخل مباشرة
      if (status == 1) {
        Get.offAllNamed(Approutes.HomeScreen);

        return;
      }

      // الحالات 2 و 3 لازم تاريخ صالح
      if (status == 2 || status == 3) {
        if (experimentDateString != null && experimentDateString.isNotEmpty) {
          DateTime experimentDate = DateTime.parse(experimentDateString);

          DateTime now = DateTime.now();

          DateTime today = DateTime(now.year, now.month, now.day);

          DateTime expireDate = DateTime(
            experimentDate.year,
            experimentDate.month,
            experimentDate.day,
          );

          bool isValid = today.isBefore(expireDate);

          if (isValid) {
            Get.offAllNamed(Approutes.HomeScreen);
          } else {
            Get.offAllNamed(
              Approutes.Login,
            );
          }
        } else {
          Get.offAllNamed(
            Approutes.Login,
          );
        }

        return;
      }

      Get.offAllNamed(
        Approutes.Login,
      );
    } else {
      Get.offAllNamed(Approutes.Login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: animate ? 0.0 : 1.0,
            child: Container(color: Colors.white),
          ),
          Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  Appimageassets.logo,
                  height: 200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
