import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import '../../data/datasource/Remote/SpecialDates.dart';
import '../../data/model/SpecialDateModel.dart';
import '../view/widget/calendar/BookingDetailsDialog.dart';

class CalendarController extends GetxController {
  // Navigation
  RxInt currentMonth = 10.obs; // October
  RxInt currentYear = 2024.obs;

  // Dialog tab mode (false = Special Day, true = Period/Season)
  RxBool isPeriodMode = false.obs;

  // Form Controllers
  late TextEditingController eventNameController;

  RxInt totalBookings = 0.obs;
  RxString fridaysOccupied = "".obs;

  Rxn<DateTime> selectedDate = Rxn<DateTime>();
  Rxn<DateTime> selectedStartDate = Rxn<DateTime>();
  Rxn<DateTime> selectedEndDate = Rxn<DateTime>();

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  // Special Dates Data Source
  late SpecialDates specialDatesRepo;
  Statusrequest statusrequest = Statusrequest.none;

  // Seasons (special_period)
  final RxList<Map<String, dynamic>> seasons = <Map<String, dynamic>>[].obs;

  // Special Days (special_day, friday, reserved)
  final RxList<Map<String, dynamic>> specialDays = <Map<String, dynamic>>[].obs;

  // All custom dates for the table (Seasons + Special Days)
  final RxList<Map<String, dynamic>> allDates = <Map<String, dynamic>>[].obs;

  // Editing state
  RxnString editingUuid = RxnString();

  @override
  void onInit() {
    specialDatesRepo = SpecialDates(Get.find());
    eventNameController = TextEditingController();

    final now = DateTime.now();
    currentMonth.value = now.month;
    currentYear.value = now.year;

    loadCalendarData();
    updateMonthlyStats();
    super.onInit();
  }

  Future<void> updateMonthlyStats() async {
    final count = await specialDatesRepo.getReservationsCountForMonth(
      currentYear.value,
      currentMonth.value,
    );
    totalBookings.value = count;

    // Calculate Fridays
    int totalFridays = 0;
    int daysInMonth = DateUtils.getDaysInMonth(
      currentYear.value,
      currentMonth.value,
    );
    for (int i = 1; i <= daysInMonth; i++) {
      if (DateTime(currentYear.value, currentMonth.value, i).weekday ==
          DateTime.friday) {
        totalFridays++;
      }
    }

    int occupiedFridays = 0;
    for (final day in specialDays) {
      if (day['date'] != null) {
        final d = DateTime.parse(day['date']);
        if (d.year == currentYear.value &&
            d.month == currentMonth.value &&
            d.weekday == DateTime.friday) {
          occupiedFridays++;
        }
      }
    }

    fridaysOccupied.value = "$occupiedFridays/$totalFridays";
  }

  @override
  void onClose() {
    eventNameController.dispose();
    super.onClose();
  }

