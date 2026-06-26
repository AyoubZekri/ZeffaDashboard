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
    Get.delete<ExpensesController>();
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

                // ── Summary Cards Section ──
                Obx(() {
                  final totalExpenses = ctrl.totalExpensesSum;
                  final totalIncome = ctrl.totalIncomeSum;
                  final totalProfits = ctrl.totalProfitsSum;
                  final currencyStr = isArabic ? 'currency_dzd'.tr : "DA";

                  final isDark = theme.brightness == Brightness.dark;
                  final isSmallScreen = MediaQuery.of(context).size.width < 900;

                  Widget buildCard({
                    required String title,
                    required double value,
                    required IconData icon,
                    required Color iconColor,
                    required Color iconBg,
                    Color? valueColor,
                  }) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: iconColor, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.subtitleColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${value.toInt()} $currencyStr",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: valueColor ?? textColor,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'current_month_or_filter'.tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.subtitleColor.withOpacity(
                                      0.8,
                                    ),
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final cardExpenses = buildCard(
                    title: 'total_expenses'.tr,
                    value: totalExpenses,
                    icon: Icons.trending_down_rounded,
                    iconColor: const Color(0xFFEF5350),
                    iconBg: isDark
                        ? const Color(0xFF3D1F1F)
                        : const Color(0xFFFFEBEE),
                    valueColor: const Color(0xFFEF5350),
                  );

                  final cardIncome = buildCard(
                    title: 'total_income'.tr,
                    value: totalIncome,
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    iconBg: isDark
                        ? const Color(0xFF1E3A20)
                        : const Color(0xFFE8F5E9),
                    valueColor: const Color(0xFF4CAF50),
                  );

                  final profitsColor = totalProfits >= 0
                      ? (isDark
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFF2E7D32))
                      : (isDark
                            ? const Color(0xFFEF5350)
                            : const Color(0xFFC62828));

                  final cardProfits = buildCard(
                    title: 'total_profits'.tr,
                    value: totalProfits,
                    icon: totalProfits >= 0
                        ? Icons.insights_rounded
                        : Icons.trending_down_rounded,
                    iconColor: totalProfits >= 0
                        ? const Color(0xFF009688)
                        : const Color(0xFFEF5350),
                    iconBg: totalProfits >= 0
                        ? (isDark
                              ? const Color(0xFF143530)
                              : const Color(0xFFE0F2F1))
                        : (isDark
                              ? const Color(0xFF3D1F1F)
                              : const Color(0xFFFFEBEE)),
                    valueColor: profitsColor,
                  );

                  final totalDebts = ctrl.totalDebtsSum;
                  final cardDebts = buildCard(
                    title: 'debts'.tr,
                    value: totalDebts,
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFFE65100),
                    iconBg: isDark
                        ? const Color(0xFF3E2723)
                        : const Color(0xFFFFF3E0),
                    valueColor: const Color(0xFFE65100),
                  );

                  if (isSmallScreen) {
                    return Column(
                      children: [
                        cardExpenses,
                        const SizedBox(height: 16),
                        cardIncome,
                        const SizedBox(height: 16),
                        cardProfits,
                        const SizedBox(height: 16),
                        cardDebts,
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(child: cardExpenses),
                        const SizedBox(width: 16),
                        Expanded(child: cardIncome),
                        const SizedBox(width: 16),
                        Expanded(child: cardProfits),
                        const SizedBox(width: 16),
                        Expanded(child: cardDebts),
                      ],
                    );
                  }
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
                        content: 'delete_expense_confirm_desc'.tr,
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
      {'id': 1, 'label': 'workers'.tr},
      {'id': 4, 'label': 'maintenance'.tr},
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
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
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
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected
                        ? AppColor.primaryPurple
                        : colors.borderColor,
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
                    : 'status'.tr == 'status'.tr
                    ? 'filter_by_date'.tr
                    : 'Filter by Date',
                style: TextStyle(
                  color: hasDateFilter
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
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
                  color: hasDateFilter
                      ? AppColor.primaryPurple
                      : colors.borderColor,
                ),
              ),
            ),
          ),
          if (hasDateFilter)
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: Colors.red),
              onPressed: () => ctrl.clearDateFilter(),
              tooltip: 'status'.tr == 'status'.tr
                  ? 'cancel_date_filter'.tr
                  : 'Clear Date Filter',
            ),
        ],
      );
    });
  }
}
