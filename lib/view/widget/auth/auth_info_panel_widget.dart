import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/constant/Colorapp.dart';

class AuthInfoPanelWidget extends StatelessWidget {
  const AuthInfoPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.deepPurple,
        gradient: LinearGradient(
          colors: [
            Color(0xFF311B92),
            Color(0xFF512DA8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'app_name'.tr,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'info_subtitle'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 50),
            _buildFeatureItem(
              Icons.bar_chart_outlined,
              'feature_1_title'.tr,
              'feature_1_desc'.tr,
            ),
            const SizedBox(height: 30),
            _buildFeatureItem(
              Icons.verified_user_outlined,
              'feature_2_title'.tr,
              'feature_2_desc'.tr,
            ),
            const Spacer(),
            Text(
              'copyright'.tr,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

