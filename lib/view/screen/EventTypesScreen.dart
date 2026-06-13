import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/EventTypesController.dart';
import '../../core/constant/AppTheme.dart';
import '../../core/functions/dialogDelete.dart';
import '../widget/event_types/EventTypeCard.dart';
import '../widget/event_types/EventTypeFormDialog.dart';
import '../widget/event_types/EventTypesHeader.dart';

class EventTypesScreen extends StatelessWidget {
  const EventTypesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';
    
    // Inject/Find the EventTypesController
    final ctrl = Get.put(EventTypesController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Section Widget ──
              EventTypesHeader(
                onAddPressed: () {
                  Get.dialog(
                    const EventTypeFormDialog(),
                    barrierDismissible: true,
                  );
                },
              ),
              const SizedBox(height: 36),

              // ── Event Cards Grid Widget ──
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive column counts based on screen width
                    int crossAxisCount = 3;
                    if (constraints.maxWidth < 750) {
                      crossAxisCount = 1;
                    } else if (constraints.maxWidth < 1100) {
                      crossAxisCount = 2;
                    }

                    return Obx(() {
                      final eventTypes = ctrl.eventTypes;

                      return GridView.builder(
                        itemCount: eventTypes.length,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          mainAxisExtent: 260, // Fixed height for visual consistency
                        ),
                        itemBuilder: (context, index) {
                          final type = eventTypes[index];
                          final title = type['titleKey'] != '' ? type['titleKey'].toString().tr : type['titleCustom'].toString();

                          return EventTypeCard(
                            type: type,
                            onEdit: () {
                              Get.dialog(
                                EventTypeFormDialog(isEdit: true, item: type),
                                barrierDismissible: true,
                              );
                            },
                            onDelete: () {
                              dialogDelete(
                                title: 'delete_confirm_btn'.tr,
                                content: "${'delete_event_confirm'.tr} ($title)؟",
                                onConfirm: () {
                                  ctrl.deleteEventType(type['uuid'] as String);
                                  Get.snackbar(
                                    'success'.tr,
                                    'event_type_deleted_success'.tr,
                                    backgroundColor: theme.brightness == Brightness.dark
                                        ? const Color(0xFF1B5E20)
                                        : const Color(0xFFE8F5E9),
                                    colorText: theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.green.shade900,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    });
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
