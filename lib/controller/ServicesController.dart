import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/class/Statusrequest.dart';
import '../core/functions/Snacpar.dart';
import '../core/services/Services.dart';
import '../data/datasource/Remote/AdditionalServices.dart';
import '../data/model/ServiceModel.dart';

class ServicesController extends GetxController {
  late AdditionalServices servicesData;
  Myservices myServices = Get.find();

  Statusrequest statusrequest = Statusrequest.none;
  List<ServiceModel> allServices = [];

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController name;
  late TextEditingController price;

  String? editUuid;

  @override
  void onInit() {
    servicesData = AdditionalServices(myServices);
    name = TextEditingController();
    price = TextEditingController();
    fetchServices();
    super.onInit();
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> fetchServices() async {
    statusrequest = Statusrequest.loadeng;
    update();

    final response = await servicesData.viewdata();
    allServices = ServiceModel.fromList(response);

    statusrequest = Statusrequest.success;
    update();
  }

  void setEditData(ServiceModel service) {
    editUuid = service.uuid;
    name.text = service.name ?? "";
    price.text = service.price?.toInt().toString() ?? "";
  }

  void clearForm() {
    editUuid = null;
    name.clear();
    price.clear();
  }

  Future<void> addService() async {
    if (!formState.currentState!.validate()) return;

    statusrequest = Statusrequest.loadeng;
    update();

    bool success = await servicesData.Adddata(
      name.text.trim(),
      double.tryParse(price.text) ?? 0.0,
    );

    if (success) {
      Get.back();
      showSnackbar('success'.tr, 'service_added_success'.tr, Colors.green);
      fetchServices();
      clearForm();
    } else {
      statusrequest = Statusrequest.success;
      update();
      showSnackbar('error'.tr, 'service_add_failed'.tr, Colors.red);
    }
  }

  Future<void> updateService() async {
    if (!formState.currentState!.validate() || editUuid == null) return;

    statusrequest = Statusrequest.loadeng;
    update();

    bool success = await servicesData.UpdateData(
      editUuid!,
      name.text.trim(),
      double.tryParse(price.text) ?? 0.0,
    );

    if (success) {
      Get.back();
      showSnackbar('success'.tr, 'service_updated_success'.tr, Colors.green);
      fetchServices();
      clearForm();
    } else {
      statusrequest = Statusrequest.success;
      update();
      showSnackbar('error'.tr, 'service_update_failed'.tr, Colors.red);
    }
  }

  Future<void> deleteService(String uuid) async {
    try {
      bool success = await servicesData.deletedata(uuid);
      if (success) {
        showSnackbar('success'.tr, 'service_deleted_success'.tr, Colors.green);
        fetchServices();
      } else {
        showSnackbar('error'.tr, 'service_delete_failed'.tr, Colors.red);
      }
    } catch (e) {
      if (e == 'linked_to_reservation') {
        showSnackbar("warning".tr, "cannot_delete_linked_item".tr, Colors.orange);
      } else {
        showSnackbar('error'.tr, 'service_delete_failed'.tr, Colors.red);
      }
    }
  }
}
