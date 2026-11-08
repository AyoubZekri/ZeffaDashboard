import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ExpensesController.dart';
import '../shared/DateFilterDialog.dart';

/// Expenses date filter: one day or a period
class ExpenseDateFilterDialog extends StatelessWidget {
  const ExpenseDateFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExpensesController>();
    return DateFilterDialog(
      initialStart: ctrl.startDateFilter.value,
      initialEnd: ctrl.endDateFilter.value,
      onApply: (start, end) {
        ctrl.startDateFilter.value = start;
        ctrl.endDateFilter.value = end;
      },
      onReset: ctrl.clearDateFilter,
    );
  }
}
