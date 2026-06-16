import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/Reservationscontroller.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustemDropDownField.dart';
import '../CustemTextField.dart';

enum ReservationFormMode { add, edit }

class ReservationFormDialog extends StatefulWidget {
  final bool isEdit;
  final Reservationscontroller? controller;
  final String? reservationUuid;

  const ReservationFormDialog({
    super.key,
    this.isEdit = false,
    this.controller,
    this.reservationUuid,
  });

  @override
  State<ReservationFormDialog> createState() => _ReservationFormDialogState();
}

class _ReservationFormDialogState extends State<ReservationFormDialog> {
  late Reservationscontroller ctrl;
  bool get isEdit => widget.isEdit;

  @override
  void initState() {
    super.initState();
    ctrl = widget.controller ?? Get.find<Reservationscontroller>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = colors.subtitleColor;
    final cardColor = colors.cardColor;
    final borderColor = colors.borderColor;
    final inputFillColor = colors.inputFillColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: bgColor,
      child: Container(
        width: 780,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
                          isEdit
                              ? 'edit_reservation'.tr
                              : 'add_new_reservation'.tr,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEdit
                              ? 'edit_reservation_desc'.tr
                              : 'add_new_reservation_desc'.tr,
                          style: TextStyle(fontSize: 13, color: subtitleColor),
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

            // ── Form Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ═══════════════════════════════════════
                      // Section 1: Customer Info
                      // ═══════════════════════════════════════
                      _buildSectionHeader(
                        Icons.person_outline_rounded,
                        'customer_info'.tr,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustemTextField(
                              controller: ctrl.username,
                              label: 'name_and_surname'.tr,
                              hint: 'name_hint'.tr,
                              icon: Icons.badge_outlined,
                              validator: (val) {
                                return validInput(val!, 1000, 1, "username");
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustemTextField(
                              controller: ctrl.phone,
                              label: 'phone_number'.tr,
                              hint: 'phone_hint'.tr,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                return validInput(val!, 13, 10, "phone");
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ═══════════════════════════════════════
                      // Section 2: Reservation Details (Dropdowns + Date)
                      // ═══════════════════════════════════════
                      _buildSectionHeader(
                        Icons.event_note_rounded,
                        'reservation_details_section'.tr,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Booking Period dropdown
                          Expanded(
                            child: _buildDropdownField(
                              label: 'reservation_period'.tr,
                              hint: 'select_period'.tr,
                              value: ctrl.BookingBeriod,
                              items: ctrl.bookingPeriods,
                              onChanged: (val) {
                                setState(() {
                                  ctrl.BookingBeriod = val;
                                });
                              },
                              isDark: isDark,
                              inputFillColor: inputFillColor,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              borderColor: borderColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Event Type dropdown
                          Expanded(
                            child: Obx(
                              () => _buildPartyTypeDropdownField(
                                label: 'event_type'.tr,
                                hint: 'select_event_type'.tr,
                                value: ctrl.typeOfPartyUuid,
                                items: ctrl.dbPartyTypes,
                                onChanged: (val) {
                                  if (ctrl.date.text.isEmpty) {
                                    Get.snackbar(
                                      'warning'.tr,
                                      'please_select_date_first_to_set_price'
                                          .tr,
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                  ctrl.typeOfPartyUuid = val;
                                  ctrl.calculatePrice();
                                },
                                isDark: isDark,
                                inputFillColor: inputFillColor,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                borderColor: borderColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Date field
                      CustemTextField(
                        controller: ctrl.date,
                        label: 'appointment_date'.tr,
                        hint: '2025/01/15',
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            final formatted =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            ctrl.date.text = formatted;
                            ctrl.calculatePrice();
                          }
                        },
                        validator: (val) {
                          return validInput(val!, 1000, 0, "date");
                        },
                      ),

                      const SizedBox(height: 28),

                      // ═══════════════════════════════════════
                      // Section 3: Guest Details
                      // ═══════════════════════════════════════
                      _buildSectionHeader(
                        Icons.people_alt_outlined,
                        'guest_details'.tr,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustemTextField(
                              controller: ctrl.numberofmen,
                              label: 'men_count'.tr,
                              hint: '0',
                              icon: Icons.man_outlined,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                return validInput(val!, 1000, 1, "number");
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustemTextField(
                              controller: ctrl.numberOfwomen,
                              label: 'women_count'.tr,
                              hint: '0',
                              icon: Icons.woman_outlined,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                return validInput(val!, 1000, 1, "number");
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ═══════════════════════════════════════
                      // Section 4: Financial Amounts
                      // ═══════════════════════════════════════
                      _buildSectionHeader(
                        Icons.payments_outlined,
                        'financial_amounts'.tr,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustemTextField(
                              controller: ctrl.price,
                              label: 'total_price'.tr,
                              hint: 'price_hint'.tr,
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                ctrl.calculateRemaining();
                              },
                              validator: (val) {
                                return validInput(val!, 1000, 1, "number");
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustemTextField(
                              controller: ctrl.deposit,
                              label: 'paid_amount'.tr,
                              hint: 'price_hint'.tr,
                              icon: Icons.savings_outlined,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                ctrl.calculateRemaining();
                              },
                              validator: (val) {
                                return validInput(val!, 1000, 1, "number");
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustemTextField(
                              controller: ctrl.remainingamount,
                              label: 'remaining_amount'.tr,
                              hint: 'price_hint'.tr,
                              icon: Icons.account_balance_wallet_outlined,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                return validInput(val!, 1000, 1, "number");
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ═══════════════════════════════════════
                      // Section 5: Dish Selection (Chips)
                      // ═══════════════════════════════════════
                      _buildSectionHeader(
                        Icons.restaurant_menu_rounded,
                        'select_dishes'.tr,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Obx(
                          () => Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ctrl.dbDishes.map((dish) {
                              final isSelected = ctrl.selectedDishes.contains(
                                dish['uuid'],
                              );
                              return FilterChip(
                                selected: isSelected,
                                label: Text(
                                  dish['name'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                              ? AppColor.textDark
                                              : AppColor.textLight),
                                  ),
                                ),
                                avatar: Icon(
                                  Icons.restaurant_menu, // fallback icon
                                  size: 18,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColor.primaryPurple,
                                ),
                                selectedColor: AppColor.primaryPurple,
                                checkmarkColor: Colors.white,
                                backgroundColor: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.white,
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColor.primaryPurple
                                      : borderColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    ctrl.selectedDishes.add(
                                      dish['uuid'] as String,
                                    );
                                  } else {
                                    ctrl.selectedDishes.remove(
                                      dish['uuid'] as String,
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ═══════════════════════════════════════
                      // Section 6: Additional Notes
                      // ═══════════════════════════════════════
                      CustemTextField(
                        controller: ctrl.note,
                        label: 'additional_notes'.tr,
                        hint: 'notes_hint'.tr,
                        maxLines: 4,
                        sectionHeaderTitle: 'additional_notes'.tr,
                        sectionHeaderIcon: Icons.sticky_note_2_outlined,
                        validator: (val) {
                          return validInput(val!, 3000, 1, "note");
                        },
                      ),
                      const SizedBox(height: 16),
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
                        fontSize: 16,
                        color: subtitleColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (isEdit && widget.reservationUuid != null) {
                        ctrl.updateReservation(widget.reservationUuid!);
                      } else {
                        ctrl.addReservation();
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
                      isEdit ? 'save_changes'.tr : 'add_reservation_btn'.tr,
                      style: const TextStyle(
                        fontSize: 16,
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
    );
  }

  // ═══════════════════════════════════════════════════════
  // Builder Helpers
  // ═══════════════════════════════════════════════════════

  Widget _buildSectionHeader(IconData icon, String title, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColor.primaryPurple, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required int? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
    required bool isDark,
    required Color inputFillColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        CustemDropDownField<int>(
          hint: hint,
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem<int>(
                  value: item['key'] as int,
                  child: Text(
                    (item['label'] as String).tr,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPartyTypeDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<dynamic> items, // dynamic because it's PartyTypeModel list
    required ValueChanged<String?> onChanged,
    required bool isDark,
    required Color inputFillColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        CustemDropDownField<String>(
          hint: hint,
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.uuid as String,
                  child: Text(
                    item.name,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
