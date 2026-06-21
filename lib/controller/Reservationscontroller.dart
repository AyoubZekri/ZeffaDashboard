import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/functions/Snacpar.dart';
import 'package:zeffa/data/model/ReservationModel.dart';

import '../core/class/Statusrequest.dart';
import '../core/services/Services.dart';
import '../data/datasource/Remote/ReservationsData.dart';
import '../data/datasource/Remote/PartyTypes.dart';
import '../data/datasource/Remote/Dishes.dart';
import '../data/datasource/Remote/SpecialDates.dart';
import '../data/model/PartyTypeModel.dart';
import '../data/model/SpecialDateModel.dart';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class Reservationscontroller extends GetxController {
  late final TextEditingController searchController;
  final RxString searchQuery = "".obs;

  final RxList<ReservationModel> allReservations = <ReservationModel>[].obs;

  // Filters
  final Rx<DateTime?> startDateFilter = Rx<DateTime?>(null);
  final Rx<DateTime?> endDateFilter = Rx<DateTime?>(null);

  List<ReservationModel> get filteredReservations {
    return allReservations.where((res) {
      // 1. Search Query
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchesName = res.customerName.toLowerCase().contains(query);
        final matchesPhone = res.phoneNumber.toLowerCase().contains(query);
        if (!matchesName && !matchesPhone) return false;
      }

      // 2. Date Filter
      if (startDateFilter.value != null || endDateFilter.value != null) {
        try {
          DateTime resDate = DateTime.parse(
            res.bookingDate.replaceAll('/', '-'),
          );
          DateTime normalizedResDate = DateTime(
            resDate.year,
            resDate.month,
            resDate.day,
          );

          if (startDateFilter.value != null) {
            DateTime sDate = startDateFilter.value!;
            DateTime nsDate = DateTime(sDate.year, sDate.month, sDate.day);
            if (normalizedResDate.isBefore(nsDate)) return false;
          }
          if (endDateFilter.value != null) {
            DateTime eDate = endDateFilter.value!;
            DateTime neDate = DateTime(eDate.year, eDate.month, eDate.day);
            if (normalizedResDate.isAfter(neDate)) return false;
          }
        } catch (e) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void clearDateFilter() {
    startDateFilter.value = null;
    endDateFilter.value = null;
  }

  Future<void> exportToExcel() async {
    try {
      statusrequest = Statusrequest.loadeng;
      update();

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = [
        'reservation_number'.tr,
        'customer_name'.tr,
        'phone_number'.tr,
        'payment_status'.tr,
        'reservation_date'.tr,
        'event_type_label'.tr,
        'gentlemen'.tr,
        'ladies'.tr,
        'paid_amount'.tr,
        'remaining_amount'.tr,
        'notes'.tr,
      ];

      sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

      for (var res in filteredReservations) {
        sheetObject.appendRow([
          TextCellValue(res.id?.toString() ?? res.uuid),
          TextCellValue(res.customerName),
          TextCellValue(res.phoneNumber),
          TextCellValue(res.statusKey.tr),
          TextCellValue(res.bookingDate),
          TextCellValue(res.typeOfPartyUuid),
          TextCellValue(res.numberOfMen.toString()),
          TextCellValue(res.numberOfWomen.toString()),
          TextCellValue(res.deposit.toString()),
          TextCellValue(res.remainingAmount.toString()),
          TextCellValue(res.notes ?? ''),
        ]);
      }

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        String filePath =
            '$selectedDirectory/reservations_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        var fileBytes = excel.save();
        if (fileBytes != null) {
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);
          showSnackbar(
            'success'.tr,
            'export_to_excel'.tr + ' ' + 'success'.tr,
            Colors.green,
          );
        }
      }
    } catch (e) {
      showSnackbar('error'.tr, e.toString(), Colors.red);
    } finally {
      statusrequest = Statusrequest.success;
      update();
    }
  }

  // Dynamic lists from DB
  final RxList<PartyTypeModel> dbPartyTypes = <PartyTypeModel>[].obs;
  final RxList<Map<String, dynamic>> dbDishes = <Map<String, dynamic>>[].obs;
  final RxList<SpecialDateModel> specialDates = <SpecialDateModel>[].obs;

  late TextEditingController username;
  late TextEditingController phone;
  late TextEditingController date;
  late TextEditingController numberofmen;
  late TextEditingController numberOfwomen;
  late TextEditingController price;
  late TextEditingController deposit;
  late TextEditingController remainingamount;
  late TextEditingController note;
  int? BookingBeriod;
  String? typeOfPartyUuid;

  // Selected dishes list state
  final RxList<String> selectedDishes = <String>[].obs;

  final List<Map<String, dynamic>> bookingPeriods = [
    {'key': 1, 'label': 'period_full_day'},
    {'key': 3, 'label': 'period_evening'},
    {'key': 4, 'label': 'period_morning'},
  ];

  late ReservationsData resData;
  late PartyTypes partyTypesData;
  late Dishes dishesData;
  late SpecialDates specialDatesData;

  Myservices myServices = Get.find();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  Statusrequest statusrequest = Statusrequest.none;

  @override
  void onInit() {
    searchController = TextEditingController();
    username = TextEditingController();
    phone = TextEditingController();
    date = TextEditingController();
    numberofmen = TextEditingController();
    numberOfwomen = TextEditingController();
    price = TextEditingController();
    deposit = TextEditingController();
    remainingamount = TextEditingController();
    note = TextEditingController();

    resData = ReservationsData(Get.find());
    partyTypesData = PartyTypes(myServices);
    dishesData = Dishes(myServices);
    specialDatesData = SpecialDates(myServices);

    fetchInitialData();

    super.onInit();
  }

  Future<void> fetchInitialData() async {
    statusrequest = Statusrequest.loadeng;
    update();

    try {
      // Fetch party types
      var pTypes = await partyTypesData.viewdata();
      print("🔍 PartyTypes fetched: ${pTypes.length} items");
      dbPartyTypes.assignAll(
        pTypes.map((e) => PartyTypeModel.fromJson(e)).toList(),
      );

      var dshs = await dishesData.viewdata();
      print("🔍 Dishes fetched: ${dshs.length} items");
      dbDishes.assignAll(List<Map<String, dynamic>>.from(dshs));

      // Fetch special dates
      var sDates = await specialDatesData.viewdata();
      print("🔍 SpecialDates fetched: ${sDates.length} items");
      specialDates.assignAll(
        sDates.map((e) => SpecialDateModel.fromJson(e)).toList(),
      );

      // Fetch reservations (now includes joined party_types + dishes data)
      var res = await resData.viewdata();
      print("🔍 Reservations fetched: ${res.length} items");
      if (res.isNotEmpty) print("🔍 First reservation: ${res.first}");
      allReservations.assignAll(
        List<ReservationModel>.from(
          res.map(
            (e) => ReservationModel.fromJson(Map<String, dynamic>.from(e)),
          ),
        ),
      );
      print(
        "🔍 allReservations.length after assign: ${allReservations.length}",
      );

      statusrequest = Statusrequest.success;
    } catch (e, st) {
      print("❌ fetchInitialData error: $e");
      print("❌ Stack trace: $st");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  // --- Price Calculation Logic ---
  void calculatePrice() {
    if (typeOfPartyUuid == null) return;

    final selectedParty = dbPartyTypes.firstWhereOrNull(
      (p) => p.name == typeOfPartyUuid,
    );
    if (selectedParty == null) return;

    double calculatedPrice = selectedParty.basicPrice!;

    if (date.text.isNotEmpty) {
      // Check if selected date is in a special period or special day
      DateTime selectedDate = DateTime.parse(date.text.replaceAll('/', '-'));
      DateTime normalizedSelected = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      bool isSpecial = false;

      for (var sd in specialDates) {
        if (sd.type == 'special_period' &&
            sd.startDate != null &&
            sd.endDate != null) {
          DateTime sDate = DateTime.parse(sd.startDate!);
          DateTime eDate = DateTime.parse(sd.endDate!);
          DateTime nsDate = DateTime(sDate.year, sDate.month, sDate.day);
          DateTime neDate = DateTime(eDate.year, eDate.month, eDate.day);
          if (!normalizedSelected.isBefore(nsDate) &&
              !normalizedSelected.isAfter(neDate)) {
            isSpecial = true;
            break;
          }
        } else if (sd.date != null) {
          DateTime d = DateTime.parse(sd.date!);
          DateTime nd = DateTime(d.year, d.month, d.day);
          if (normalizedSelected.isAtSameMomentAs(nd)) {
            isSpecial = true;
            break;
          }
        }
      }

      // Also consider Fridays as special if needed (optional logic, applying it based on user request)
      if (normalizedSelected.weekday == DateTime.friday) {
        isSpecial = true;
      }

      if (isSpecial) {
        calculatedPrice += selectedParty.seasonalPrice!;
      }
    }

    price.text = calculatedPrice.toString();
    calculateRemaining();
  }

  void calculateRemaining() {
    double p = double.tryParse(price.text) ?? 0.0;
    double d = double.tryParse(deposit.text) ?? 0.0;
    double rem = p - d;
    remainingamount.text = rem > 0 ? rem.toString() : '0.0';
  }

  String _generate13DigitNumber() {
    final Random random = Random();
    String number = (random.nextInt(9) + 1).toString();
    for (int i = 0; i < 8; i++) {
      number += random.nextInt(10).toString();
    }
    return number;
  }

  String? checkBookingConflict(
    String dateStr,
    int selectedPeriod, {
    String? excludeUuid,
  }) {
    if (dateStr.isEmpty) return null;
    try {
      final normalizedSelected = DateTime.parse(dateStr.replaceAll('/', '-'));
      final formattedSelected =
          "${normalizedSelected.year}-${normalizedSelected.month.toString().padLeft(2, '0')}-${normalizedSelected.day.toString().padLeft(2, '0')}";

      final List<int> bookedPeriods = [];
      for (var res in allReservations) {
        if (excludeUuid != null && res.uuid == excludeUuid) continue;

        try {
          final resDate = DateTime.parse(res.bookingDate.replaceAll('/', '-'));
          final formattedRes =
              "${resDate.year}-${resDate.month.toString().padLeft(2, '0')}-${resDate.day.toString().padLeft(2, '0')}";
          if (formattedSelected == formattedRes) {
            if (res.bookingPeriod != null) {
              bookedPeriods.add(res.bookingPeriod!);
            }
          }
        } catch (e) {
          // ignore
        }
      }

      if (bookedPeriods.isEmpty) {
        return null; // Date is completely free
      }

      // If already booked for full day, nothing else can be booked
      if (bookedPeriods.contains(1)) {
        return 'date_already_reserved'.tr;
      }

      // If selected period is full day (1), but there are already some bookings on that date, it is blocked
      if (selectedPeriod == 1 && bookedPeriods.isNotEmpty) {
        return 'date_already_reserved_period'.tr;
      }

      // If already booked for both morning and evening, nothing else can be booked
      if (bookedPeriods.contains(3) && bookedPeriods.contains(4)) {
        return 'date_already_reserved'.tr;
      }

      // If already booked for evening (3)
      if (bookedPeriods.contains(3)) {
        if (selectedPeriod == 3) {
          return 'evening_period_reserved'.tr;
        }
        if (selectedPeriod == 1) {
          return 'date_already_reserved_period'.tr;
        }
      }

      // If already booked for morning (4)
      if (bookedPeriods.contains(4)) {
        if (selectedPeriod == 4) {
          return 'morning_period_reserved'.tr;
        }
        if (selectedPeriod == 1) {
          return 'date_already_reserved_period'.tr;
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  List<Map<String, dynamic>> getAvailablePeriodsForDate(
    String dateStr, {
    String? excludeUuid,
  }) {
    if (dateStr.isEmpty) {
      return bookingPeriods;
    }

    try {
      final normalizedSelected = DateTime.parse(dateStr.replaceAll('/', '-'));
      final formattedSelected =
          "${normalizedSelected.year}-${normalizedSelected.month.toString().padLeft(2, '0')}-${normalizedSelected.day.toString().padLeft(2, '0')}";

      final List<int> bookedPeriods = [];
      for (var res in allReservations) {
        if (excludeUuid != null && res.uuid == excludeUuid) continue;

        try {
          final resDate = DateTime.parse(res.bookingDate.replaceAll('/', '-'));
          final formattedRes =
              "${resDate.year}-${resDate.month.toString().padLeft(2, '0')}-${resDate.day.toString().padLeft(2, '0')}";
          if (formattedSelected == formattedRes) {
            if (res.bookingPeriod != null) {
              bookedPeriods.add(res.bookingPeriod!);
            }
          }
        } catch (e) {
          // ignore
        }
      }

      if (bookedPeriods.isEmpty) {
        return bookingPeriods;
      }

      // If booked for full day (1), nothing is available
      if (bookedPeriods.contains(1)) {
        return [];
      }

      // If booked for both morning and evening, nothing is available
      if (bookedPeriods.contains(3) && bookedPeriods.contains(4)) {
        return [];
      }

      final List<Map<String, dynamic>> available = [];

      // If booked for evening (3), only morning (4) is available
      if (bookedPeriods.contains(3)) {
        available.addAll(bookingPeriods.where((p) => p['key'] == 4));
      }
      // If booked for morning (4), only evening (3) is available
      else if (bookedPeriods.contains(4)) {
        available.addAll(bookingPeriods.where((p) => p['key'] == 3));
      }

      return available;
    } catch (e) {
      return bookingPeriods;
    }
  }

  // عرض البيانات
  Future<void> addReservation() async {
    if (!formState.currentState!.validate()) {
      return;
    }

    if (typeOfPartyUuid == null || BookingBeriod == null) {
      showSnackbar(
        'warning'.tr,
        'please_fill_required_fields'.tr,
        Colors.orange,
      );
      return;
    }

    final String selectedDateStr = date.text.trim();
    final conflictError = checkBookingConflict(selectedDateStr, BookingBeriod!);
    if (conflictError != null) {
      showSnackbar('warning'.tr, conflictError, Colors.orange);
      return;
    }

    statusrequest = Statusrequest.loadeng;
    update();

    Map<String, dynamic> rawData = {
      "numperReservation": _generate13DigitNumber(),
      "username": username.text,
      "phone_numper": phone.text,
      "booking_date": date.text,
      "booking_period": BookingBeriod,
      "type_of_party_uuid": typeOfPartyUuid,
      "price": double.tryParse(price.text) ?? 0.0,
      "deposit": double.tryParse(deposit.text) ?? 0.0,
      "remaining_amount": double.tryParse(remainingamount.text) ?? 0.0,
      "number_of_men": int.tryParse(numberofmen.text) ?? 0,
      "number_of_women": int.tryParse(numberOfwomen.text) ?? 0,
      "notes": note.text,
    };

    bool success = await resData.Adddata(rawData, selectedDishes);
    if (success) {
      Get.back();

      fetchInitialData();

      username.clear();
      phone.clear();
      date.clear();
      price.clear();
      deposit.clear();
      remainingamount.clear();
      numberofmen.clear();
      numberOfwomen.clear();
      note.clear();
      BookingBeriod = null;
      typeOfPartyUuid = null;
      selectedDishes.clear();
    } else {
      showSnackbar('error'.tr, 'failed_to_save_reservation'.tr, Colors.red);
    }

    statusrequest = Statusrequest.success;
    update();
  }

  void setEditData(ReservationModel res) async {
    username.text = res.customerName;
    phone.text = res.phoneNumber;
    date.text = res.bookingDate.replaceAll('/', '-');
    BookingBeriod = res.bookingPeriod;
    typeOfPartyUuid = res.typeOfPartyUuid;
    price.text = res.price.toString();
    deposit.text = res.deposit.toString();
    remainingamount.text = res.remainingAmount.toString();
    numberofmen.text = res.numberOfMen.toString();
    numberOfwomen.text = res.numberOfWomen.toString();
    note.text = res.notes ?? '';

    // fetch dishes for this reservation
    selectedDishes.clear();
    final dshs = await resData.viewReservationDishes(res.uuid);
    selectedDishes.assignAll(
      dshs.map((e) => e['dishes_uuid'].toString()).toList(),
    );
  }

  Future<void> updateReservation(String uuid) async {
    if (!formState.currentState!.validate()) return;

    if (typeOfPartyUuid == null || BookingBeriod == null) {
      Get.snackbar(
        'warning'.tr,
        'please_fill_required_fields'.tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final String selectedDateStr = date.text.trim();
    final conflictError = checkBookingConflict(
      selectedDateStr,
      BookingBeriod!,
      excludeUuid: uuid,
    );
    if (conflictError != null) {
      showSnackbar('warning'.tr, conflictError, Colors.orange);
      return;
    }

    statusrequest = Statusrequest.loadeng;
    update();

    Map<String, dynamic> rawData = {
      "username": username.text,
      "phone_numper": phone.text,
      "booking_date": date.text,
      "booking_period": BookingBeriod,
      "type_of_party_uuid": typeOfPartyUuid,
      "price": double.tryParse(price.text) ?? 0.0,
      "deposit": double.tryParse(deposit.text) ?? 0.0,
      "remaining_amount": double.tryParse(remainingamount.text) ?? 0.0,
      "number_of_men": int.tryParse(numberofmen.text) ?? 0,
      "number_of_women": int.tryParse(numberOfwomen.text) ?? 0,
      "notes": note.text,
    };

    bool success = await resData.Updatedata(uuid, rawData, selectedDishes);
    if (success) {
      Get.back();
      showSnackbar(
        'success_msg'.tr,
        'reservation_updated_successfully'.tr,
        Colors.green,
      );
      fetchInitialData();
      username.clear();
      phone.clear();
      date.clear();
      price.clear();
      deposit.clear();
      remainingamount.clear();
      numberofmen.clear();
      numberOfwomen.clear();
      note.clear();
      BookingBeriod = null;
      typeOfPartyUuid = null;
      selectedDishes.clear();
    } else {
      showSnackbar('error'.tr, 'failed_to_update_reservation'.tr, Colors.red);
    }

    statusrequest = Statusrequest.success;
    update();
  }

  Future<void> deleteReservation(String uuid) async {
    bool success = await resData.Deletedata(uuid);
    if (success) {
      showSnackbar('success_msg'.tr, 'deleted_successfully'.tr, Colors.green);
      fetchInitialData();
    } else {
      showSnackbar('error'.tr, 'failed_to_delete'.tr, Colors.red);
    }
  }

  /// Add payment to existing deposit
  Future<void> addPayment(
    String uuid,
    double currentDeposit,
    double reservationPrice,
    double newPayment,
  ) async {
    double newTotalDeposit = currentDeposit + newPayment;
    if (newTotalDeposit > reservationPrice) {
      showSnackbar("warning".tr, "payment_exceeds_price".tr, Colors.orange);
      return;
    }

    double newRemaining = reservationPrice - newTotalDeposit;
    bool success = await resData.updatePartialFields(uuid, {
      "deposit": newTotalDeposit,
      "remaining_amount": newRemaining,
    });

    if (success) {
      Get.back();
      showSnackbar("success".tr, "payment_added_success".tr, Colors.green);
      fetchInitialData();
    } else {
      showSnackbar("error".tr, "payment_failed".tr, Colors.red);
    }
  }

  /// Update guest count
  Future<void> updateGuestCount(String uuid, int men, int women) async {
    bool success = await resData.updatePartialFields(uuid, {
      "number_of_men": men,
      "number_of_women": women,
    });

    if (success) {
      Get.back();
      showSnackbar("success".tr, "guests_updated_success".tr, Colors.green);
      fetchInitialData();
    } else {
      showSnackbar("error".tr, "guests_update_failed".tr, Colors.red);
    }
  }
}
