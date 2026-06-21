import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../controller/CalendarController.dart';

class CalendarGuide extends StatelessWidget {
  const CalendarGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';

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
            'calendar_guide'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          _buildGuideItem(
            color: AppColor.primaryPurple.withOpacity(0.08),
            borderColor: AppColor.primaryPurple,
            tag: "04",
            title: 'friday_special_days'.tr,
            subtitle: 'friday_special_days_sub'.tr,
            textColor: AppColor.primaryPurple,
          ),
          const SizedBox(height: 16),
          _buildGuideItemWithIcon(
            color: Colors.redAccent.withOpacity(0.08),
            borderColor: Colors.redAccent.withOpacity(0.3),
            icon: Icons.lock_outline_rounded,
            iconColor: Colors.redAccent,
            title: 'reserved_date'.tr,
            subtitle: 'reserved_date_sub'.tr,
          ),
          const SizedBox(height: 16),
          _buildGuideItemWithIcon(
            color: Colors.orange.withOpacity(0.05),
            borderColor: Colors.orange.shade300,
            icon: Icons.light_mode_rounded,
            iconColor: Colors.orange,
            title: 'morning_booking_title'.tr,
            subtitle: 'morning_booking_sub'.tr,
          ),
          const SizedBox(height: 16),
          _buildGuideItemWithIcon(
            color: Colors.indigo.withOpacity(0.05),
            borderColor: Colors.indigo.shade300,
            icon: Icons.nights_stay_rounded,
            iconColor: Colors.indigo,
            title: 'evening_booking_title'.tr,
            subtitle: 'evening_booking_sub'.tr,
          ),
          const SizedBox(height: 16),
          _buildGuideItemWithIcon(
            color: Colors.deepPurple.withOpacity(0.15),
            borderColor: Colors.deepPurple.withOpacity(0.4),
            icon: Icons.star_outline_rounded,
            iconColor: Colors.deepPurple,
            title: 'seasonal_period'.tr,
            subtitle: 'seasonal_period_sub'.tr,
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            color: colors.inputFillColor,
            borderColor: colors.borderColor,
            tag: "01",
            title: 'available_slot'.tr,
            subtitle: 'available_slot_sub'.tr,
            textColor: colors.subtitleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required Color color,
    required Color borderColor,
    required String tag,
    required String title,
    required String subtitle,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItemWithIcon({
    required Color color,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
