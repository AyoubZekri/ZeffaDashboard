import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/Colorapp.dart';
import '../../../../core/constant/AppTheme.dart';

class NotificationPerformanceSummary extends StatelessWidget {
  const NotificationPerformanceSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [const Color(0xFF4C1D95), const Color(0xFF1E1B4B)] : [AppColor.primaryPurple, const Color(0xFF4338CA)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: colors.shadowColor, blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("performance_summary".tr, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600, )),
                const SizedBox(height: 12),
                Text("performance_text".tr, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.4, ), textAlign: TextAlign.right),
              ],
            ),
          ),
          const SizedBox(width: 64),
          _buildStatCircle("12", "successful_sales".tr),
          const SizedBox(width: 32),
          _buildStatCircle("3", "alerts_count".tr),
        ],
      ),
    );
  }

  Widget _buildStatCircle(String val, String label) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, )),
        ],
      ),
    );
  }
}
