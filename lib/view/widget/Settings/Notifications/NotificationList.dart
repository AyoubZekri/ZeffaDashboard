import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/Colorapp.dart';
import '../../../../controller/NotificationsController.dart';
import './NotificationCard.dart';
import 'package:intl/intl.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Obx(() {
      if (controller.filteredNotifications.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              children: [
                Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "لا توجد إشعارات",
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredNotifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final notif = controller.filteredNotifications[index];

          // Determine Icon and Color based on type
          IconData icon = Icons.notifications_outlined;
          Color iconColor = AppColor.primaryPurple;

          switch (notif.type) {
            case 'sale':
              icon = Icons.shopping_cart_outlined;
              iconColor = Colors.green;
              break;
            case 'stock':
              icon = Icons.warning_amber_rounded;
              iconColor = Colors.orange;
              break;
            case 'system':
              icon = Icons.settings_outlined;
              iconColor = Colors.blue;
              break;
            case 'security':
              icon = Icons.security_outlined;
              iconColor = Colors.indigo;
              break;
            case 'reservation':
              icon = Icons.event_available_outlined;
              iconColor = AppColor.primaryPurple;
              break;
          }

          String formattedDate = notif.createdAt ?? '';
          if (notif.createdAt != null) {
            try {
              final date = DateTime.parse(notif.createdAt!);
              formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
            } catch (e) {
              // Ignore
            }
          }

          return InkWell(
            onTap: () {
              if (!notif.isRead) {
                controller.markAsRead(notif.uuid!);
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: NotificationCard(
              title: notif.title ?? '',
              desc: notif.content ?? '',
              time: formattedDate,
              icon: icon,
              iconColor: iconColor,
              isRead: notif.isRead,
              onDelete: () => controller.deleteNotification(notif.uuid!),
            ),
          );
        },
      );
    });
  }
}
