import 'package:zeffa/core/functions/format_money.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ExpensesController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustemTextField.dart';
import '../CustemDropDownField.dart';

class ExpenseFormDialog extends StatefulWidget {
  final bool isEdit;

  const ExpenseFormDialog({super.key, this.isEdit = false});

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  late ExpensesController ctrl;
  bool get isEdit => widget.isEdit;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<ExpensesController>();
    if (!isEdit) {
      ctrl.clearFields();
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
          width: 580,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
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
                        isEdit
                            ? Icons.edit_note_rounded
                            : Icons.add_circle_outline_rounded,
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
                            isEdit ? 'edit_expense'.tr : 'add_expense'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEdit
                                ? 'edit_expense_desc'.tr
                                : 'add_new_expense_desc'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
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

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: ctrl.formState,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        CustemTextField(
                          controller: ctrl.nameController,
                          label: 'expense_name'.tr,
                          hint: 'expense_name'.tr,
                          icon: Icons.description_outlined,
                          validator: (val) {
                            return validInput(val!, 1000, 1, "Text");
                          },
                        ),
                        const SizedBox(height: 20),

                        // Category Dropdown
                        Text(
                          'status'.tr == 'status'.tr
                              ? 'category'.tr
                              : 'Category',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          return CustemDropDownField<int>(
                            value: ctrl.formCategory.value,
                            onChanged: (val) {
                              ctrl.onCategoryChanged(val);
                            },
                            validator: (val) {
                              if (val == null) {
                                return "please_select_category".tr;
                              }
                              return null;
                            },
                            items: [
                              DropdownMenuItem<int>(
                                value: 1,
                                child: Text(
                                  'workers'.tr,
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                              DropdownMenuItem<int>(
                                value: 4,
                                child: Text(
                                  'maintenance'.tr,
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                              DropdownMenuItem<int>(
                                value: 2,
                                child: Text(
                                  'cleaning_materials'.tr,
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                              DropdownMenuItem<int>(
                                value: 3,
                                child: Text(
                                  'other_expenses'.tr,
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 20),

                        // Linked to a reservation (optional switch)
                        Obx(() {
                          final linked = ctrl.linkToReservation.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 12,
                                  end: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: linked
                                      ? AppColor.primaryPurple.withValues(
                                          alpha: 0.06,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: linked
                                        ? AppColor.primaryPurple
                                        : borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.event_available_rounded,
                                      size: 20,
                                      color: linked
                                          ? AppColor.primaryPurple
                                          : subtitleColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'expense_linked_to_reservation'.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        value: linked,
                                        activeColor: AppColor.primaryPurple,
                                        onChanged: ctrl.setLinkToReservation,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (linked) ...[
                                const SizedBox(height: 12),
                                CustemDropDownField<String?>(
                                  value: ctrl.formReservationUuid.value,
                                  hint: 'select_reservation'.tr,
                                  onChanged: (val) {
                                    ctrl.onReservationChanged(val);
                                  },
                                  items: ctrl.allReservations
                                      .map(
                                        (res) => DropdownMenuItem<String?>(
                                          value: res['uuid']?.toString(),
                                          child: Text(
                                            ctrl.reservationLabel(
                                                  res['uuid']?.toString(),
                                                ) ??
                                                '',
                                            style: TextStyle(color: textColor),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          );
                        }),
                        const SizedBox(height: 20),

                        // Date
                        CustemTextField(
                          controller: ctrl.dateController,
                          label: 'expense_date'.tr,
                          hint: 'YYYY-MM-DD',
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: () => ctrl.selectDate(context),
                          validator: (val) {
                            return validInput(val!, 1000, 0, "date");
                          },
                        ),
                        const SizedBox(height: 20),

                        // Amount — workers: count × price per person (from the event type
                        // when linked to a reservation), otherwise the amount typed directly
                        Obx(() {
                          final isWorkers = ctrl.formCategory.value == 1;
                          final linked = ctrl.linkToReservation.value;
                          final byCount = ctrl.workersByCount.value;
                          final total = ctrl.workersTotal.value;
                          final computed = isWorkers && (linked || byCount);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isWorkers && !linked) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.groups_rounded,
                                      size: 20,
                                      color: subtitleColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'by_workers_count'.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        value: byCount,
                                        activeColor: AppColor.primaryPurple,
                                        onChanged: (v) {
                                          ctrl.workersByCount.value = v;
                                          ctrl.recalcWorkers();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (computed) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustemTextField(
                                        controller: ctrl.workersCountController,
                                        label: 'workers_count'.tr,
                                        hint: '0',
                                        icon: Icons.man_rounded,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => ctrl.recalcWorkers(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustemTextField(
                                        controller: ctrl.workerPriceController,
                                        label: 'worker_price'.tr,
                                        hint: '0',
                                        icon: Icons.payments_outlined,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => ctrl.recalcWorkers(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustemTextField(
                                        controller:
                                            ctrl.femaleWorkersCountController,
                                        label: 'female_workers_count'.tr,
                                        hint: '0',
                                        icon: Icons.woman_rounded,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => ctrl.recalcWorkers(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustemTextField(
                                        controller:
                                            ctrl.femaleWorkerPriceController,
                                        label: 'female_worker_price'.tr,
                                        hint: '0',
                                        icon: Icons.payments_outlined,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => ctrl.recalcWorkers(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryPurple.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColor.primaryPurple.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'workers_total'.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "${formatMoney(total)} DA",
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.primaryPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else
                                CustemTextField(
                                  controller: ctrl.amountController,
                                  label: 'status'.tr == 'status'.tr
                                      ? 'amount_da'.tr
                                      : 'Amount (DA)',
                                  hint: '0.00',
                                  icon: Icons.monetization_on_outlined,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (val) {
                                    return validInput(val!, 1000, 1, "number");
                                  },
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Footer ──
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
                      onPressed: () => ctrl.saveExpense(),
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
                        isEdit ? 'save_changes'.tr : 'add_expense'.tr,
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
          ),
        ),
      ),
    );
  }
}
