import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/SubUsersController.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../data/model/RoleModel.dart';

void showSubUserFormDialog(BuildContext context, SubUsersController ctrl, {bool isArabic = true}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;
  final colors = theme.extension<AppColors>()!;
  final textColor = theme.colorScheme.onSurface;
  final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

  Get.dialog(
    Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ctrl.isEdit
                        ? (isArabic ? 'تعديل موظف' : 'Edit Staff')
                        : (isArabic ? 'إضافة موظف جديد' : 'Add New Staff'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Username
              Text(
                isArabic ? 'اسم الموظف' : 'Staff Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl.usernameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: isArabic ? 'أدخل اسم الموظف' : 'Enter staff name',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
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
                    borderSide: const BorderSide(color: AppColor.primaryPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email
              Text(
                isArabic ? 'البريد الإلكتروني' : 'Email',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl.emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: isArabic ? 'أدخل البريد الإلكتروني' : 'Enter email',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
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
                    borderSide: const BorderSide(color: AppColor.primaryPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              Text(
                isArabic ? 'كلمة المرور' : 'Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              GetBuilder<SubUsersController>(
                builder: (controller) => TextField(
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordHidden,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: controller.isEdit 
                      ? (isArabic ? 'اتركه فارغاً للاحتفاظ بكلمة المرور الحالية' : 'Leave blank to keep current password')
                      : (isArabic ? 'أدخل كلمة المرور (6 أحرف على الأقل)' : 'Enter password (min 6 chars)'),
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () {
                        controller.togglePasswordVisibility();
                      },
                    ),
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
                      borderSide: const BorderSide(color: AppColor.primaryPurple, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Role Selection
              Text(
                isArabic ? 'الدور (الصلاحيات)' : 'Role (Permissions)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (ctrl.rolesController.allRoles.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Text(
                      isArabic ? 'يرجى إضافة أدوار أولاً من قسم الأدوار والصلاحيات' : 'Please add roles first from Roles & Permissions section',
                      style: const TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  );
                }

                return DropdownButtonFormField<int>(
                  value: ctrl.selectedRoleId?.value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
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
                      borderSide: const BorderSide(color: AppColor.primaryPurple, width: 2),
                    ),
                  ),
                  dropdownColor: theme.scaffoldBackgroundColor,
                  hint: Text(
                    isArabic ? 'اختر الدور' : 'Select Role',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  items: ctrl.rolesController.allRoles.map((RoleModel role) {
                    return DropdownMenuItem<int>(
                      value: role.id,
                      child: Text(
                        role.name ?? '',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ctrl.selectedRoleId = value.obs;
                      ctrl.update();
                    }
                  },
                );
              }),

              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      isArabic ? 'إلغاء' : 'Cancel',
                      style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      ctrl.saveUser();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isArabic ? 'حفظ' : 'Save',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
