import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class TransactionsTable extends StatelessWidget {
  const TransactionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final titleColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
                'last_transactions'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,

                  color: titleColor,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'view_all'.tr,
                  style: const TextStyle(color: AppColor.primaryPurple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTableHeader(colors),
          Divider(color: colors.borderColor),
          _buildTableRow(
            context,
            'iphone_15_pro_max'.tr,
            'date_time_1'.tr,
            'khalid_omari'.tr,
            'completed'.tr,
            'sar_amount_3'.tr,
            Colors.green,
            Icons.smartphone,
            colors,
          ),
          _buildTableRow(
            context,
            'sony_headphones'.tr,
            'date_time_2'.tr,
            'reem_qahtani'.tr,
            'completed'.tr,
            'sar_amount_4'.tr,
            Colors.green,
            Icons.headphones,
            colors,
          ),
          _buildTableRow(
            context,
            'apple_watch_ultra_2'.tr,
            'date_time_3'.tr,
            'mohammed_otaibi'.tr,
            'processing'.tr,
            'sar_amount_5'.tr,
            Colors.orange,
            Icons.watch,
            colors,
          ),
          _buildTableRow(
            context,
            'macbook_air_m3'.tr,
            'date_time_4'.tr,
            'sara_shammari'.tr,
            'completed'.tr,
            'sar_amount_6'.tr,
            Colors.green,
            Icons.laptop_mac,
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(AppColors colors) {
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: colors.subtitleColor,
      fontSize: 13,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'product'.tr,
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'date'.tr,
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'customer'.tr,
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'status'.tr,
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'amount'.tr,
              textAlign: TextAlign.right,
              style: headerStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    String product,
    String date,
    String customer,
    String status,
    String amount,
    Color statusColor,
    IconData icon,
    AppColors colors,
  ) {
    final theme = Theme.of(context);
    final titleColor = theme.colorScheme.onSurface;
    final subtitleColor = colors.subtitleColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.inputFillColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColor.primaryPurple),
                ),
                const SizedBox(width: 12),
                Text(
                  product,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              textAlign: TextAlign.right,
              style: TextStyle(color: subtitleColor, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              customer,
              textAlign: TextAlign.right,
              style: TextStyle(color: titleColor, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.primaryPurple,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
