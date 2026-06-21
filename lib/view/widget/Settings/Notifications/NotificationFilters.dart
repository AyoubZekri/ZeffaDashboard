import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/Colorapp.dart';
import '../../../../core/constant/AppTheme.dart';
import '../../../../controller/NotificationsController.dart';

class NotificationFilters extends StatelessWidget {
  const NotificationFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final controller = Get.find<NotificationsController>();
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : colors.inputFillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterChip(
              context,
              "all".tr,
              controller.currentFilter.value == 'all',
              () {
                controller.setFilter('all');
              },
            ),
            _buildFilterChip(
              context,
              "unread".tr,
              controller.currentFilter.value == 'unread',
              () {
                controller.setFilter('unread');
              },
            ),
            _buildFilterChip(
              context,
              "read_msg".tr,
              controller.currentFilter.value == 'read',
              () {
                controller.setFilter('read');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? (isDark ? AppColor.primaryPurple : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: (isDark ? AppColor.primaryPurple : Colors.black)
                        .withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? (isDark ? Colors.white : AppColor.primaryPurple)
                : colors.subtitleColor,
            fontWeight: active ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
