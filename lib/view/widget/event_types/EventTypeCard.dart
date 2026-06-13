import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class EventTypeCard extends StatelessWidget {
  final Map<String, dynamic> type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventTypeCard({
    Key? key,
    required this.type,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    
    final title = type['titleKey'] != '' ? type['titleKey'].toString().tr : type['titleCustom'].toString();
    final description = type['descKey'] != '' ? type['descKey'].toString().tr : type['descCustom'].toString();

    return Container(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon & Accent Dot Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: type['iconBgColor'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type['icon'] as IconData,
                  color: type['iconColor'] as Color,
                  size: 24,
                ),
              ),
              // Top-corner accent dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: (type['iconColor'] as Color).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Expanded(
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: colors.subtitleColor,
                fontFamily: 'Cairo',
                height: 1.5,
              ),
            ),
          ),

          const Divider(height: 16),

          // Price & Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'base_price'.tr + ': ',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.subtitleColor,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        type['price'].toString() + ' ' + 'sar_currency'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColor.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'السعر الموسمي: ',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.subtitleColor,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        type['seasonalPrice'].toString() + ' ' + 'sar_currency'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColor.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Actions (Edit, Delete)
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: colors.subtitleColor,
                      size: 20,
                    ),
                    onPressed: onEdit,
                    tooltip: 'edit_btn'.tr,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: onDelete,
                    tooltip: 'delete'.tr,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
