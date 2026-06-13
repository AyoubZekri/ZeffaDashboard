import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildChartCard(context)),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: _buildBestSellersCard(context)),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
              Text(
                'income_statistics'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: titleColor,
                ),
              ),
              _buildChartFilter(context),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'sales_performance_comparison'.tr,
            style: TextStyle(
              fontSize: 14,
              color: colors.subtitleColor,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 15,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(
                          color: colors.subtitleColor,
                          fontSize: 10,
                          fontFamily: 'Cairo',
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = '08:00';
                            break;
                          case 1:
                            text = '10:00';
                            break;
                          case 2:
                            text = '12:00';
                            break;
                          case 3:
                            text = '14:00';
                            break;
                          case 4:
                            text = '16:00';
                            break;
                          case 5:
                            text = '18:00';
                            break;
                          case 6:
                            text = '20:00';
                            break;
                          default:
                            text = '';
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroup(context, 0, 5, isHighlighted: false),
                  _makeGroup(context, 1, 8, isHighlighted: false),
                  _makeGroup(context, 2, 6, isHighlighted: false),
                  _makeGroup(context, 3, 10, isHighlighted: false),
                  _makeGroup(context, 4, 7, isHighlighted: false),
                  _makeGroup(context, 5, 14, isHighlighted: true),
                  _makeGroup(context, 6, 9, isHighlighted: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroup(
    BuildContext context,
    int x,
    double y, {
    required bool isHighlighted,
  }) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isHighlighted
              ? AppColor.primaryPurple
              : colors.inputFillColor,
          width: 32,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildChartFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.inputFillColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterTab(context, 'day'.tr, isActive: true),
          _buildFilterTab(context, 'week'.tr, isActive: false),
          _buildFilterTab(context, 'month'.tr, isActive: false),
          _buildFilterTab(context, 'year'.tr, isActive: false),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    BuildContext context,
    String label, {
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.surface
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? AppColor.primaryPurple
              : colors.subtitleColor,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildBestSellersCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(24),
      height: 420,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            'best_selling'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: titleColor,
            ),
          ),
          const SizedBox(height: 24),
          _buildBestSellerItem(
            context,
            'electronics'.tr,
            75,
            AppColor.primaryPurple,
            Icons.laptop_mac,
          ),
          _buildBestSellerItem(
            context,
            'clothing'.tr,
            42,
            const Color(0xFF4CAF50),
            Icons.checkroom,
          ),
          _buildBestSellerItem(
            context,
            'home_appliances'.tr,
            28,
            const Color(0xFFFFA726),
            Icons.home_outlined,
          ),
          Divider(height: 70, color: colors.borderColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'total_active_stock'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.subtitleColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    '2,482',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3A20)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'stable',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellerItem(
    BuildContext context,
    String title,
    int progress,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final titleColor = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                        color: titleColor,
                      ),
                    ),
                    Text(
                      '$progress%',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.subtitleColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: colors.inputFillColor,
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
