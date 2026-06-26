import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/RolesController.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/constant/AppTheme.dart';
import '../widget/roles/RoleFormDialog.dart';
import '../widget/shared/CustomHandlingView.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RolesController ctrl = Get.put(RolesController());
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
                  isArabic ? 'إدارة الأدوار والصلاحيات' : 'Roles & Permissions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ctrl.clearFields();
                    showRoleFormDialog(context, ctrl, isArabic: isArabic);
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    isArabic ? 'إضافة دور جديد' : 'Add New Role',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Body (List of Roles)
            Expanded(
              child: GetBuilder<RolesController>(builder: (controller) {
                return CustomHandlingView(
                  statusRequest: controller.statusrequest,
                  child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350,
                    mainAxisExtent: 200,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: controller.allRoles.length,
                  itemBuilder: (context, index) {
                    final role = controller.allRoles[index];
                    final isFull = role.type == 'full';
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: colors.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isFull ? Colors.green : Colors.orange).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFull ? Icons.verified_user_rounded : Icons.admin_panel_settings_outlined,
                                  color: isFull ? Colors.green : Colors.orange,
                                  size: 20,
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert_rounded, color: colors.subtitleColor),
                                color: colors.cardColor,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    ctrl.setEditData(role);
                                    showRoleFormDialog(context, ctrl, isArabic: isArabic);
                                  } else if (val == 'delete') {
                                    ctrl.deleteRole(role.id.toString());
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_rounded, size: 18, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Text('edit'.tr),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                                        const SizedBox(width: 8),
                                        Text(isArabic ? "حذف" : "Delete"),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const Spacer(),
                          Text(
                            role.name ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isFull 
                              ? (isArabic ? 'صلاحيات كاملة' : 'Full Access')
                              : (isArabic ? 'صلاحيات جزئية' : 'Partial Access'),
                            style: TextStyle(
                              fontSize: 13,
                              color: isFull ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            role.createdAt?.split('T')[0] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
