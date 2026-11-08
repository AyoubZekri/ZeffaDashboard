import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ServicesController.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustemTextField.dart';

class ServiceFormDialog extends StatelessWidget {
  final bool isEdit;
  const ServiceFormDialog({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ServicesController>();
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
        padding: const EdgeInsets.all(0),
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
                      Icons.room_service_outlined,
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
                          isEdit ? 'edit_service'.tr : 'add_new_service'.tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'service_form_desc'.tr,
                          style: TextStyle(fontSize: 13, color: subtitleColor),
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
                      label: 'service_name'.tr,
                      hint: 'service_name_hint'.tr,
                      icon: Icons.title_outlined,
                      validator: (val) => validInput(val!, 100, 2, "text"),
                    ),
                    const SizedBox(height: 24),
                    CustemTextField(
                      controller: ctrl.price,
                      label: 'service_price'.tr,
                      hint: '0.00',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (val) => validInput(val!, 20, 1, "decimal"),
                    ),
                    const SizedBox(height: 16),
                    // How the price is counted in a reservation
                    GetBuilder<ServicesController>(
                      builder: (_) {
                        Widget option(int type, IconData icon, String label) {
                          final selected = ctrl.priceType == type;
                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                ctrl.priceType = type;
                                ctrl.update();
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColor.primaryPurple
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      icon,
                                      size: 18,
                                      color: selected ? Colors.white : subtitleColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        label,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: selected ? Colors.white : subtitleColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colors.inputFillColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  option(0, Icons.sell_outlined, 'price_fixed'.tr),
                                  const SizedBox(width: 4),
                                  option(1, Icons.groups_outlined, 'price_per_person'.tr),
                                ],
                              ),
                            ),
                            if (ctrl.priceType == 1) ...[
                              const SizedBox(height: 8),
                              Text(
                                'price_per_person_note'.tr,
                                style: TextStyle(fontSize: 12, color: subtitleColor),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: GetBuilder<ServicesController>(
                        builder: (_) {
                          return ElevatedButton(
                            onPressed: () {
                              if (isEdit) {
                                ctrl.updateService();
                              } else {
                                ctrl.addService();
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
                                    isEdit ? 'save_changes'.tr : 'add_service'.tr,
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
    );
  }
}
