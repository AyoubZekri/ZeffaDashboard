import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/CalendarController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import 'CalendarFormDialog.dart';

class SeasonsTable extends StatelessWidget {
  const SeasonsTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';
    final CalendarController ctrl = Get.find();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: AppColor.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'seasons_overview'.tr, // 'seasons_and_special_days_overview'.tr
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Table Headers
          Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'name'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.subtitleColor,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'period_label'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.subtitleColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'season_performance'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'actions_label'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.allDates.length,
              separatorBuilder: (context, index) => Column(
                children: [
                  const SizedBox(height: 12),
                  Divider(color: colors.borderColor, height: 1),
                  const SizedBox(height: 12),
                ],
              ),
              itemBuilder: (context, index) {
                final item = ctrl.allDates[index];
                final isSeason = item['type'] == 'special_period';

                final name = isSeason
                    ? (item['nameKey'] != ''
                          ? item['nameKey'].toString().tr
                          : item['nameCustom'].toString())
                    : item['title'].toString();

                final period = isSeason
                    ? (item['periodKey'] != ''
                          ? item['periodKey'].toString().tr
                          : item['periodCustom'].toString())
                    : item['date'].toString();

                return Row(
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: [
                    // Season/Day Name
                    Expanded(
                      flex: 3,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Period Duration / Date
                    Expanded(
                      flex: 3,
                      child: Text(
                        period,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.subtitleColor,
                        ),
                      ),
                    ),
                    // Performance
                    Expanded(
                      flex: 2,
                      child: Text(
                        isSeason ? ctrl.getSeasonPerformance(item) : '---',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(
                            isSeason ? ctrl.getSeasonPerformance(item) : '',
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Actions
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: AppColor.primaryPurple,
                              size: 20,
                            ),
                            onPressed: () {
                              ctrl.setEditData(item);
                              Get.dialog(
                                CalendarFormDialog(ctrl: ctrl),
                                barrierDismissible: true,
                              );
                            },
                            tooltip: 'edit'.tr,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () {
                              ctrl.deleteSpecialDate(item['uuid']);
                            },
                            tooltip: 'delete'.tr,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(String perf) {
    if (perf == 'excellent'.tr) return Colors.green;
    if (perf == 'average'.tr) return Colors.blue;
    if (perf == 'below_average'.tr) return Colors.orange;
    if (perf == 'bad'.tr) return Colors.red;
    return Colors.grey;
  }
}
