import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/class/Sqldb.dart';
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
  final SQLDB _db = SQLDB();
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

    fridaysOccupied.value = "$totalFridays";
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
      
      // Fetch actual reservations directly from SQLite
      final int userId = specialDatesRepo.id;
      final List<Map<String, dynamic>> resResult = await _db.readData(
        '''
        SELECT 
          r.uuid,
          r.id,
          r.username,
          r.phone_numper,
          r.booking_date,
          r.booking_period,
          pt.name AS event_type
        FROM reservations r
        LEFT JOIN party_types pt ON r.type_of_party_uuid = pt.uuid
        WHERE r.user_id = ?
        ''',
        [userId],
      );

      final loadedSeasons = <Map<String, dynamic>>[];
      final loadedSpecialDays = <Map<String, dynamic>>[];

      if (result.isNotEmpty) {
        final models = SpecialDateModel.fromList(result);

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
              'eventType': 'special_period'.tr,
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
      }

      // Add actual reservations to loadedSpecialDays
      for (var res in resResult) {
        final String? dateStr = res['booking_date'];
        if (dateStr == null || dateStr.isEmpty) continue;

        String normalizedDate = dateStr;
        try {
          final parsedDate = DateTime.parse(dateStr.replaceAll('/', '-'));
          normalizedDate = "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
        } catch (e) {
          // ignore/fallback
        }

        loadedSpecialDays.add({
          'uuid': res['uuid'],
          'title': res['event_type'] ?? 'حجز',
          'type': 'reserved',
          'booking_period': res['booking_period'],
          'date': normalizedDate,
          'customerName': res['username'] ?? '',
          'customerPhone': res['phone_numper'] ?? '',
          'bookingId': res['id'] != null ? '#${res['id']}' : '',
        });
      }

      seasons.assignAll(loadedSeasons);
      specialDays.assignAll(loadedSpecialDays);

      // Combine them for the table, filtering out 'reserved' since they come from actual reservations
      allDates.assignAll([
        ...loadedSeasons,
        ...loadedSpecialDays.where((e) => e['type'] != 'reserved'),
      ]);

      if (seasons.isEmpty && specialDays.isEmpty) {
        statusrequest = Statusrequest.none;
      } else {
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
    if (!formState.currentState!.validate()) {
      return false;
    }
    if (selectedDate.value == null) {
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
    if (!formState.currentState!.validate()) {
      return false;
    }
    if (selectedStartDate.value == null || selectedEndDate.value == null) {
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

    if (!formState.currentState!.validate()) {
      return false;
    }

    bool success = false;

    if (isPeriodMode.value) {
      if (selectedStartDate.value == null || selectedEndDate.value == null) {
        return false;
      }

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
      if (selectedDate.value == null) {
        return false;
      }

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
    final List<Map<String, dynamic>> matches = [];
    
    // Find all matching items in specialDays
    for (final event in specialDays) {
      if (event['date'] != null) {
        final eventDate = DateTime.parse(event['date']);
        if (eventDate.year == date.year &&
            eventDate.month == date.month &&
            eventDate.day == date.day) {
          matches.add(event);
        }
      }
    }

    if (matches.isNotEmpty) {
      final reservations = matches.where((e) => e['type'] == 'reserved').toList();
      if (reservations.isNotEmpty) {
        // If there's a full day booking
        if (reservations.any((r) => r['booking_period'] == 1)) {
          return {
            'type': 'reserved',
            'booking_period': 1,
            'reservations': reservations,
          };
        }
        
        // If there are two reservations (morning & evening)
        if (reservations.length >= 2) {
          return {
            'type': 'reserved',
            'booking_period': 5, // custom code for both periods booked
            'reservations': reservations,
          };
        }
        
        // If there is only one reservation
        final singleRes = reservations.first;
        return {
          'type': 'reserved',
          'booking_period': singleRes['booking_period'],
          'reservations': [singleRes],
        };
      }
      
      // If no reservations, return the first special day (special_day/friday)
      return matches.first;
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

    if (count > 15) return 'excellent'.tr;
    if (count == 15) return 'average'.tr;
    if (count >= 5 && count < 15) return 'below_average'.tr;
    return 'bad'.tr; // < 5
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
      'january'.tr,
      'february'.tr,
      'march'.tr,
      'april'.tr,
      'may'.tr,
      'june'.tr,
      'july'.tr,
      'august'.tr,
      'september'.tr,
      'october'.tr,
      'november'.tr,
      'december'.tr,
    ];
    return "${date.day} ${months[date.month - 1]}";
  }

  // Month names
  String getMonthName(int monthNum) {
    final monthsAr = [
      'january'.tr,
      'february'.tr,
      'march'.tr,
      'april'.tr,
      'may'.tr,
      'june'.tr,
      'july'.tr,
      'august'.tr,
      'september'.tr,
      'october'.tr,
      'november'.tr,
      'december'.tr,
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