  Future<void> loadCalendarData() async {
    statusrequest = Statusrequest.loadeng;
    update();
    try {
      final result = await specialDatesRepo.viewdata();
      if (result.isEmpty) {
        statusrequest = Statusrequest.none;
        seasons.clear();
        specialDays.clear();
        allDates.clear();
      } else {
        final models = SpecialDateModel.fromList(result);

        final loadedSeasons = <Map<String, dynamic>>[];
        final loadedSpecialDays = <Map<String, dynamic>>[];

        for (var item in models) {
          if (item.type == 'special_period') {
            loadedSeasons.add({
              'uuid': item.uuid,
              'nameKey': '',
              'nameCustom': item.title ?? '',
              'periodKey': '',
              'periodCustom': '${item.startDate} - ${item.endDate}',
              'start': item.startDate,
              'end': item.endDate,
              'type': 'special_period',
              'title': item.title ?? '',
              'eventType': 'فترة مميزة',
            });
          } else {
            loadedSpecialDays.add({
              'uuid': item.uuid,
              'title': item.title ?? '',
              'type': item.type ?? 'special_day',
              'date': item.date,
              'customerName': item.customerName ?? '',
              'customerPhone': item.customerPhone ?? '',
              'bookingId': item.bookingId != null ? '#${item.bookingId}' : '',
            });
          }
        }

        seasons.assignAll(loadedSeasons);
        specialDays.assignAll(loadedSpecialDays);

        // Combine them for the table, filtering out 'reserved' since they come from actual reservations
        allDates.assignAll([
          ...loadedSeasons,
          ...loadedSpecialDays.where((e) => e['type'] != 'reserved'),
        ]);

        statusrequest = Statusrequest.success;
      }
      updateMonthlyStats();
    } catch (e) {
      print("Error loading Calendar Data: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  // Clear dialog fields
  void clearFields() {
    editingUuid.value = null;
    eventNameController.clear();
    selectedDate.value = null;
    selectedStartDate.value = null;
    selectedEndDate.value = null;
  }

  // Pre-fill for edit
  void setEditData(Map<String, dynamic> item) {
    editingUuid.value = item['uuid'];
    final bool isSeason = item['type'] == 'special_period';
    isPeriodMode.value = isSeason;

    if (isSeason) {
      eventNameController.text = item['nameCustom'] ?? '';
      if (item['start'] != null)
        selectedStartDate.value = DateTime.parse(item['start']);
      if (item['end'] != null)
        selectedEndDate.value = DateTime.parse(item['end']);
    } else {
      eventNameController.text = item['title'] ?? '';
      if (item['date'] != null)
        selectedDate.value = DateTime.parse(item['date']);
    }
  }

  // Navigation Methods
  void nextMonth() {
    if (currentMonth.value == 12) {
      currentMonth.value = 1;
      currentYear.value++;
    } else {
      currentMonth.value++;
    }
    updateMonthlyStats();
  }

  void previousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value--;
    } else {
      currentMonth.value--;
    }
    updateMonthlyStats();
  }

  void jumpToDate(DateTime date) {
    currentMonth.value = date.month;
    currentYear.value = date.year;
    updateMonthlyStats();
  }

  // Add Special Day
  Future<bool> addSpecialDay() async {
    if (eventNameController.text.trim().isEmpty || selectedDate.value == null) {
      return false;
    }

    final isFriday = selectedDate.value!.weekday == DateTime.friday;
    final type = isFriday ? 'friday' : 'special_day';
    final dateStr = formatDate(selectedDate.value!);

    final success = await specialDatesRepo.AddSpecialDay(
      eventNameController.text.trim(),
      type,
      dateStr,
    );

    if (success) {
      clearFields();
      await loadCalendarData();
      return true;
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
      return false;
    }
  }

  // Add Seasonal Period
  Future<bool> addSeason() async {
    if (eventNameController.text.trim().isEmpty ||
        selectedStartDate.value == null ||
        selectedEndDate.value == null) {
      return false;
    }

    final startStr = formatDate(selectedStartDate.value!);
    final endStr = formatDate(selectedEndDate.value!);

    final success = await specialDatesRepo.AddSpecialPeriod(
      eventNameController.text.trim(),
      'special_period',
      startStr,
      endStr,
    );

    if (success) {
      clearFields();
      await loadCalendarData(); // Refresh and wait
      return true;
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
      return false;
    }
  }

  // Update Special Date
  Future<bool> updateSpecialDate() async {
    final uuid = editingUuid.value;
    if (uuid == null) return false;

    bool success = false;

    if (isPeriodMode.value) {
      if (eventNameController.text.trim().isEmpty ||
          selectedStartDate.value == null ||
          selectedEndDate.value == null)
        return false;

      final startStr = formatDate(selectedStartDate.value!);
      final endStr = formatDate(selectedEndDate.value!);

      success = await specialDatesRepo.Updatedata(
        uuid,
        eventNameController.text.trim(),
        'special_period',
        startDate: startStr,
        endDate: endStr,
      );
    } else {
      if (eventNameController.text.trim().isEmpty || selectedDate.value == null)
        return false;

      final isFriday = selectedDate.value!.weekday == DateTime.friday;
      final type = isFriday ? 'friday' : 'special_day';
      final dateStr = formatDate(selectedDate.value!);

      success = await specialDatesRepo.Updatedata(
        uuid,
        eventNameController.text.trim(),
        type,
        date: dateStr,
      );
    }

    if (success) {
      clearFields();
      await loadCalendarData(); // Refresh and wait
      return true;
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
      return false;
    }
  }

  // Delete Special Date
  Future<void> deleteSpecialDate(String uuid) async {
    final success = await specialDatesRepo.Deletedata(uuid);
    if (success) {
      await loadCalendarData();
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }

  Map<String, dynamic>? getEventForDate(DateTime date) {
    for (final event in specialDays) {
      if (event['date'] != null) {
        final eventDate = DateTime.parse(event['date']);
        if (eventDate.year == date.year &&
            eventDate.month == date.month &&
            eventDate.day == date.day) {
          return event;
        }
      }
    }

    for (final season in seasons) {
      if (season['start'] != null && season['end'] != null) {
        final start = DateTime.parse(season['start']);
        final end = DateTime.parse(season['end']);
        // Normalize time to compare just dates
        final checkDate = DateTime(date.year, date.month, date.day);
        final startDate = DateTime(start.year, start.month, start.day);
        final endDate = DateTime(end.year, end.month, end.day);

        if (!checkDate.isBefore(startDate) && !checkDate.isAfter(endDate)) {
          return season;
        }
      }
    }

    return null;
  }

  // Calculate Season Performance based on reservations count
  String getSeasonPerformance(Map<String, dynamic> item) {
    if (item['type'] != 'special_period') return '';
    if (item['start'] == null || item['end'] == null) return '';

    final start = DateTime.parse(item['start']);
    final end = DateTime.parse(item['end']);

    int count = 0;
    for (final day in specialDays) {
      if (day['type'] == 'reserved' && day['date'] != null) {
        final d = DateTime.parse(day['date']);
        // Normalize time to compare just dates
        final checkDate = DateTime(d.year, d.month, d.day);
        final startDate = DateTime(start.year, start.month, start.day);
        final endDate = DateTime(end.year, end.month, end.day);

        if (!checkDate.isBefore(startDate) && !checkDate.isAfter(endDate)) {
          count++;
        }
      }
    }

    if (count > 15) return 'ممتاز';
    if (count == 15) return 'متوسط';
    if (count >= 5 && count < 15) return 'دون المتوسط';
    return 'سيئ'; // < 5
  }

  void showBookingDetails(Map<String, dynamic> event) {
    Get.dialog(BookingDetailsDialog(event: event), barrierDismissible: true);
  }

  // Helper date formatters
  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String formatDateShort(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return "${date.day} ${months[date.month - 1]}";
  }

  // Month names
  String getMonthName(int monthNum) {
    final monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final monthsEn = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final isArabic = Get.locale?.languageCode == 'ar';
    return isArabic ? monthsAr[monthNum - 1] : monthsEn[monthNum - 1];
  }
}
