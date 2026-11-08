import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/CalendarController.dart';
import '../halls/HallChips.dart';

/// Hall chips above the calendar. Hidden when the account has one hall.
class CalendarHallSelector extends StatelessWidget {
  final CalendarController ctrl;

  const CalendarHallSelector({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!ctrl.hasMultipleHalls) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: HallChips(
          halls: ctrl.halls.toList(),
          selectedKey: ctrl.selectedHallUuid.value ?? '',
          onSelected: ctrl.selectHall,
        ),
      );
    });
  }
}
