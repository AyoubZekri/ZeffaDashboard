import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/controller/Settings/EditProfileController.dart';
import 'package:zeffa/core/constant/Colorapp.dart';
import 'package:zeffa/core/constant/imageassets.dart';
import 'package:zeffa/view/widget/CustemTextField.dart';

import '../../../core/class/Statusrequest.dart';
import '../../../core/functions/valiedinput.dart';

class EditProfileDialog extends StatelessWidget {
  const EditProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Get.delete<EditProfileController>();
    Get.put(EditProfileController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color textColor = isDark ? AppColor.white : AppColor.deepPurple;
    Color cardColor = isDark ? AppColor.surfaceDark : Colors.white;

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
            // Dialog Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تعديل الحساب'.tr,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18, color: textColor),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: GetBuilder<EditProfileController>(
                builder: (controller) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: controller.formstate,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Profile Image Edit
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColor.primaryPurple,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: controller.profileImage != null
                                        ? Image.file(
                                            controller.profileImage!,
                                            fit: BoxFit.cover,
                                          )
                                        : (controller.currentImagePath !=
                                                      null &&
                                                  controller
                                                      .currentImagePath!
                                                      .isNotEmpty &&
                                                  !controller.currentImagePath!
                                                      .startsWith('http') &&
                                                  File(
                                                    controller
                                                        .currentImagePath!,
                                                  ).existsSync()
                                              ? Image.file(
                                                  File(
                                                    controller
                                                        .currentImagePath!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  Appimageassets.logo,
                                                  fit: BoxFit.cover,
                                                )),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () => controller.pickImage(),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryPurple,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: cardColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Fields
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: CustemTextField(
                              controller: controller.hallname,
                              label: 'اسم القاعة'.tr,
                              hint: 'أدخل اسم القاعة'.tr,
                              icon: Icons.business_outlined,
                              validator: (val) {
                                return validInput(val!, 100, 1, "Text");
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: CustemTextField(
                              controller: controller.username,
                              label: 'اسم صاحب القاعة'.tr,
                              hint: 'أدخل اسم المالك'.tr,
                              icon: Icons.person_outline,
                              validator: (val) {
                                return validInput(val!, 100, 1, "Text");
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: CustemTextField(
                              controller: controller.phone,
                              label: 'رقم الهاتف'.tr,
                              hint: 'أدخل رقم الهاتف'.tr,
                              icon: Icons.phone_android_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                return validInput(val!, 15, 10, "phone");
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: CustemTextField(
                              controller: controller.fieldPhone,
                              label: 'field_phone'.tr,
                              hint: 'enter_field_phone'.tr,
                              icon: Icons.phone_android_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                return validInput(
                                  val!,
                                  15,
                                  10,
                                  "phone",
                                  empty: true,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: CustemTextField(
                              controller: controller.adresse,
                              label: 'العنوان'.tr,
                              hint: 'أدخل عنوان القاعة'.tr,
                              icon: Icons.location_on_outlined,
                              validator: (val) {
                                return validInput(val!, 200, 1, "Text");
                              },
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => controller.updateProfile(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryPurple,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  controller.statusrequest ==
                                      Statusrequest.loadeng
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'حفظ التعديلات'.tr,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
