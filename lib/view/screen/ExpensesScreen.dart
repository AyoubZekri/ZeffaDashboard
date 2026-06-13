import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/ExpensesController.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/constant/AppTheme.dart';
import '../../core/functions/dialogDelete.dart';
import '../../data/model/ExpenseModel.dart';
import '../widget/expenses/ExpenseFormDialog.dart';
import '../widget/expenses/ExpensesHeader.dart';
import '../widget/expenses/ExpensesTable.dart';
import '../widget/expenses/ExpenseDateFilterDialog.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';
    final textColor = theme.colorScheme.onSurface;

    // Inject/Find the ExpensesController
    final ctrl = Get.put(ExpensesController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Section Widget ──
                ExpensesHeader(
                  searchController: ctrl.searchController,
                  onSearchChanged: (value) {
                    ctrl.searchQuery.value = value;
                  },
                  onAddPressed: () {
                    Get.dialog(
                      const ExpenseFormDialog(),
                      barrierDismissible: true,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── Summary Cards Section (Remaining budget removed, only total expenses is displayed) ──
                Obx(() {
                  final totalSum = ctrl.totalExpensesSum;
                  final currencyStr = isArabic ? "د.ج" : "DA";

                  return Container(
                    width: double.infinity,
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
                      border: Border.all(color: colors.borderColor, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'status'.tr == 'الحالة'
                                  ? 'إجمالي مصاريف الشهر الحالي'
                                  : 'Total Month Expenses',
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.subtitleColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "${totalSum.toStringAsFixed(2)} $currencyStr",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColor.primaryPurple,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              textDirection: isArabic
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              children: [
                                const Icon(
                                  Icons.trending_up_rounded,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'status'.tr == 'الحالة'
                                      ? 'محدث تلقائياً من العمليات'
                                      : 'Auto-updated from transactions',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Add action inside banner
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.dialog(
                              const ExpenseFormDialog(),
                              barrierDismissible: true,
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: Text(
                            'add_expense'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // ── Category Filters / Chips ──
                _buildCategoryFilters(ctrl, context),
                const SizedBox(height: 24),

                // ── Expenses Table Section ──
                Obx(() {
                  final paginated = ctrl.paginatedExpenses;
                  return ExpensesTable(
                    expenses: paginated,
                    currentPage: ctrl.currentPage.value,
                    totalPages: ctrl.totalPages,
                    totalItems: ctrl.filteredExpenses.length,
                    itemsPerPage: ctrl.itemsPerPage,
                    onPageChanged: (page) {
                      ctrl.goToPage(page);
                    },
                    onEdit: (expense) {
                      ctrl.setEditData(expense);
                      Get.dialog(
                        const ExpenseFormDialog(isEdit: true),
                        barrierDismissible: true,
                      );
                    },
                    onDelete: (expense) {
                      dialogDelete(
                        title: 'delete_expense'.tr,
                        content:
                            "${'delete_expense_confirm'.tr} (${expense.description})؟",
                        onConfirm: () {
                          ctrl.deleteExpense(expense.uuid!);
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(ExpensesController ctrl, BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';

    final List<Map<String, dynamic>> categories = [
      {'id': 0, 'label': 'all'.tr},
      {'id': 1, 'label': 'maintenance_workers'.tr},
      {'id': 2, 'label': 'cleaning_materials'.tr},
      {'id': 3, 'label': 'other_expenses'.tr},
    ];

    return Obx(() {
      final selectedId = ctrl.selectedCategory.value;
      final start = ctrl.startDateFilter.value;
      final end = ctrl.endDateFilter.value;
      final hasDateFilter = start != null && end != null;

      return Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // Category chips
          ...categories.map((cat) {
            final id = cat['id'] as int;
            final label = cat['label'] as String;
            final isSelected = selectedId == id;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                label: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ctrl.selectedCategory.value = id;
                  }
                },
                selectedColor: AppColor.primaryPurple,
                backgroundColor: colors.inputFillColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? AppColor.primaryPurple : colors.borderColor,
                  ),
                ),
              ),
            );
          }).toList(),

          const Spacer(),

          // Date Filter Button / Chip
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              avatar: Icon(
                Icons.calendar_month_rounded,
                color: hasDateFilter ? Colors.white : AppColor.primaryPurple,
                size: 18,
              ),
              label: Text(
                hasDateFilter
                    ? "${start.year}/${start.month.toString().padLeft(2, '0')}/${start.day.toString().padLeft(2, '0')} - ${end.year}/${end.month.toString().padLeft(2, '0')}/${end.day.toString().padLeft(2, '0')}"
                    : 'status'.tr == 'الحالة' ? 'تصفية بالتاريخ' : 'Filter by Date',
                style: TextStyle(
                  color: hasDateFilter ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              selected: hasDateFilter,
              onSelected: (selected) {
                Get.dialog(
                  const ExpenseDateFilterDialog(),
                  barrierDismissible: true,
                );
              },
              selectedColor: AppColor.primaryPurple,
              backgroundColor: colors.inputFillColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: hasDateFilter ? AppColor.primaryPurple : colors.borderColor,
                ),
              ),
            ),
          ),
          if (hasDateFilter)
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: Colors.red),
              onPressed: () => ctrl.clearDateFilter(),
              tooltip: 'status'.tr == 'الحالة' ? 'إلغاء تصفية التاريخ' : 'Clear Date Filter',
            ),
        ],
      );
    });
  }
}
