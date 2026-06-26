import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import '../../core/functions/handlingdatacontroller.dart';
import '../../data/datasource/Remote/SubUsersRepo.dart';
import '../../data/model/SubUserModel.dart';
import 'RolesController.dart';

class SubUsersController extends GetxController {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  
  RxInt? selectedRoleId;

  bool isEdit = false;
  String? editId;
  
  bool isPasswordHidden = true;

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  Statusrequest statusrequest = Statusrequest.none;
  final RxList<SubUserModel> allUsers = <SubUserModel>[].obs;
  late final SubUsersRepo subUsersRepo;

  final RolesController rolesController = Get.put(RolesController());

  @override
  void onInit() {
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    subUsersRepo = SubUsersRepo(Get.find());
    loadUsers();
    super.onInit();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void clearFields() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    selectedRoleId = null;
    isEdit = false;
    editId = null;
    isPasswordHidden = true;
    update();
  }

  void setEditData(SubUserModel user) {
    isEdit = true;
    editId = user.id?.toString();
    usernameController.text = user.username ?? '';
    emailController.text = user.email ?? '';
    passwordController.text = ''; // Leave blank unless they want to change it
    selectedRoleId = user.roleId?.obs;
    update();
  }

  Future<void> loadUsers() async {
    statusrequest = Statusrequest.loadeng;
    update();
    try {
      final response = await subUsersRepo.viewdata();
      statusrequest = handlingData(response);
      if (statusrequest == Statusrequest.success) {
        if (response['status'] == 1 || response['status'] == true) {
          final dataList = response['data'] as List?;
          if (dataList != null && dataList.isNotEmpty) {
            allUsers.assignAll(SubUserModel.fromList(dataList));
          } else {
            allUsers.clear();
            statusrequest = Statusrequest.failure;
          }
        } else {
          statusrequest = Statusrequest.failure;
        }
      }
    } catch (e) {
      print("Error loading sub users: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  Future<void> saveUser() async {
    if (usernameController.text.trim().isEmpty || 
        emailController.text.trim().isEmpty ||
        selectedRoleId == null || selectedRoleId!.value == 0) {
      showSnackbar("error".tr, isArabic() ? "يرجى ملء الحقول المطلوبة" : "Please fill required fields", Colors.red);
      return;
    }

    if (!isEdit && passwordController.text.trim().length < 6) {
      showSnackbar("error".tr, isArabic() ? "كلمة المرور يجب أن تكون 6 أحرف على الأقل" : "Password must be at least 6 characters", Colors.red);
      return;
    }

    statusrequest = Statusrequest.loadeng;
    update();

    dynamic response;
    if (isEdit) {
      response = await subUsersRepo.Updatedata(
        editId!,
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRoleId!.value,
      );
    } else {
      response = await subUsersRepo.Adddata(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRoleId!.value,
      );
    }

    statusrequest = handlingData(response);
    if (statusrequest == Statusrequest.success) {
      if (response['status'] == 1 || response['status'] == true) {
        Get.back();
        loadUsers();
        clearFields();
        showSnackbar("success".tr, isArabic() ? "تم الحفظ بنجاح" : "Saved successfully", Colors.green);
      } else {
        showSnackbar("error".tr, response['message'] ?? "operation_failed".tr, Colors.red);
      }
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
    update();
  }

  Future<void> deleteUser(String id) async {
    statusrequest = Statusrequest.loadeng;
    update();

    final response = await subUsersRepo.Deletedata(id);
    statusrequest = handlingData(response);
    if (statusrequest == Statusrequest.success) {
      if (response['status'] == 1 || response['status'] == true) {
        loadUsers();
        showSnackbar("success".tr, isArabic() ? "تم الحذف بنجاح" : "Deleted successfully", Colors.green);
      } else {
        showSnackbar("error".tr, "operation_failed".tr, Colors.red);
      }
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
    update();
  }

  bool isArabic() {
    return Get.locale?.languageCode == 'ar';
  }
}
