import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/EventTypesController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustemTextField.dart';

class EventTypeFormDialog extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? item;

  const EventTypeFormDialog({super.key, this.isEdit = false, this.item});

  @override
  State<EventTypeFormDialog> createState() => _EventTypeFormDialogState();
}

class _EventTypeFormDialogState extends State<EventTypeFormDialog> {
  late EventTypesController ctrl;
  bool get isEdit => widget.isEdit;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<EventTypesController>();
    if (isEdit && widget.item != null) {
      ctrl.setEditData(widget.item!);
    } else {
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
          width: 580,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                            isEdit ? 'edit_event_type'.tr : 'add_new_type'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEdit
                                ? 'edit_event_type_desc'.tr
                                : 'add_event_type_desc'.tr,
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

              // ── Form Content ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: ctrl.formState,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Selection Section
                        Text(
                          'select_party_icon'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          final currentSelected = isEdit
                              ? ctrl.editSelectedIcon.value
                              : ctrl.selectedIcon.value;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: ctrl.availableIcons.map((icon) {
                                final isSelected = currentSelected == icon;
                                return InkWell(
                                  onTap: () {
                                    if (isEdit) {
                                      ctrl.editSelectedIcon.value = icon;
                                    } else {
                                      ctrl.selectedIcon.value = icon;
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColor.primaryPurple.withOpacity(
                                              0.15,
                                            )
                                          : (isDark
                                                ? Colors.white.withOpacity(0.04)
                                                : const Color(0xFFF8F9FA)),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColor.primaryPurple
                                            : borderColor,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: isSelected
                                          ? AppColor.primaryPurple
                                          : subtitleColor,
                                      size: 22,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),

                        // Event Type Name Field
                        CustemTextField(
                          controller: isEdit
                              ? ctrl.editTypeName
                              : ctrl.typeName,
                          label: 'event_type_name'.tr,
                          hint: 'event_type_name'.tr,
                          icon: Icons.title_rounded,
                          validator: (val) {
                            return validInput(val!, 100, 1, "text");
                          },
                        ),
                        const SizedBox(height: 20),

                        // Price Field
                        CustemTextField(
                          controller: isEdit
                              ? ctrl.editTypePrice
                              : ctrl.typePrice,
                          label: 'base_price'.tr,
                          hint: 'price_hint'.tr,
                          icon: Icons.attach_money_rounded,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            return validInput(val!, 100, 1, "decimal");
                          },
                        ),
                        const SizedBox(height: 20),

                        // Seasonal Price Field
                        CustemTextField(
                          controller: isEdit
                              ? ctrl.editTypeSeasonalPrice
                              : ctrl.typeSeasonalPrice,
                          label: 'seasonal_price'.tr,
                          hint: 'enter_seasonal_price'.tr,
                          icon: Icons.price_change_rounded,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            return validInput(val!, 100, 1, "decimal");
                          },
                        ),
                        const SizedBox(height: 20),

                        // Description Field
                        CustemTextField(
                          controller: isEdit
                              ? ctrl.editTypeDesc
                              : ctrl.typeDesc,
                          label: 'description'.tr,
                          hint: 'notes_hint'.tr,
                          icon: Icons.description_outlined,
                          maxLines: 3,
                          validator: (val) {
                            return validInput(
                              val!,
                              1000,
                              1,
                              "text",
                              empty: true,
                            );
                          },
                        ),
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
                      onPressed: () {
                        if (!ctrl.formState.currentState!.validate()) return;

                        if (isEdit) {
                          ctrl.updateEventType(widget.item!['uuid'] as String);
                        } else {
                          ctrl.addEventType();
                        }
                        Get.back();
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
                        isEdit ? 'save_changes'.tr : 'add_new_type'.tr,
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
