import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/Reservationscontroller.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/functions/Snacpar.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustemDropDownField.dart';
import '../CustemTextField.dart';
import 'ReservationDatePickerDialog.dart';

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
                  key: ctrl.formState,
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
                              hint: 'name_and_surname'.tr,
                              icon: Icons.badge_outlined,
                              validator: (val) {
                                return validInput(val!, 1000, 1, "Text");
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustemTextField(
                              controller: ctrl.phone,
                              label: 'phone_number'.tr,
                              hint: 'phone_number'.tr,
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
                      // Date field
                      CustemTextField(
                        controller: ctrl.date,
                        label: 'appointment_date'.tr,
                        hint: 'appointment_date'.tr,
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: () async {
                          final parsedDate = ctrl.date.text.isNotEmpty
                              ? DateTime.tryParse(ctrl.date.text.replaceAll('/', '-'))
                              : null;
                          final picked = await Get.dialog<DateTime>(
                            ReservationDatePickerDialog(
                              initialDate: parsedDate,
                              excludeUuid: isEdit ? widget.reservationUuid : null,
                              selectedPeriod: ctrl.BookingBeriod != null ? int.tryParse(ctrl.BookingBeriod!) : null,
                            ),
                          );
                          if (picked != null) {
                            final formatted =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            
                            setState(() {
                              ctrl.date.text = formatted;
                            });

                            // Check if current selected period is still available for the new date
                            final availablePeriods = ctrl.getAvailablePeriodsForDate(
                              formatted,
                              excludeUuid: isEdit ? widget.reservationUuid : null,
                            );
                            if (ctrl.BookingBeriod != null) {
                              final stillAvailable = availablePeriods.any((element) => element['key'] == ctrl.BookingBeriod);
                              if (!stillAvailable) {
                                setState(() {
                                  ctrl.BookingBeriod = null;
                                });
                              }
                            }

                            ctrl.calculatePrice();
                          }
                        },
                        validator: (val) {
                          return validInput(val!, 1000, 0, "date");
                        },
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
                              items: ctrl.getAvailablePeriodsForDate(
                                ctrl.date.text,
                                excludeUuid: isEdit ? widget.reservationUuid : null,
                              ),
                              onChanged: ctrl.date.text.isEmpty ? null : (val) {
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
                            child: _buildPartyTypeDropdownField(
                              label: 'event_type'.tr,
                              hint: 'select_event_type'.tr,
                              value: ctrl.typeOfPartyUuid,
                              items: ctrl.dbPartyTypes,
                              onChanged: ctrl.date.text.isEmpty ? null : (val) {
                                setState(() {
                                  ctrl.typeOfPartyUuid = val;
                                  ctrl.calculatePrice();
                                });
                              },
                              isDark: isDark,
                              inputFillColor: inputFillColor,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              borderColor: borderColor,
                            ),
                          ),
                        ],
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
                              onChanged: (_) => ctrl.calculatePrice(),
                              validator: (val) {
                                return validInput(
                                  val!,
                                  1000,
                                  1,
                                  "integer",
                                  empty: true,
                                );
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
                              onChanged: (_) => ctrl.calculatePrice(),
                              validator: (val) {
                                return validInput(
                                  val!,
                                  1000,
                                  1,
                                  "integer",
                                  empty: true,
                                );
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
                        child: Obx(() {
                          ctrl.selectedDishes.isEmpty; // Register listener
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ctrl.dbDishes.map((dish) {
                              final isSelected = ctrl.selectedDishes.contains(
                                dish.uuid,
                              );
                              return FilterChip(
                                selected: isSelected,
                                label: Text(
                                  dish.name ?? "",
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
                                      dish.uuid!,
                                    );
                                  } else {
                                    ctrl.selectedDishes.remove(
                                      dish.uuid!,
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      // ═══════════════════════════════════════
                      // Section 5.5: Additional Services Selection (Chips)
                      // ═══════════════════════════════════════
                      _buildSectionHeader(
                        Icons.room_service_outlined,
                        'additional_services'.tr,
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
                        child: Obx(() {
                          ctrl.selectedServices.isEmpty; // Register listener unconditionally
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ctrl.dbServices.map((service) {
                              final isSelected = ctrl.selectedServices.contains(
                                service.uuid,
                              );
                              return FilterChip(
                                selected: isSelected,
                                label: Text(
                                  "${service.name} (${service.price?.toInt()} DA)",
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
                                  Icons.add_circle_outline,
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
                                  double currentPrice = double.tryParse(ctrl.price.text) ?? 0.0;
                                  if (selected) {
                                    ctrl.selectedServices.add(service.uuid!);
                                    ctrl.price.text = (currentPrice + (service.price ?? 0.0)).toInt().toString();
                                  } else {
                                    ctrl.selectedServices.remove(service.uuid!);
                                    ctrl.price.text = (currentPrice - (service.price ?? 0.0)).toInt().toString();
                                  }
                                  ctrl.calculateRemaining(); // Update remaining amount
                                },
                              );
                            }).toList(),
                          );
                        }),
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
                          return validInput(val!, 3000, 1, "note", empty: true);
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
                      style: TextStyle(fontSize: 16, color: subtitleColor),
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
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?>? onChanged,
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
                  value: item['key'].toString(),
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
    required ValueChanged<String?>? onChanged,
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
                  value: item.uuid,
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
