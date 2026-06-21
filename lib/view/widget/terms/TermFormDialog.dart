import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/TermsController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustemTextField.dart';

class TermFormDialog extends StatelessWidget {
  final bool isEdit;

  const TermFormDialog({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TermsController>();
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final bgColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = colors.subtitleColor;
    final borderColor = colors.borderColor;
    final isArabic = Get.locale?.languageCode == 'ar';

    final typesList = [
      {"key": "internal_rules", "label": "internal_rules".tr},
      {"key": "contract_terms", "label": "contract_terms".tr},
      {"key": "required_procedures", "label": "required_procedures".tr},
      {"key": "required_documents", "label": "required_documents".tr},
    ];

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
              // Header
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
                            : Icons.post_add_rounded,
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
                            isEdit ? 'edit_term'.tr : 'add_term'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEdit
                                ? 'edit_term_desc'.tr
                                : 'add_new_term_desc'.tr,
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

              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: ctrl.formState,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustemTextField(
                          controller: ctrl.titleController,
                          label: 'term_title'.tr,
                          hint: 'term_title'.tr,
                          icon: Icons.title_rounded,
                          validator: (val) {
                            return validInput(val!, 200, 1, "Text");
                          },
                        ),
                        const SizedBox(height: 24),

                        // Type dropdown
                        Text(
                          'term_type'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => DropdownButtonFormField<String>(
                            value: ctrl.selectedType.value,
                            dropdownColor: bgColor,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontFamily: 'Cairo',
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.category_rounded,
                                color: AppColor.primaryPurple,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: colors.inputFillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColor.primaryPurple,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            items: typesList.map((type) {
                              return DropdownMenuItem<String>(
                                value: type["key"],
                                child: Text(
                                  type["label"]!,
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ctrl.selectedType.value = val;
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Details Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isArabic
                                  ? "تفاصيل البند (نقاط تفصيلية)"
                                  : "Term Details (Bullet Points)",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: ctrl.addDetailField,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(
                                isArabic ? "إضافة تفصيل" : "Add Detail",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColor.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          if (ctrl.detailControllers.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: colors.inputFillColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: borderColor.withOpacity(0.5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  isArabic
                                      ? "لا توجد تفاصيل حالياً (اضغط إضافة تفصيل لإضافة نقاط)"
                                      : "No details added yet (click Add Detail to add points)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtitleColor,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: List.generate(
                              ctrl.detailControllers.length,
                              (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              ctrl.detailControllers[index],
                                          decoration: InputDecoration(
                                            hintText:
                                                '${isArabic ? "تفصيل" : "Detail"} ${index + 1}',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: borderColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: borderColor,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: AppColor.primaryPurple,
                                                width: 1.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: colors.inputFillColor,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                          ),
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        onPressed: () =>
                                            ctrl.removeDetailField(index),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                        ),
                                        tooltip: isArabic
                                            ? "حذف التفصيل"
                                            : "Delete Detail",
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
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
                      onPressed: () => ctrl.saveTerm(),
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
                        isEdit ? 'save_changes'.tr : 'add_term'.tr,
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
