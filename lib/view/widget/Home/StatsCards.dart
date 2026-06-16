import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _buildStatCard(
            context: context,
            title: 'today_profit'.tr,
            value: 'sar_amount_1'.tr,
            percentage: '+12.5%',
            isPositive: true,
            icon: Icons.trending_up,
            iconBg: isDark
                ? const Color(0xFF1E3A20)
                : const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF4CAF50),
          ),
          _buildStatCard(
            context: context,
            title: 'today_income'.tr,
            value: 'sar_amount_2'.tr,
            percentage: '+8.2%',
            isPositive: true,
            icon: Icons.account_balance_wallet_outlined,
            iconBg: isDark
                ? const Color(0xFF1A2E44)
                : const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF2196F3),
          ),
          _buildStatCard(
            context: context,
            title: 'low_stock'.tr,
            value: '14',
            percentage: 'near_depletion'.tr,
            isPositive: false,
            icon: Icons.warning_amber_rounded,
            iconBg: isDark
                ? const Color(0xFF3D1F1F)
                : const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFEF5350),
          ),
          _buildStatCard(
            context: context,
            title: 'today_sales_count'.tr,
            value: '84',
            percentage: '8+',
            isPositive: true,
            icon: Icons.shopping_basket_outlined,
            iconBg: isDark
                ? const Color(0xFF3A2D1F)
                : const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFFFA726),
            hasAvatars: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String percentage,
    required bool isPositive,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    bool hasAvatars = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: iconBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: colors.subtitleColor,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
