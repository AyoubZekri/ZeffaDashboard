import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../data/model/TermModel.dart';

class TermCard extends StatelessWidget {
  final TermModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TermCard({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';

    String formattedDate = '';
    if (item.createdAt != null) {
      try {
        final date = DateTime.parse(item.createdAt!);
        formattedDate = DateFormat('yyyy-MM-dd').format(date);
      } catch (e) {
        formattedDate = item.createdAt!;
      }
    }

    // Determine color and icon based on Term type
    Color typeColor;
    IconData typeIcon;
    switch (item.type) {
      case 'internal_rules':
        typeColor = Colors.orange;
        typeIcon = Icons.rule_rounded;
        break;
      case 'contract_terms':
        typeColor = Colors.blue;
        typeIcon = Icons.description_rounded;
        break;
      case 'required_procedures':
        typeColor = Colors.teal;
        typeIcon = Icons.assignment_turned_in_rounded;
        break;
      case 'required_documents':
        typeColor = Colors.redAccent;
        typeIcon = Icons.folder_shared_rounded;
        break;
      default:
        typeColor = AppColor.primaryPurple;
        typeIcon = Icons.gavel_rounded;
    }

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFullContentDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Term Type Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: typeColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, color: typeColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            (item.type ?? '').tr,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.edit_outlined,
                            color: colors.subtitleColor,
                            size: 18,
                          ),
                          onPressed: onEdit,
                          tooltip: 'edit_term'.tr,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          onPressed: onDelete,
                          tooltip: 'delete_term'.tr,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  item.title ?? '',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: item.contents.isNotEmpty ? 2 : 5,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Content Description
                if (item.contents.isNotEmpty) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.contents.take(3).map((detail) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "• ",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: typeColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _parseDetail(detail, isArabic, item.type),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: colors.subtitleColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Date & Detail indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColor.primaryPurple,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isArabic ? "تفاصيل أكثر ←" : "More details →",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryPurple.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullContentDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Get.locale?.languageCode == 'ar';

    Color typeColor;
    switch (item.type) {
      case 'internal_rules':
        typeColor = Colors.orange;
        break;
      case 'contract_terms':
        typeColor = Colors.blue;
        break;
      case 'required_procedures':
        typeColor = Colors.teal;
        break;
      case 'required_documents':
        typeColor = Colors.redAccent;
        break;
      default:
        typeColor = AppColor.primaryPurple;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: typeColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      (item.type ?? '').tr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.title ?? '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.contents.map((detail) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "• ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _parseDetail(detail, isArabic, item.type),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.8),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      isArabic ? "إغلاق" : "Close",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _parseDetail(String detail, bool isArabic, String? type) {
    if (type == 'required_documents') {
      try {
        final decoded = jsonDecode(detail);
        final name = decoded['name'] ?? item.title ?? '';
        final qty = decoded['quantity'] ?? 1;
        final unit = decoded['unit'] ?? '';
        final guests = decoded['covers_guests'] ?? 100;
        if (isArabic) {
          return "$name: $qty $unit (تكفي $guests أشخاص)";
        } else {
          return "$name: $qty $unit (covers $guests guests)";
        }
      } catch (e) {
        return detail;
      }
    }
    return detail;
  }
}
