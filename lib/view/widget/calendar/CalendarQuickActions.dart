import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class CalendarQuickActions extends StatelessWidget {
  final VoidCallback? onWeekendEdit;
  final VoidCallback? onBlockDate;
  final VoidCallback? onDownloadReport;

  const CalendarQuickActions({
    Key? key,
    this.onWeekendEdit,
    this.onBlockDate,
    this.onDownloadReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_actions'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 20),
          _buildActionItem(
            icon: Icons.edit_calendar_rounded,
            title: 'edit_weekend_prices'.tr,
            onTap: onWeekendEdit ?? () {
              Get.snackbar(
                'quick_actions'.tr,
                'edit_weekend_prices'.tr,
                backgroundColor: AppColor.primaryPurple.withOpacity(0.1),
                colorText: AppColor.primaryPurple,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            icon: Icons.block_flipped,
            title: 'block_specific_date'.tr,
            onTap: onBlockDate ?? () {
              Get.snackbar(
                'quick_actions'.tr,
                'block_specific_date'.tr,
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                colorText: Colors.redAccent,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            icon: Icons.cloud_download_outlined,
            title: 'download_occupancy_report'.tr,
            onTap: onDownloadReport ?? () {
              Get.snackbar(
                'quick_actions'.tr,
                'download_occupancy_report'.tr,
                backgroundColor: Colors.green.withOpacity(0.1),
                colorText: Colors.green.shade800,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColor.primaryPurple,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
