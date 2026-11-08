import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/class/Statusrequest.dart';
import '../core/functions/Snacpar.dart';
import '../core/services/Services.dart';
import '../data/datasource/Remote/Halls.dart';
import '../data/model/HallModel.dart';

class HallsController extends GetxController {
  late Halls hallsData;
  Myservices myServices = Get.find();

  Statusrequest statusrequest = Statusrequest.none;
  // Account hall first, then the extra halls
  List<HallModel> allHalls = [];

  /// Halls added in the halls page (without the account hall)
  List<HallModel> get extraHalls =>
      allHalls.where((h) => !h.isAccountHall).toList();

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController name;
  late TextEditingController phone1;
  late TextEditingController phone2;
  late TextEditingController address;

  String? editUuid;

  @override
  void onInit() {
    hallsData = Halls(myServices);
    name = TextEditingController();
    phone1 = TextEditingController();
    phone2 = TextEditingController();
    address = TextEditingController();
    fetchHalls();
    super.onInit();
  }

  @override
  void dispose() {
    name.dispose();
    phone1.dispose();
    phone2.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> fetchHalls() async {
    statusrequest = Statusrequest.loadeng;
    update();

    allHalls = await hallsData.allHalls();

    statusrequest = Statusrequest.success;
    update();
  }

  void setEditData(HallModel hall) {
    editUuid = hall.uuid;
    name.text = hall.name ?? "";
    phone1.text = hall.phone1 ?? "";
    phone2.text = hall.phone2 ?? "";
    address.text = hall.address ?? "";
  }

  void clearForm() {
    editUuid = null;
    name.clear();
    phone1.clear();
    phone2.clear();
    address.clear();
  }

  Future<void> addHall() async {
    if (!formState.currentState!.validate()) return;

    statusrequest = Statusrequest.loadeng;
    update();

    bool success = await hallsData.Adddata(
      name.text.trim(),
      phone1.text.trim(),
      phone2.text.trim(),
      address.text.trim(),
    );

    if (success) {
      Get.back();
      showSnackbar('success'.tr, 'hall_added_success'.tr, Colors.green);
      fetchHalls();
      clearForm();
    } else {
      statusrequest = Statusrequest.success;
      update();
      showSnackbar('error'.tr, 'operation_failed'.tr, Colors.red);
    }
  }

  Future<void> updateHall() async {
    if (!formState.currentState!.validate() || editUuid == null) return;

    statusrequest = Statusrequest.loadeng;
    update();

    bool success = await hallsData.Updatedata(
      editUuid!,
      name.text.trim(),
      phone1.text.trim(),
      phone2.text.trim(),
      address.text.trim(),
    );

    if (success) {
      Get.back();
      showSnackbar('success'.tr, 'hall_updated_success'.tr, Colors.green);
      fetchHalls();
      clearForm();
    } else {
      statusrequest = Statusrequest.success;
      update();
      showSnackbar('error'.tr, 'operation_failed'.tr, Colors.red);
    }
  }

  Future<void> deleteHall(String uuid) async {
    try {
      bool success = await hallsData.Deletedata(uuid);
      if (success) {
        showSnackbar('success'.tr, 'hall_deleted_success'.tr, Colors.green);
        fetchHalls();
      } else {
        showSnackbar('error'.tr, 'operation_failed'.tr, Colors.red);
      }
    } catch (e) {
      if (e == 'linked_to_reservation') {
        showSnackbar("warning".tr, "hall_has_reservations".tr, Colors.orange);
      } else {
        showSnackbar('error'.tr, 'operation_failed'.tr, Colors.red);
      }
    }
  }
}
