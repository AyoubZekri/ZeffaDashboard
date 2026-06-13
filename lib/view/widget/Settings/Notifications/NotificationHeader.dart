import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/Colorapp.dart';
import '../../../../controller/NotificationsController.dart';
import '../../../../core/functions/dialogDelete.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.find<NotificationsController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                dialogDelete(
                  title: 'delete_confirm_btn'.tr,
                  content: '',
                  onConfirm: () {
                    controller.deleteAllNotifications();
                    Get.back();
                  },
                );
              },
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              label: Text("delete_all".tr, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => controller.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 20),
              label: Text("mark_all_read".tr, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                foregroundColor: theme.colorScheme.onSurface,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => controller.generateDummyNotification(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text("توليد إشعار تجريبي", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryPurple.withValues(alpha: 0.1),
                foregroundColor: AppColor.primaryPurple,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        // Removed System Alerts text and icon as requested
        const SizedBox(),
      ],
    );
  }
}
