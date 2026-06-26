import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/ServicesController.dart';
import '../../core/constant/AppTheme.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/functions/dialogDelete.dart';
import '../widget/services/ServiceFormDialog.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';

    Get.delete<ServicesController>();
    final ctrl = Get.put(ServicesController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Widget
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'additional_services'.tr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'manage_services_desc'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ctrl.clearForm();
                      Get.dialog(const ServiceFormDialog(), barrierDismissible: true);
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(
                      'add_service'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Responsive Services Grid
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 3;
                    if (constraints.maxWidth < 750) {
                      crossAxisCount = 2;
                    } else if (constraints.maxWidth < 1100) {
                      crossAxisCount = 3;
                    } else {
                      crossAxisCount = 4;
                    }

                    return GetBuilder<ServicesController>(
                      builder: (controller) {
                        final services = controller.allServices;

                        if (services.isEmpty) {
                          return Center(
                            child: Text(
                              'no_services_found'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                color: colors.subtitleColor,
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          itemCount: services.length,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            mainAxisExtent: 180,
                          ),
                          itemBuilder: (context, index) {
                            final service = services[index];
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: colors.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: colors.borderColor),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                        ),
                                      ),
                                      const Spacer(),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert, color: colors.subtitleColor),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            ctrl.setEditData(service);
                                            Get.dialog(
                                              const ServiceFormDialog(isEdit: true),
                                              barrierDismissible: true,
                                            );
                                          } else if (value == 'delete') {
                                            dialogDelete(
                                              title: 'delete_confirm_btn'.tr,
                                              content: 'delete_service_confirm_title'.tr,
                                              onConfirm: () {
                                                ctrl.deleteService(service.uuid!);
                                              },
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                const Icon(Icons.edit_outlined, size: 20),
                                                const SizedBox(width: 8),
                                                Text('edit'.tr),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                                const SizedBox(width: 8),
                                                Text('delete'.tr, style: const TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    service.name ?? "",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${service.price?.toInt()} DA",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.primaryPurple,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
