import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:zeffa/core/functions/valiedinput.dart' show validInput;
import '../../../controller/Reservationscontroller.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../CustemTextField.dart';

class ReservationDateFilterDialog extends StatefulWidget {
  const ReservationDateFilterDialog({super.key});

  @override
  State<ReservationDateFilterDialog> createState() =>
      _ReservationDateFilterDialogState();
}

class _ReservationDateFilterDialogState
    extends State<ReservationDateFilterDialog> {
  late Reservationscontroller ctrl;
  DateTime? tempStart;
  DateTime? tempEnd;

  late TextEditingController startController;
  late TextEditingController endController;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<Reservationscontroller>();
    tempStart = ctrl.startDateFilter.value;
    tempEnd = ctrl.endDateFilter.value;

    startController = TextEditingController(
      text: tempStart != null
          ? DateFormat('yyyy-MM-dd').format(tempStart!)
          : "",
    );
    endController = TextEditingController(
      text: tempEnd != null ? DateFormat('yyyy-MM-dd').format(tempEnd!) : "",
    );
  }

  @override
  void dispose() {
    startController.dispose();
    endController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? tempStart : tempEnd) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          tempStart = picked;
          startController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          tempEnd = picked;
          endController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final bgColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = colors.subtitleColor;
    final borderColor = colors.borderColor;
    final isArabic = Get.locale?.languageCode == 'ar';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: bgColor,
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColor.primaryPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'filter_by_date'.tr : 'Filter by Date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? 'choose_start_end_date'.tr
                              : 'Select start date and end date',
                          style: TextStyle(fontSize: 12, color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded, color: subtitleColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 24),

              // Start Date Picker
              CustemTextField(
                controller: startController,
                label: 'select_start_date'.tr,
                hint: 'YYYY-MM-DD',
                icon: Icons.date_range_rounded,
                readOnly: true,
                onTap: () => _pickDate(context, true),
                validator: (val) {
                  return validInput(val!, 10000, 0, "date");
                },
              ),
              const SizedBox(height: 20),

              // End Date Picker
              CustemTextField(
                controller: endController,
                label: 'select_end_date'.tr,
                hint: 'YYYY-MM-DD',
                icon: Icons.date_range_rounded,
                readOnly: true,
                onTap: () => _pickDate(context, false),
                validator: (val) {
                  return validInput(val!, 10000, 0, "date");
                },
              ),
              const SizedBox(height: 32),

              // Footer Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel / Clear Filter
                  TextButton(
                    onPressed: () {
                      ctrl.clearDateFilter();
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      isArabic ? 'reset'.tr : 'Reset',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Cancel Button
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Apply Button
                  ElevatedButton(
                    onPressed: () {
                      ctrl.startDateFilter.value = tempStart;
                      ctrl.endDateFilter.value = tempEnd;
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isArabic ? 'apply'.tr : 'Apply',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
}
