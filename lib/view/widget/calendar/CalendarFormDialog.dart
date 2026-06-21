import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/CalendarController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustemTextField.dart';

class CalendarFormDialog extends StatefulWidget {
  final CalendarController? ctrl;
  const CalendarFormDialog({super.key, this.ctrl});

  @override
  State<CalendarFormDialog> createState() => _CalendarFormDialogState();
}

class _CalendarFormDialogState extends State<CalendarFormDialog> {
  late CalendarController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = widget.ctrl ?? Get.put(CalendarController());
    if (widget.ctrl == null) {
      ctrl.clearFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;
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
          width: 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: Obx(() {
            final isPeriod = ctrl.isPeriodMode.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Dynamic Dialog Title ──
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColor.purpleGradient,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isPeriod
                              ? Icons.date_range_rounded
                              : Icons.star_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ctrl.editingUuid.value != null
                                  ? (isPeriod
                                        ? 'update_special_period'.tr
                                        : 'update_special_day'.tr)
                                  : (isPeriod
                                        ? 'add_period_season'.tr
                                        : 'add_special_day'.tr),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
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
                ),

                // ── Interactive Segment Tabs Selector ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.inputFillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        // Tab 1: Special Day
                        Expanded(
                          child: InkWell(
                            onTap: () => ctrl.isPeriodMode.value = false,
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !isPeriod
                                    ? AppColor.primaryPurple
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'add_special_day'.tr,
                                style: TextStyle(
                                  color: !isPeriod
                                      ? Colors.white
                                      : subtitleColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Tab 2: Period / Season
                        Expanded(
                          child: InkWell(
                            onTap: () => ctrl.isPeriodMode.value = true,
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isPeriod
                                    ? AppColor.primaryPurple
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'add_period_season'.tr,
                                style: TextStyle(
                                  color: isPeriod
                                      ? Colors.white
                                      : subtitleColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Form Content ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: ctrl.formState,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isPeriod) ...[
                            // SPECIAL DAY FORM
                            CustemTextField(
                              controller: ctrl.eventNameController,
                              label: 'special_day_name'.tr,
                              hint: 'event_name'.tr,
                              icon: Icons.bookmark_added_outlined,
                              validator: (val) {
                                return validInput(val!, 100, 3, "name");
                              },
                            ),
                            const SizedBox(height: 20),
                            // Specific Date Picker Row
                            _buildDatePickerTrigger(
                              label: 'date_label'.tr,
                              currentVal: ctrl.selectedDate.value,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  ctrl.selectedDate.value = picked;
                                }
                              },
                            ),
                          ] else ...[
                            // PERIOD / SEASON FORM
                            CustemTextField(
                              controller: ctrl.eventNameController,
                              label: 'period_name'.tr,
                              hint: 'season_autumn'.tr,
                              icon: Icons.wb_twilight_rounded,
                              validator: (val) {
                                return validInput(val!, 100, 3, "username");
                              },
                            ),
                            const SizedBox(height: 20),

                            // Range Date Pickers
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDatePickerTrigger(
                                    label: 'date_from'.tr,
                                    currentVal: ctrl.selectedStartDate.value,
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2030),
                                      );
                                      if (picked != null) {
                                        ctrl.selectedStartDate.value = picked;
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDatePickerTrigger(
                                    label: 'date_to'.tr,
                                    currentVal: ctrl.selectedEndDate.value,
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2030),
                                      );
                                      if (picked != null) {
                                        ctrl.selectedEndDate.value = picked;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Footer Buttons ──
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            color: subtitleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          bool success = false;
                          if (ctrl.editingUuid.value != null) {
                            success = await ctrl.updateSpecialDate();
                          } else {
                            if (isPeriod) {
                              success = await ctrl.addSeason();
                            } else {
                              success = await ctrl.addSpecialDay();
                            }
                          }

                          if (success) {
                            Get.back();
                            Get.snackbar(
                              'success'.tr,
                              isPeriod
                                  ? 'season_added'.tr
                                  : 'special_day_added'.tr,
                              backgroundColor: isDark
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFFE8F5E9),
                              colorText: isDark
                                  ? Colors.white
                                  : Colors.green.shade900,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          ctrl.editingUuid.value != null
                              ? 'update'.tr
                              : (isPeriod
                                    ? 'add_period_season'.tr
                                    : 'add_special_day'.tr),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDatePickerTrigger({
    required String label,
    required DateTime? currentVal,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final String dateText = currentVal == null
        ? 'select_date'.tr
        : "${currentVal.year}/${currentVal.month.toString().padLeft(2, '0')}/${currentVal.day.toString().padLeft(2, '0')}";

    return FormField<DateTime>(
      key: ValueKey(
        currentVal,
      ), // Force rebuild and reset state when value changes
      initialValue: currentVal,
      validator: (val) {
        if (currentVal == null) {
          return 'required_field'.tr; // Or any generic error message you prefer
        }
        return null;
      },
      builder: (FormFieldState<DateTime> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colors.inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.hasError
                        ? Colors.red.shade400
                        : colors.borderColor,
                    width: state.hasError ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 14,
                        color: currentVal == null
                            ? colors.subtitleColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Icon(
                      Icons.calendar_month_rounded,
                      color: state.hasError
                          ? Colors.red.shade400
                          : AppColor.primaryPurple.withOpacity(0.7),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 12, left: 12),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
