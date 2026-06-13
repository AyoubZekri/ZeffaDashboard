import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../data/model/ExpenseModel.dart';

class ExpensesTable extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ExpenseModel>? onEdit;
  final ValueChanged<ExpenseModel>? onDelete;

  const ExpensesTable({
    super.key,
    required this.expenses,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScroll = ScrollController();
    final horizontalScroll = ScrollController();
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Container(
      height: 500,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.cardColor,
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
        children: [
          Expanded(
            child: Scrollbar(
              controller: horizontalScroll,
              thumbVisibility: true,
              thickness: 8,
              radius: const Radius.circular(8),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: SingleChildScrollView(
                  controller: horizontalScroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 900,
                    child: Scrollbar(
                      controller: verticalScroll,
                      notificationPredicate: (notif) => notif.depth == 1,
                      child: SingleChildScrollView(
                        controller: verticalScroll,
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            _buildTableHeader(context),
                            const SizedBox(height: 8),
                            Divider(color: colors.borderColor, height: 1),
                            if (expenses.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 64,
                                ),
                                child: Center(
                                  child: Text(
                                    'no_expenses_found'.tr,
                                    style: TextStyle(
                                      color: colors.subtitleColor,
                                      fontSize: 16,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...List.generate(
                                expenses.length,
                                (index) =>
                                    _buildTableRow(context, expenses[index]),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildPagination(context),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final style = TextStyle(
      fontSize: 14,
      color: colors.subtitleColor,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
    );
    final isArabic = Get.locale?.languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          SizedBox(
            width: 300,
            child: Text(
              'expense_name'.tr,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: style,
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              'expense_date'.tr,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: style,
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              'amount'.tr,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: style,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 100,
            child: Center(child: Text('actions'.tr, style: style)),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, ExpenseModel item) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final isArabic = Get.locale?.languageCode == 'ar';

    // Categories details
    IconData categoryIcon = Icons.category_rounded;
    Color categoryColor = AppColor.primaryPurple;
    String categoryName = "";

    switch (item.type) {
      case 1:
        categoryIcon = Icons.construction_rounded;
        categoryColor = Colors.orange;
        categoryName = 'maintenance_workers'.tr;
        break;
      case 2:
        categoryIcon = Icons.cleaning_services_rounded;
        categoryColor = Colors.teal;
        categoryName = 'cleaning_materials'.tr;
        break;
      case 3:
      default:
        categoryIcon = Icons.more_horiz_rounded;
        categoryColor = Colors.blueGrey;
        categoryName = 'other_expenses'.tr;
        break;
    }

    // Currency representation in DA
    final String currencyStr = isArabic ? "د.ج" : "DA";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // Expense Name & Category
          SizedBox(
            width: 300,
            child: Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: categoryColor.withOpacity(0.1),
                  child: Icon(categoryIcon, color: categoryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description ?? "",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          categoryName,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Expense Date
          SizedBox(
            width: 150,
            child: Text(
              item.datePerry ?? "",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          // Amount in DA
          SizedBox(
            width: 150,
            child: Text(
              "${item.value?.toStringAsFixed(2) ?? '0.00'} $currencyStr",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const Spacer(),

          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionIcon(
                  context,
                  Icons.edit_outlined,
                  Colors.amber.shade700,
                  () => onEdit?.call(item),
                ),
                _buildActionIcon(
                  context,
                  Icons.delete_outline_rounded,
                  Colors.red,
                  () => onDelete?.call(item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(
    BuildContext context,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.inputFillColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';

    final startIndex = totalItems == 0
        ? 0
        : (currentPage - 1) * itemsPerPage + 1;
    final endIndex = (currentPage * itemsPerPage) > totalItems
        ? totalItems
        : (currentPage * itemsPerPage);

    final String infoText = isArabic
        ? "عرض $startIndex-$endIndex من أصل $totalItems مصروف"
        : "Showing $startIndex-$endIndex of $totalItems expenses";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(
          infoText,
          style: TextStyle(
            color: colors.subtitleColor,
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
        ),
        Row(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            _buildPageItem(
              context,
              isArabic ? '>' : '<',
              false,
              enabled: currentPage > 1,
              onTap: () => onPageChanged(currentPage - 1),
            ),
            ...List.generate(totalPages, (index) {
              final pageNum = index + 1;
              return _buildPageItem(
                context,
                pageNum.toString(),
                pageNum == currentPage,
                enabled: true,
                onTap: () => onPageChanged(pageNum),
              );
            }),
            _buildPageItem(
              context,
              isArabic ? '<' : '>',
              false,
              enabled: currentPage < totalPages,
              onTap: () => onPageChanged(currentPage + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageItem(
    BuildContext context,
    String label,
    bool active, {
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColor.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active
              ? null
              : Border.all(
                  color: colors.borderColor.withOpacity(enabled ? 1.0 : 0.3),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Colors.white
                : theme.colorScheme.onSurface.withOpacity(enabled ? 1.0 : 0.3),
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
