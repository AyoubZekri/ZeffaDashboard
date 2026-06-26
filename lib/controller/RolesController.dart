import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import '../../core/functions/handlingdatacontroller.dart';
import '../../data/datasource/Remote/Roles.dart';
import '../../data/model/RoleModel.dart';

class RolesController extends GetxController {
  late TextEditingController nameController;
  final RxString selectedType = "full".obs;
  
  final List<String> availablePermissions = [
    'calendar',
    'reservations',
    'event_types',
    'dish_categories',
    'dishes',
    'expenses',
    'additional_services',
    'notes',
    'terms',
  ];
  final RxList<String> selectedPermissions = <String>[].obs;


  bool isEdit = false;
  String? editId;

  Statusrequest statusrequest = Statusrequest.none;
  final RxList<RoleModel> allRoles = <RoleModel>[].obs;
  late final RolesRepo rolesRepo;

  @override
  void onInit() {
    nameController = TextEditingController();
    rolesRepo = RolesRepo(Get.find());
    loadRoles();
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void clearFields() {
    nameController.clear();
    selectedType.value = "full";
    selectedPermissions.clear();
    isEdit = false;
    editId = null;
  }

  void setEditData(RoleModel role) {
    isEdit = true;
    editId = role.id?.toString();
    nameController.text = role.name ?? '';
    selectedType.value = role.type ?? 'full';
    
    selectedPermissions.clear();
    if (role.permissions != null && role.permissions!.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(role.permissions!);
        selectedPermissions.assignAll(decoded.map((e) => e.toString()).toList());
      } catch (e) {
        print("Error decoding permissions: $e");
      }
    }
  }

  void togglePermission(String permission) {
    if (selectedPermissions.contains(permission)) {
      selectedPermissions.remove(permission);
    } else {
      selectedPermissions.add(permission);
    }
  }


  Future<void> loadRoles() async {
    statusrequest = Statusrequest.loadeng;
    update();
    try {
      final response = await rolesRepo.viewdata();
      statusrequest = handlingData(response);
      if (statusrequest == Statusrequest.success) {
        if (response['status'] == 1 || response['status'] == true) {
          final dataList = response['data'] as List?;
          if (dataList != null && dataList.isNotEmpty) {
            allRoles.assignAll(RoleModel.fromList(dataList));
          } else {
            allRoles.clear();
            statusrequest = Statusrequest.failure;
          }
        } else {
          statusrequest = Statusrequest.failure;
        }
      }
    } catch (e) {
      print("Error loading roles: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  Future<void> saveRole() async {
    if (nameController.text.trim().isEmpty) {
      showSnackbar("error".tr, "name_required".tr, Colors.red);
      return;
    }

    String permissionsJson = "[]";
    if (selectedType.value == 'partial') {
      if (selectedPermissions.isEmpty) {
        showSnackbar("error".tr, "select_at_least_one_permission".tr, Colors.red);
        return;
      }
      permissionsJson = jsonEncode(selectedPermissions.toList());
    }

    statusrequest = Statusrequest.loadeng;
    update();

    dynamic response;
    if (isEdit) {
      response = await rolesRepo.Updatedata(
        editId!,
        nameController.text.trim(),
        selectedType.value,
        permissionsJson,
      );
    } else {
      response = await rolesRepo.Adddata(
        nameController.text.trim(),
        selectedType.value,
        permissionsJson,
      );
    }

    statusrequest = handlingData(response);
    if (statusrequest == Statusrequest.success) {
      if (response['status'] == 1 || response['status'] == true) {
        Get.back();
        loadRoles();
        clearFields();
      } else {
        showSnackbar("error".tr, "operation_failed".tr, Colors.red);
      }
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
    update();
  }

  Future<void> deleteRole(String id) async {
    statusrequest = Statusrequest.loadeng;
    update();

    final response = await rolesRepo.Deletedata(id);
    statusrequest = handlingData(response);
    if (statusrequest == Statusrequest.success) {
      if (response['status'] == 1 || response['status'] == true) {
        loadRoles();
      } else {
        showSnackbar("error".tr, "operation_failed".tr, Colors.red);
      }
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
    update();
  }
}
