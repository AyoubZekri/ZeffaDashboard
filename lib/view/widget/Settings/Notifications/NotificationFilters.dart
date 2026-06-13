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

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.inputFillColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Obx(() => Row(
            children: [
              _buildFilterChip(context, "all".tr, controller.currentFilter.value == 'all', () {
                controller.setFilter('all');
              }),
              _buildFilterChip(context, "unread".tr, controller.currentFilter.value == 'unread', () {
                controller.setFilter('unread');
              }),
            ],
          )),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool active, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [BoxShadow(color: colors.shadowColor, blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? (isDark ? Colors.white : AppColor.primaryPurple) : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
