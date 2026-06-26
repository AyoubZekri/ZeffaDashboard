import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../controller/Reservationscontroller.dart';
import '../../../controller/CalendarController.dart';

class ReservationDatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final String? excludeUuid;
  final int? selectedPeriod;
  const ReservationDatePickerDialog({
    Key? key,
    this.initialDate,
    this.excludeUuid,
    this.selectedPeriod,
  }) : super(key: key);

  @override
  State<ReservationDatePickerDialog> createState() => _ReservationDatePickerDialogState();
}

class _ReservationDatePickerDialogState extends State<ReservationDatePickerDialog> {
  late int currentMonth;
  late int currentYear;
  late Reservationscontroller ctrl;
  late CalendarController calCtrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<Reservationscontroller>();
    calCtrl = Get.put(CalendarController());
    final initial = widget.initialDate ?? DateTime.now();
    currentMonth = initial.month;
    currentYear = initial.year;
  }

  void nextMonth() {
    setState(() {
      if (currentMonth == 12) {
        currentMonth = 1;
        currentYear++;
      } else {
        currentMonth++;
      }
    });
  }

  void previousMonth() {
    setState(() {
      if (currentMonth == 1) {
        currentMonth = 12;
        currentYear--;
      } else {
        currentMonth--;
      }
    });
  }

  Map<String, dynamic>? getDayBookingStatus(DateTime date) {
    final List<dynamic> matches = [];
    for (var res in ctrl.allReservations) {
      if (widget.excludeUuid != null && res.uuid == widget.excludeUuid) continue;
      try {
        final resDate = DateTime.parse(res.bookingDate.replaceAll('/', '-'));
        if (resDate.year == date.year &&
            resDate.month == date.month &&
            resDate.day == date.day) {
          matches.add(res);
        }
      } catch (e) {
        // ignore
      }
    }

    if (matches.isEmpty) return null;

    if (matches.any((r) => r.bookingPeriod == 1)) {
      return {'status': 'fully_booked', 'period': 1};
    }
    if (matches.length >= 2) {
      return {'status': 'fully_booked', 'period': 5};
    }
    final single = matches.first;
    return {'status': 'partially_booked', 'period': single.bookingPeriod};
  }

  String getMonthName(int monthNum) {
    final monthsAr = [
      'جانفي', 'فيفري', 'مارس', 'أفريل', 'ماي', 'جوان',
      'جويلية', 'أوت', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final monthsEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final isArabic = Get.locale?.languageCode == 'ar';
    return isArabic ? monthsAr[monthNum - 1] : monthsEn[monthNum - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isArabic = Get.locale?.languageCode == 'ar';

    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
    final totalDays = DateUtils.getDaysInMonth(currentYear, currentMonth);
    final offset = firstDayOfMonth.weekday % 7;

    final prevMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final prevYear = currentMonth == 1 ? currentYear - 1 : currentYear;
    final prevTotalDays = DateUtils.getDaysInMonth(prevYear, prevMonth);

    final int gridCount = offset + totalDays;
    final int rowsCount = (gridCount / 7).ceil();
    final int totalGridItems = rowsCount * 7;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          width: 500,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: previousMonth,
                      icon: Icon(
                        isArabic ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                        color: AppColor.primaryPurple,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(currentYear, currentMonth),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          initialDatePickerMode: DatePickerMode.year,
                        );
                        if (picked != null) {
                          setState(() {
                            currentMonth = picked.month;
                            currentYear = picked.year;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${getMonthName(currentMonth)} $currentYear",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: AppColor.primaryPurple,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: nextMonth,
                      icon: Icon(
                        isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                        color: AppColor.primaryPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    'sunday'.tr, 'monday'.tr, 'tuesday'.tr, 'wednesday'.tr, 'thursday'.tr, 'friday'.tr, 'saturday'.tr
                  ].map((dayName) {
                    final isFriday = dayName == 'friday'.tr;
                    return Expanded(
                      child: Center(
                        child: Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isFriday ? AppColor.primaryPurple : colors.subtitleColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 16),
                GetBuilder<CalendarController>(
                  builder: (calCtrl) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalGridItems,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        mainAxisExtent: 52,
                      ),
                      itemBuilder: (context, index) {
                        if (index < offset) {
                          final prevDay = prevTotalDays - offset + index + 1;
                          return Center(
                            child: Text(
                              "$prevDay",
                              style: TextStyle(
                                color: colors.subtitleColor.withOpacity(0.3),
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        if (index < offset + totalDays) {
                          final day = index - offset + 1;
                          final currentDate = DateTime(currentYear, currentMonth, day);
                          final isFriday = currentDate.weekday == DateTime.friday;
                          final status = getDayBookingStatus(currentDate);
                          final event = calCtrl.getEventForDate(currentDate);

                          Color cellBg = colors.inputFillColor;
                          Border cellBorder = Border.all(color: colors.borderColor);
                          Widget? iconWidget;
                          Widget? secondaryIcon;
                          bool isDisabled = false;

                          if (event != null && event['type'] != 'reserved') {
                            if (event['type'] == 'special_day') {
                              cellBg = Colors.orange.withOpacity(0.08);
                              cellBorder = Border.all(color: Colors.orange.withOpacity(0.4));
                              secondaryIcon = const Icon(Icons.star_rounded, color: Colors.orange, size: 14);
                            } else if (event['type'] == 'special_period') {
                              cellBg = AppColor.primaryPurple.withOpacity(0.08);
                              cellBorder = Border.all(color: AppColor.primaryPurple.withOpacity(0.4));
                              secondaryIcon = const Icon(Icons.auto_awesome_rounded, color: AppColor.primaryPurple, size: 14);
                            }
                          } else if (isFriday) {
                            cellBg = AppColor.primaryPurple.withOpacity(0.04);
                            cellBorder = Border.all(color: AppColor.primaryPurple.withOpacity(0.3));
                          }

                          if (status != null) {
                            final bookingStatus = status['status'];
                            final period = status['period'];

                            if (bookingStatus == 'fully_booked') {
                              cellBg = Colors.redAccent.withOpacity(0.06);
                              cellBorder = Border.all(color: Colors.redAccent.shade200);
                              iconWidget = const Icon(Icons.lock_outline_rounded, color: Colors.redAccent, size: 14);
                              isDisabled = true;
                            } else if (bookingStatus == 'partially_booked') {
                              if (period == 3) {
                                cellBg = Colors.indigo.withOpacity(0.06);
                                cellBorder = Border.all(color: Colors.indigo.shade300);
                                iconWidget = const Icon(Icons.nights_stay_rounded, color: Colors.indigo, size: 14);
                                
                                if (widget.selectedPeriod == 3 || widget.selectedPeriod == 1) {
                                  isDisabled = true;
                                }
                              } else if (period == 4) {
                                cellBg = Colors.orange.withOpacity(0.06);
                                cellBorder = Border.all(color: Colors.orange.shade300);
                                iconWidget = const Icon(Icons.light_mode_rounded, color: Colors.orange, size: 14);
                                
                                if (widget.selectedPeriod == 4 || widget.selectedPeriod == 1) {
                                  isDisabled = true;
                                }
                              }
                            }
                          }

                          if (isDisabled) {
                            cellBg = colors.inputFillColor.withOpacity(0.4);
                            cellBorder = Border.all(color: colors.borderColor.withOpacity(0.3));
                          }

                          return InkWell(
                            onTap: isDisabled
                                ? null
                                : () {
                                    Navigator.pop(context, currentDate);
                                  },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cellBg,
                                borderRadius: BorderRadius.circular(8),
                                border: cellBorder,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "$day",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDisabled
                                            ? colors.subtitleColor.withOpacity(0.4)
                                            : (isFriday
                                                ? AppColor.primaryPurple
                                                : theme.colorScheme.onSurface),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (secondaryIcon != null) secondaryIcon,
                                        if (iconWidget != null) iconWidget,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final nextDay = index - (offset + totalDays) + 1;
                        return Center(
                          child: Text(
                            "$nextDay",
                            style: TextStyle(
                              color: colors.subtitleColor.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
                const Divider(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('cancel'.tr, style: TextStyle(color: colors.subtitleColor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
