import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/HallsController.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustemTextField.dart';

class HallFormDialog extends StatelessWidget {
  final bool isEdit;
  const HallFormDialog({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HallsController>();
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final bgColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = colors.subtitleColor;
    final borderColor = colors.borderColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: bgColor,
      child: Container(
        width: 480,
        child: SingleChildScrollView(
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColor.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.meeting_room_outlined,
                        color: AppColor.primaryPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'edit_hall'.tr : 'add_hall'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: subtitleColor),
                    ),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: ctrl.formState,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustemTextField(
                        controller: ctrl.name,
                        label: 'hall_name_label'.tr,
                        hint: 'hall_name_label'.tr,
                        icon: Icons.meeting_room_outlined,
                        validator: (val) => validInput(val!, 100, 2, "text"),
                      ),
                      const SizedBox(height: 24),
                      CustemTextField(
                        controller: ctrl.phone1,
                        label: 'hall_phone1'.tr,
                        hint: 'hall_phone_optional'.tr,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                            validInput(val!, 13, 10, "phone", empty: true),
                      ),
                      const SizedBox(height: 24),
                      CustemTextField(
                        controller: ctrl.phone2,
                        label: 'hall_phone2'.tr,
                        hint: 'hall_phone_optional'.tr,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                            validInput(val!, 13, 10, "phone", empty: true),
                      ),
                      const SizedBox(height: 24),
                      CustemTextField(
                        controller: ctrl.address,
                        label: 'hall_location'.tr,
                        hint: 'hall_phone_optional'.tr,
                        icon: Icons.location_on_outlined,
                        validator: (val) =>
                            validInput(val!, 300, 2, "text", empty: true),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: GetBuilder<HallsController>(
                          builder: (_) {
                            return ElevatedButton(
                              onPressed: () {
                                if (isEdit) {
                                  ctrl.updateHall();
                                } else {
                                  ctrl.addHall();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: ctrl.statusrequest.name == "loadeng"
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isEdit ? 'save_changes'.tr : 'add_hall'.tr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
