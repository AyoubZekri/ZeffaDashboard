import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/RolesController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../CustemTextField.dart';

void showRoleFormDialog(BuildContext context, RolesController ctrl, {bool isArabic = true}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;
  final colors = theme.extension<AppColors>()!;
  final textColor = theme.colorScheme.onSurface;
  final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: colors.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ctrl.isEdit 
                      ? (isArabic ? 'تعديل الدور' : 'Edit Role') 
                      : (isArabic ? 'إضافة دور جديد' : 'Add New Role'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded, color: textColor),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.inputFillColor,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    CustemTextField(
                      controller: ctrl.nameController,
                      label: isArabic ? 'اسم الدور' : 'Role Name',
                      hint: isArabic ? 'مثال: مدير، موظف استقبال...' : 'e.g. Manager, Receptionist...',
                      icon: Icons.badge_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "مطلوب / Required";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      isArabic ? 'نوع الصلاحيات' : 'Permission Type',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => ctrl.selectedType.value = "full",
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: ctrl.selectedType.value == 'full' 
                                  ? AppColor.primaryPurple.withOpacity(0.1) 
                                  : Colors.transparent,
                                border: Border.all(
                                  color: ctrl.selectedType.value == 'full'
                                    ? AppColor.primaryPurple
                                    : borderColor,
                                  width: ctrl.selectedType.value == 'full' ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.verified_user_rounded,
                                    color: ctrl.selectedType.value == 'full' 
                                      ? AppColor.primaryPurple 
                                      : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isArabic ? "صلاحيات كاملة" : "Full Access",
                                    style: TextStyle(
                                      color: ctrl.selectedType.value == 'full' 
                                        ? AppColor.primaryPurple 
                                        : textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => ctrl.selectedType.value = "partial",
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: ctrl.selectedType.value == 'partial' 
                                  ? AppColor.primaryPurple.withOpacity(0.1) 
                                  : Colors.transparent,
                                border: Border.all(
                                  color: ctrl.selectedType.value == 'partial'
                                    ? AppColor.primaryPurple
                                    : borderColor,
                                  width: ctrl.selectedType.value == 'partial' ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_outlined,
                                    color: ctrl.selectedType.value == 'partial' 
                                      ? AppColor.primaryPurple 
                                      : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isArabic ? "صلاحيات جزئية" : "Partial Access",
                                    style: TextStyle(
                                      color: ctrl.selectedType.value == 'partial' 
                                        ? AppColor.primaryPurple 
                                        : textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                    
                    Obx(() {
                      if (ctrl.selectedType.value != 'partial') return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            isArabic ? 'صلاحيات الوصول' : 'Access Permissions',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.inputFillColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: ctrl.availablePermissions.map((permission) {
                                return CheckboxListTile(
                                  value: ctrl.selectedPermissions.contains(permission),
                                  onChanged: (val) => ctrl.togglePermission(permission),
                                  title: Text(
                                    permission.tr,
                                    style: TextStyle(color: textColor, fontSize: 14),
                                  ),
                                  activeColor: AppColor.primaryPurple,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  visualDensity: VisualDensity.compact,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: colors.cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      isArabic ? 'إلغاء' : 'Cancel',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ctrl.saveRole();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isArabic ? 'حفظ' : 'Save',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

