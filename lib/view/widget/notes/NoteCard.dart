import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../data/model/NoteModel.dart';

class NoteCard extends StatelessWidget {
  final NoteModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    String formattedDate = '';
    if (item.createdAt != null) {
      try {
        final date = DateTime.parse(item.createdAt!);
        formattedDate = DateFormat('yyyy-MM-dd').format(date);
      } catch (e) {
        formattedDate = item.createdAt!;
      }
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Action Buttons Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                        size: 20,
                      ),
                      onPressed: onEdit,
                      tooltip: 'edit_note'.tr,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: onDelete,
                      tooltip: 'delete_note'.tr,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            if (item.description != null && item.description!.isNotEmpty) ...[
              Text(
                item.description!,
                style: TextStyle(fontSize: 14, color: colors.subtitleColor),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],

            const Spacer(),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColor.primaryPurple,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primaryPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
