import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/functions/Snacpar.dart';
import 'package:zeffa/data/model/ReservationModel.dart';

import '../core/class/Statusrequest.dart';
import '../core/services/Services.dart';
import '../core/class/Crud.dart';
import '../data/datasource/Remote/ReservationsData.dart';
import '../data/datasource/Remote/PartyTypes.dart';
import '../data/datasource/Remote/Dishes.dart';
import '../data/datasource/Remote/SpecialDates.dart';
import '../data/model/PartyTypeModel.dart';
import '../data/model/SpecialDateModel.dart';

class Reservationscontroller extends GetxController {
  late final TextEditingController searchController;
  final RxString searchQuery = "".obs;

  final RxList<ReservationModel> allReservations = <ReservationModel>[].obs;

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
    {'key': 2, 'label': 'period_half_day'},
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

    resData = ReservationsData();
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

      // Fetch reservations (now includes joined party_type + dishes data)
      var res = await resData.viewdata();
      print("🔍 Reservations fetched: ${res.length} items");
      if (res.isNotEmpty) print("🔍 First reservation: ${res.first}");
      allReservations.assignAll(
        List<ReservationModel>.from(
          res.map((e) => ReservationModel.fromJson(Map<String, dynamic>.from(e))),
        ),
      );
      print("🔍 allReservations.length after assign: ${allReservations.length}");

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
      (p) => p.uuid == typeOfPartyUuid,
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

  // عرض البيانات
  Future<void> addReservation() async {
    if (username.text.isEmpty || phone.text.isEmpty || date.text.isEmpty || typeOfPartyUuid == null || BookingBeriod == null) {
      Get.snackbar("تنبيه".tr, "يرجى تعبئة الحقول الأساسية (الاسم، الهاتف، التاريخ، نوع الحفل والفترة)".tr, backgroundColor: Colors.orange, colorText: Colors.white);
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

    bool success = await resData.Adddata(rawData, selectedDishes);
    if (success) {
      Get.back();
      showSnackbar("نجاح".tr, "تم حفظ الحجز بنجاح".tr, Colors.green);
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
      showSnackbar("خطأ".tr, "فشل حفظ الحجز".tr, Colors.red);
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
      showSnackbar("نجاح".tr, "تم تعديل الحجز بنجاح".tr, Colors.green);
      fetchInitialData();
    } else {
      showSnackbar("خطأ".tr, "فشل تعديل الحجز".tr, Colors.red);
    }

    statusrequest = Statusrequest.success;
    update();
  }

  Future<void> deleteReservation(String uuid) async {
    bool success = await resData.Deletedata(uuid);
    if (success) {
      showSnackbar("نجاح".tr, "تم الحذف بنجاح".tr, Colors.green);
      fetchInitialData();
    } else {
      showSnackbar("خطأ".tr, "فشل الحذف".tr, Colors.red);
    }
  }

  /// Add payment to existing deposit
  Future<void> addPayment(String uuid, double currentDeposit, double reservationPrice, double newPayment) async {
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
