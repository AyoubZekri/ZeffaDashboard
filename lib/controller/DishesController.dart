import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:zeffa/data/datasource/Remote/Dishes.dart';

import '../core/functions/Snacpar.dart';
import '../core/functions/uploudfiler.dart';
import '../data/datasource/Remote/DishCategories.dart' show Dishcategories;
import '../data/model/DishCategoryModel.dart';
import '../data/model/DishModel.dart';

class DishesController extends GetxController {
  // Input fields for Add
  File? file;
  String? uuid;
  String? catUuid;
  String? editcatUuid;

  late TextEditingController name;

  // Input fields for Edit
  late TextEditingController editName;
  Dishes dishes = Dishes(Get.find());
  Dishcategories dishcategories = Dishcategories(Get.find());

  Statusrequest statusrequest = Statusrequest.none;

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  List<DishCategoryModel> dishCategories = <DishCategoryModel>[].obs;
  List<DishModel> dishesdate = <DishModel>[].obs;
  final RxnString selectedCategoryUuid = RxnString();

  List<DishModel> get filteredDishes {
    final catUuid = selectedCategoryUuid.value;
    if (catUuid == null) {
      return dishesdate;
    }
    return dishesdate.where((dish) => dish.catUuid == catUuid).toList();
  }

  @override
  void onInit() {
    viewCategory();
    viewdishes();
    name = TextEditingController();
    editName = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    name.dispose();
    editName.dispose();
    super.onClose();
  }

  void clearFields() {
    name.clear();
    file = null;
    uuid = null;
    catUuid = null;
    editcatUuid = null;
    editName.clear();
  }

  Future<void> uploadimagefile() async {
    file = await fileuploadGallery(false) ?? file;
    update();
  }

  // Add Category
  void adddishes() async {
    if (!formState.currentState!.validate()) return;

    try {
      final result = await dishes.Adddata(name.text, catUuid!, file);
      print("=============$result");
      if (result == true) {
        Get.back(result: true);
        viewdishes();
        clearFields();
      } else {
        showSnackbar("error".tr, "error_adding_product".tr, Colors.red);
        statusrequest = Statusrequest.failure;
      }
    } catch (e) {
      showSnackbar("error".tr, "db_error".tr, Colors.red);
      print("DB Error: $e");
      statusrequest = Statusrequest.failure;
    }

    clearFields();
  }

  void viewCategory() async {
    try {
      final result = await dishcategories.viewdata();
      print("=================$result=============");
      if (result.isEmpty) {
        statusrequest = Statusrequest.none;
        dishCategories.clear();
      } else {
        List<DishCategoryModel> list = [];
        for (var e in result) {
          list.add(DishCategoryModel.fromJson(Map<String, dynamic>.from(e)));
        }
        dishCategories.assignAll(list);
        statusrequest = Statusrequest.success;
      }
      update();
    } catch (e) {
      print("DB Error: $e");
      statusrequest = Statusrequest.failure;
      update();
    }
  }

  void viewdishes() async {
    try {
      final result = await dishes.viewdata();
      print("=================$result=============");
      if (result.isEmpty) {
        statusrequest = Statusrequest.none;
        dishesdate.clear();
      } else {
        List<DishModel> list = [];
        for (var e in result) {
          list.add(DishModel.fromJson(Map<String, dynamic>.from(e)));
        }
        dishesdate.assignAll(list);
        statusrequest = Statusrequest.success;
      }
      update();
    } catch (e) {
      print("DB Error: $e");
      statusrequest = Statusrequest.failure;
      update();
    }
  }

  void setEditData(DishModel dishCategory) {
    editName.text = dishCategory.name!;
    uuid = dishCategory.uuid;
    file = dishCategory.image != null ? File(dishCategory.image!) : null;
    editcatUuid = dishCategory.catUuid;
  }

  void editdishes() async {
    if (!formState.currentState!.validate()) return;

    try {
      var result = await dishes.Updatecat(
        uuid!,
        editName.text,
        editcatUuid!,
        file,
      );
      print("===========$result");

      if (result == true) {
        Get.back(result: true);
        clearFields();
        viewdishes();
      }
    } catch (e) {
      print("error in edit category : $e");
    }
  }

  void deleteDishes(String uuid) async {
    try {
      var result = await dishes.deletecat(uuid);

      if (result == true) {
        Get.back(result: true);
        viewdishes();
      }
    } catch (e) {
      print("error in edit category : $e");
    }
  }
}
