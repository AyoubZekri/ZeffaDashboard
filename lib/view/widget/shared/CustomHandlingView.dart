import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/Statusrequest.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class CustomHandlingView extends StatelessWidget {
  final Statusrequest statusRequest;
  final Widget child;

  const CustomHandlingView({
    Key? key,
    required this.statusRequest,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = theme.extension<AppColors>() ?? AppColors.light;

    if (statusRequest == Statusrequest.loadeng) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              Get.locale?.languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.subtitleColor,
              ),
            ),
          ],
        ),
      );
    } else if (statusRequest == Statusrequest.offlinefailure || statusRequest == Statusrequest.serverfailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              Get.locale?.languageCode == 'ar' ? 'لا يتوفر اتصال بالإنترنت' : 'No Internet Connection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.subtitleColor,
              ),
            ),
          ],
        ),
      );
    } else if (statusRequest == Statusrequest.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              Get.locale?.languageCode == 'ar' ? 'لا توجد بيانات' : 'No Data Available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.subtitleColor,
              ),
            ),
          ],
        ),
      );
    }

    // Default to the actual view when status is successful or none (assuming none means success in local state)
    return child;
  }
}
