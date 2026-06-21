import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../data/model/DishCategoryModel.dart';

class DishCategoryCard extends StatelessWidget {
  final DishCategoryModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DishCategoryCard({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    // final isArabic = Get.locale?.languageCode == 'ar';

    final title = item.name;
    final imageUrl = item.image;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with Badge
          Stack(
            children: [
              imageUrl != null &&
                      imageUrl.isNotEmpty &&
                      !imageUrl.startsWith('http') &&
                      File(imageUrl).existsSync()
                  ? Image.file(
                      File(imageUrl),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: AppColor.purpleGradient),
                      ),
                      child: const Icon(
                        Icons.flatware_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
              // Items Count Badge overlay
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
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
                          tooltip: 'edit_btn'.tr,
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
                          tooltip: 'delete'.tr,
                        ),
                      ],
                    ),
                  ],
                ),
                // const Divider(height: 1),
                // const SizedBox(height: 16),

                // // Explore Link
                // InkWell(
                //   onTap: () {},
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         'explore_category'.tr,
                //         style: const TextStyle(
                //           fontSize: 13,
                //           fontWeight: FontWeight.bold,
                //           color: AppColor.primaryPurple,
                //
                //         ),
                //       ),
                //       const SizedBox(width: 8),
                //       Icon(
                //         isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                //         color: AppColor.primaryPurple,
                //         size: 16,
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
