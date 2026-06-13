import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class CalendarHeader extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onExportPressed;

  const CalendarHeader({
    Key? key,
    required this.onAddPressed,
    required this.onExportPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title & Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'calendar_title'.tr,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'calendar_desc'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.subtitleColor,
                  fontFamily: 'Cairo',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Action Buttons Row
        Row(
          children: [
            // Export Button (Sleek Outline style)
            // OutlinedButton.icon(
            //   onPressed: onExportPressed,
            //   icon: const Icon(
            //     Icons.file_download_outlined,
            //     color: AppColor.primaryPurple,
            //     size: 20,
            //   ),
            //   label: Text(
            //     'export_calendar'.tr,
            //     style: const TextStyle(
            //       color: AppColor.primaryPurple,
            //       fontWeight: FontWeight.bold,
            //       fontSize: 14,
            //       fontFamily: 'Cairo',
            //     ),
            //   ),
            //   style: OutlinedButton.styleFrom(
            //     side: const BorderSide(color: AppColor.primaryPurple, width: 1.5),
            //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            // Add Seasonal Event Button
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              label: Text(
                'add_seasonal_event'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryPurple,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
