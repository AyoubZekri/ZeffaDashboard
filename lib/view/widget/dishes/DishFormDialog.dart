import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/DishesController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/functions/valiedinput.dart';
import '../../../data/model/DishCategoryModel.dart';
import '../CustemDropDownField.dart';
import '../CustemTextField.dart';

class DishFormDialog extends StatefulWidget {
  final bool isEdit;

  const DishFormDialog({super.key, this.isEdit = false});

  @override
  State<DishFormDialog> createState() => _DishFormDialogState();
}

class _DishFormDialogState extends State<DishFormDialog> {
  late DishesController ctrl;
  bool get isEdit => widget.isEdit;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(DishesController());
    // ctrl.clearFields();
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
    final inputFillColor = colors.inputFillColor;

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
                            isEdit ? 'edit_dish'.tr : 'add_new_dish'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEdit ? 'edit_dish_desc'.tr : 'add_dish_desc'.tr,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GetBuilder<DishesController>(
                          builder: (ctrl) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              height: 250,
                              width: 250,
                              decoration: BoxDecoration(
                                color: AppColor.lightBlue,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(width: 2),
                              ),
                              child: ctrl.file == null
                                  ? MaterialButton(
                                      onPressed: () {
                                        ctrl.uploadimagefile();
                                      },
                                      child: Text('add_image'.tr),
                                    )
                                  : Stack(
                                      children: [
                                        Center(
                                          child: SizedBox(
                                            height: 245,
                                            width: 245,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                ctrl.file!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              ctrl.uploadimagefile();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(
                          label: 'dish_category_label'.tr,
                          hint: 'choose_dish_category'.tr,
                          value: isEdit ? ctrl.editcatUuid : ctrl.catUuid,
                          items: ctrl.dishCategories,
                          onChanged: (val) {
                            setState(() {
                              if (isEdit) {
                                ctrl.editcatUuid = val;
                              } else {
                                ctrl.catUuid = val;
                              }
                            });
                          },
                          isDark: isDark,
                          inputFillColor: inputFillColor,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 20),
                        CustemTextField(
                          controller: isEdit ? ctrl.editName : ctrl.name,
                          label: 'dish_name'.tr,
                          hint: 'dish_name'.tr,
                          icon: Icons.flatware_rounded,
                          validator: (val) {
                            return validInput(val!, 100, 1, "name");
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
                        if (isEdit) {
                          ctrl.editdishes();
                        } else {
                          ctrl.adddishes();
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
                        isEdit ? 'save_changes'.tr : 'add_new_dish'.tr,
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

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<DishCategoryModel> items,
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
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.uuid as String,
                  child: Text(
                    (item.name as String).tr,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (val) {
            if (val == null) {
              return 'please_select_category'.tr;
            }
            return null;
          },
        ),
      ],
    );
  }
}
