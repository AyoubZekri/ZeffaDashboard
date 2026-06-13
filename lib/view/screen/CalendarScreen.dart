import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/CalendarController.dart';
import '../../core/constant/AppTheme.dart';
import '../../core/constant/Colorapp.dart';
import '../widget/calendar/CalendarCard.dart';
import '../widget/calendar/CalendarFormDialog.dart';
import '../widget/calendar/CalendarGuide.dart';
import '../widget/calendar/CalendarHeader.dart';
import '../widget/calendar/CalendarStats.dart';
import '../widget/calendar/CalendarQuickActions.dart';
import '../widget/calendar/SeasonsTable.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';

    // Inject CalendarController
    final ctrl = Get.put(CalendarController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left Sidebar (Stats, Guide, Actions) ──
              SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const CalendarGuide(),
                      const SizedBox(height: 24),
                      Obx(() {
                        return CalendarStats(
                          monthName: ctrl.getMonthName(ctrl.currentMonth.value),
                          totalBookings: ctrl.totalBookings.value,
                          fridaysOccupied: ctrl.fridaysOccupied.value,
                        );
                      }),
                      // const SizedBox(height: 24),
                      // const CalendarQuickActions(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),

              // ── Right Main Area (Calendar & Seasons Table) ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Widget
                      CalendarHeader(
                        onAddPressed: () {
                          Get.dialog(
                            const CalendarFormDialog(),
                            barrierDismissible: true,
                          );
                        },
                        onExportPressed: () {
                          Get.snackbar(
                            'export_calendar'.tr,
                            'success'.tr,
                            backgroundColor: Colors.green.withOpacity(0.12),
                            colorText: Colors.green.shade900,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      const SizedBox(height: 36),

                      CalendarCard(
                        ctrl: ctrl,
                        theme: theme,
                        colors: colors,
                        isArabic: isArabic,
                      ),
                      const SizedBox(height: 36),
                      const SeasonsTable(),
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
