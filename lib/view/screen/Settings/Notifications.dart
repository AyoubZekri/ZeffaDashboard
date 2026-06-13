import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widget/Settings/Notifications/NotificationHeader.dart';
import '../../widget/Settings/Notifications/NotificationFilters.dart';
import '../../widget/Settings/Notifications/NotificationList.dart';

import '../../../controller/NotificationsController.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationsController());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const NotificationHeader(),
            const SizedBox(height: 32),
            const NotificationFilters(),
            const SizedBox(height: 32),
            const NotificationList(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
