import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/view/widget/roles/RoleFormDialog.dart'; // Just needed for styles/themes maybe
import '../../controller/SubUsersController.dart';
import '../../core/constant/AppTheme.dart';
import '../../core/constant/Colorapp.dart';
import '../widget/subusers/SubUserFormDialog.dart';
import '../widget/shared/CustomHandlingView.dart';

class SubUsersScreen extends StatelessWidget {
  const SubUsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SubUsersController ctrl = Get.put(SubUsersController());
    final isArabic = Get.locale?.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = theme.extension<AppColors>()!;
    final textColor = theme.colorScheme.onSurface;
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'إدارة المستخدمين' : 'User Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ctrl.clearFields();
                    showSubUserFormDialog(context, ctrl, isArabic: isArabic);
                  },
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  label: Text(
                    isArabic ? 'إضافة مستخدم' : 'Add User',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'إدارة حسابات المستخدمين وصلاحياتهم' : 'Manage user accounts and permissions',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Content
            Expanded(
              child: GetBuilder<SubUsersController>(
                builder: (controller) {
                  return CustomHandlingView(
                    statusRequest: controller.statusrequest,
                    child: GridView.builder(
                      itemCount: controller.allUsers.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 140,
                      ),
                      itemBuilder: (context, index) {
                        final user = controller.allUsers[index];
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColor.primaryPurple.withOpacity(0.1),
                                    child: const Icon(Icons.person, color: AppColor.primaryPurple),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.username ?? '',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email ?? '',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        ctrl.setEditData(user);
                                        showSubUserFormDialog(context, ctrl, isArabic: isArabic);
                                      } else if (val == 'delete') {
                                        ctrl.deleteUser(user.id.toString());
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.edit, size: 18, color: Colors.blue),
                                            const SizedBox(width: 8),
                                            Text(isArabic ? 'تعديل' : 'Edit'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete, size: 18, color: Colors.red),
                                            const SizedBox(width: 8),
                                            Text(isArabic ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shield_outlined, size: 14, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Text(
                                      user.roleDetails?.name ?? (isArabic ? 'بدون دور' : 'No Role'),
                                      style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
