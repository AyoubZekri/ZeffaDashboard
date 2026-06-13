import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/CalendarController.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/constant/Colorapp.dart';

class CalendarCard extends StatelessWidget {
  final CalendarController ctrl;
  final ThemeData theme;
  final AppColors colors;
  final bool isArabic;

  const CalendarCard({
    super.key,
    required this.ctrl,
    required this.theme,
    required this.colors,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Obx(() {
        // Explicitly read lengths to ensure Obx listens to changes in these lists
        final _ = ctrl.seasons.length;
        final __ = ctrl.specialDays.length;

        final year = ctrl.currentYear.value;
        final month = ctrl.currentMonth.value;

        final firstDayOfMonth = DateTime(year, month, 1);
        final totalDays = DateUtils.getDaysInMonth(year, month);

        final offset = firstDayOfMonth.weekday % 7;

        final prevMonth = month == 1 ? 12 : month - 1;
        final prevYear = month == 1 ? year - 1 : year;
        final prevTotalDays = DateUtils.getDaysInMonth(prevYear, prevMonth);

        final int gridCount = offset + totalDays;
        final int rowsCount = (gridCount / 7).ceil();
        final int totalGridItems = rowsCount * 7;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: ctrl.previousMonth,
                  icon: Icon(
                    isArabic
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    color: AppColor.primaryPurple,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(year, month),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDatePickerMode: DatePickerMode.year,
                    );
                    if (picked != null) {
                      ctrl.jumpToDate(picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          "${ctrl.getMonthName(month)} $year",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down_rounded, color: AppColor.primaryPurple),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: ctrl.nextMonth,
                  icon: Icon(
                    isArabic
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColor.primaryPurple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children:
                  [
                    'أحد',
                    'اثنين',
                    'ثلاثاء',
                    'أربعاء',
                    'خميس',
                    'جمعة',
                    'سبت',
                  ].map((dayName) {
                    final isFriday = dayName == 'جمعة';

                    return Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isFriday
                                  ? AppColor.primaryPurple
                                  : colors.subtitleColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const Divider(),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalGridItems,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 110,
              ),
              itemBuilder: (context, index) {
                if (index < offset) {
                  final prevDay = prevTotalDays - offset + index + 1;

                  return _buildEmptyCell(prevDay, colors);
                }

                if (index < offset + totalDays) {
                  final day = index - offset + 1;

                  final currentDate = DateTime(year, month, day);

                  final isFriday = currentDate.weekday == DateTime.friday;

                  final event = ctrl.getEventForDate(currentDate);
                  return InkWell(
                    onTap: (event != null && event['type'] == 'reserved')
                        ? () => ctrl.showBookingDetails(event)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    splashColor: AppColor.primaryPurple.withOpacity(0.1),
                    child: _buildDayCell(day, isFriday, event, theme, colors),
                  );
                }

                final nextDay = index - (offset + totalDays) + 1;

                return _buildEmptyCell(nextDay, colors);
              },
            ),

            if (month == 10 && year == 2024) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColor.primaryPurple.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wb_twilight_rounded,
                      color: AppColor.primaryPurple,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'season_autumn'.tr,
                      style: const TextStyle(
                        color: AppColor.primaryPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCell(int day, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        "$day",
        style: TextStyle(
          color: colors.subtitleColor.withOpacity(0.35),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDayCell(
    int day,
    bool isFriday,
    Map<String, dynamic>? event,
    ThemeData theme,
    AppColors colors,
  ) {
    // final hasEvent = event != null;
    final eventType = event?['type'] ?? 'available';
    Color cellBg = colors.inputFillColor;
    Border cellBorder = Border.all(color: colors.borderColor);

    if (eventType == 'reserved') {
      cellBg = Colors.redAccent.withOpacity(0.05);
      cellBorder = Border.all(color: Colors.redAccent);
    } else if (eventType == 'special_day') {
      cellBg = Colors.orange.withOpacity(0.08);
      cellBorder = Border.all(color: Colors.orange);
    } else if (eventType == 'special_period') {
      cellBg = AppColor.primaryPurple.withOpacity(0.08);
      cellBorder = Border.all(color: AppColor.primaryPurple);
    } else if (isFriday) {
      cellBg = AppColor.primaryPurple.withOpacity(0.05);
      cellBorder = Border.all(color: AppColor.primaryPurple);
    }

    return Container(
      decoration: BoxDecoration(
        color: cellBg,
        borderRadius: BorderRadius.circular(12),
        border: cellBorder,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day number & optional badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$day",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isFriday
                      ? AppColor.primaryPurple
                      : theme.colorScheme.onSurface,
                ),
              ),
              // if (isFriday)
              //   const Icon(
              //     Icons.star_rounded,
              //     color: AppColor.primaryPurple,
              //     size: 20,
              //   ),
            ],
          ),
          const Spacer(),
          // Event details
          if (eventType == 'reserved')
            const Icon(Icons.lock_outline_rounded, color: Colors.red),
          if (eventType == 'special_day')
            const Icon(Icons.star_rounded, color: Colors.orange),
          if (eventType == 'special_period')
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColor.primaryPurple,
            ),
        ],
      ),
    );
  }
}
