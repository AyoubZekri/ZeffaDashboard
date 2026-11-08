import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Reservationscontroller.dart';
import '../shared/DateFilterDialog.dart';

/// Reservations date filter: one day or a period
class ReservationDateFilterDialog extends StatelessWidget {
  const ReservationDateFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<Reservationscontroller>();
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
