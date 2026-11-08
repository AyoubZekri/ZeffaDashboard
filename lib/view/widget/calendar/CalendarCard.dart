import 'package:zeffa/core/functions/role_permissions.dart';
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
        final ___ = ctrl.selectedHallUuid.value;

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

        final Widget daysView = Column(
          key: const ValueKey('days'),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: ctrl.previousMonth,
                  // Chevrons mirror automatically in RTL, no manual swap needed
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColor.primaryPurple,
                  ),
                ),
                InkWell(
                  // Zoom out: show the months of the year
                  onTap: ctrl.toggleMonthsView,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${ctrl.getMonthName(month)} $year",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.zoom_out_rounded,
                          color: AppColor.primaryPurple,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: ctrl.nextMonth,
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColor.primaryPurple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children:
                  [
                    'sunday'.tr,
                    'monday'.tr,
                    'tuesday'.tr,
                    'wednesday'.tr,
                    'thursday'.tr,
                    'friday'.tr,
                    'saturday'.tr,
                  ].map((dayName) {
                    final isFriday = dayName == 'friday'.tr;

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
                    // Reserved day → booking details, free day → new reservation
                    onTap: (event != null && event['type'] == 'reserved')
                        ? () => ctrl.showBookingDetails(event)
                        : (hasRolePermission('add_reservation')
                              ? () => ctrl.addReservationForDate(currentDate)
                              : null),
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: ctrl.showMonthsView.value
              ? _buildMonthsView(context, year, month)
              : daysView,
        );
      }),
    );
  }

  /// Zoomed-out view: 12 months of [year], tap one to see its days
  Widget _buildMonthsView(BuildContext context, int year, int selectedMonth) {
    final now = DateTime.now();
    final bool compact = MediaQuery.of(context).size.width < 600;

    return Column(
      key: const ValueKey('months'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: ctrl.previousYear,
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColor.primaryPurple,
              ),
            ),
            InkWell(
              // Zoom back in on the current month
              onTap: ctrl.toggleMonthsView,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$year",
                      style: TextStyle(
                        fontSize: compact ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.zoom_in_rounded,
                      color: AppColor.primaryPurple,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: ctrl.nextYear,
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: AppColor.primaryPurple,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 12 : 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: compact ? 3 : 4,
            crossAxisSpacing: compact ? 8 : 12,
            mainAxisSpacing: compact ? 8 : 12,
            mainAxisExtent: compact ? 76 : 96,
          ),
          itemBuilder: (context, index) {
            final m = index + 1;
            final count = ctrl.reservationsInMonth(year, m);
            final isSelected = m == selectedMonth;
            final isCurrent = m == now.month && year == now.year;

            return InkWell(
              onTap: () => ctrl.selectMonth(m),
              borderRadius: BorderRadius.circular(12),
              splashColor: AppColor.primaryPurple.withValues(alpha: 0.1),
              child: Container(
                padding: EdgeInsets.all(compact ? 8 : 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.primaryPurple.withValues(alpha: 0.12)
                      : colors.inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected || isCurrent
                        ? AppColor.primaryPurple
                        : colors.borderColor,
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ctrl.getMonthName(m),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 13 : 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColor.primaryPurple
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: compact ? 4 : 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: count > 0
                            ? AppColor.primaryPurple.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'month_reservations_count'.trParams({
                          'count': count.toString(),
                        }),
                        style: TextStyle(
                          fontSize: compact ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          color: count > 0
                              ? AppColor.primaryPurple
                              : colors.subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
    final isDark = theme.brightness == Brightness.dark;
    final eventType = event?['type'] ?? 'available';
    Color cellBg = colors.inputFillColor;
    Border cellBorder = Border.all(color: colors.borderColor);

    if (eventType == 'reserved') {
      final period = event?['booking_period'];
      if (period == 3) {
        // Evening period booked (Indigo style)
        cellBg = Colors.indigo.withOpacity(0.05);
        cellBorder = Border.all(color: Colors.indigo.shade300);
      } else if (period == 4) {
        // Morning period booked (Orange style)
        cellBg = Colors.orange.withOpacity(0.05);
        cellBorder = Border.all(color: Colors.orange.shade300);
      } else {
        // Full day (1) or both periods booked (5) (Red style)
        cellBg = Colors.redAccent.withOpacity(0.05);
        cellBorder = Border.all(color: Colors.redAccent.shade200);
      }
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
            ],
          ),
          const Spacer(),
          // Event details
          if (eventType == 'reserved') ...[
            // Half-booked days: booked period icon + "+" hint (other period free)
            if (event?['booking_period'] == 3)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: colors.subtitleColor.withValues(alpha: 0.6),
                    size: 16,
                  ),
                  Icon(
                    Icons.nights_stay_rounded,
                    color: isDark ? Colors.indigo.shade300 : Colors.indigo,
                    size: 18,
                  ),
                ],
              )
            else if (event?['booking_period'] == 4)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: colors.subtitleColor.withValues(alpha: 0.6),
                    size: 16,
                  ),
                  Icon(
                    Icons.light_mode_rounded,
                    color: isDark ? Colors.orange.shade300 : Colors.orange,
                    size: 18,
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: isDark ? Colors.red.shade300 : Colors.red,
                  size: 18,
                ),
              ),
          ],
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
