import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/SiedBarController.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/core/constant/imageassets.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:zeffa/core/constant/routes.dart';
import 'package:zeffa/view/screen/Settings/EditProfileScreen.dart';
import 'package:zeffa/view/screen/Settings/SettingsPasswordDialog.dart';

class UserProfileDialog extends StatelessWidget {
  const UserProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Siedbarcontroller>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color textColor = isDark ? AppColor.white : AppColor.deepPurple;
    Color subtitleColor = isDark
        ? AppColor.textSecondary
        : Colors.grey.shade700;
    Color cardColor = isDark ? AppColor.surfaceDark : Colors.white;
    Color statusBgColor = isDark
        ? AppColor.deepPurple.withOpacity(0.2)
        : AppColor.primaryPurple.withOpacity(0.08);

    return Obx(() {
      String formattedDate = 'unspecified'.tr;
      if (controller.dateExperiment.value != null &&
          controller.dateExperiment.value!.isNotEmpty) {
        try {
          DateTime date = DateTime.parse(controller.dateExperiment.value!);
          formattedDate = DateFormat('dd MMMM yyyy', 'ar').format(date);
        } catch (e) {
          formattedDate = controller.dateExperiment.value!;
        }
      }

      String statusText = (controller.status.value ?? 0) >= 1
          ? 'status_active'.tr
          : 'status_inactive'.tr;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cardColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cover Image & Avatar Stack
              SizedBox(
                height: 180,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Cover Image
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColor.purpleGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Close Button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    // Avatar
                    Positioned(
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: () {
                            final path = controller.imagePath.value;
                            if (path != null &&
                                path.isNotEmpty &&
                                !path.startsWith('http') &&
                                File(path).existsSync()) {
                              return FileImage(File(path)) as ImageProvider;
                            }
                            return const AssetImage(Appimageassets.logo);
                          }(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      controller.hallname.value.isEmpty
                          ? 'hall_name_label'.tr
                          : controller.hallname.value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.name.value.isEmpty
                          ? 'ahmed_alsultan'.tr
                          : controller.name.value,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColor.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.emailofuser.value.isEmpty
                              ? "owner@luxvenue.com"
                              : controller.emailofuser.value,
                          style: TextStyle(fontSize: 14, color: subtitleColor),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: subtitleColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Account Status Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Right Side: Details
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryPurple.withOpacity(
                                    0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified_user_outlined,
                                  color: AppColor.deepPurple,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                textDirection: TextDirection.rtl,
                                children: [
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${'activation_end_date'.tr}: $formattedDate',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                     
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        // Edit Account Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              Get.dialog(const EditProfileDialog());
                            },
                            icon: Icon(
                              Icons.person_outline,
                              size: 18,
                              color: textColor,
                            ),
                            label: Text(
                              'edit_account'.tr,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Edit Password Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              Get.dialog(const SettingsPasswordDialog());
                            },
                            icon: Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: textColor,
                            ),
                            label: Text(
                              'edit_password'.tr,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.logout();
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          'logout'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
