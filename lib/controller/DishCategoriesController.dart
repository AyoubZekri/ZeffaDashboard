import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/class/Statusrequest.dart';
import '../core/functions/Snacpar.dart';
import '../core/functions/uploudfiler.dart';
import '../data/datasource/Remote/DishCategories.dart';
import '../data/model/DishCategoryModel.dart';

class DishCategoriesController extends GetxController {
  File? file;
  String? uuid;
  late TextEditingController catName;

  // Input fields for Edit
  late TextEditingController editCatName;
  Dishcategories dishcategories = Dishcategories(Get.find());
  Statusrequest statusrequest = Statusrequest.none;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  // List of Dish Categories in RxList
  List<DishCategoryModel> dishCategories = <DishCategoryModel>[].obs;
  @override
  void onInit() {
    viewCategory();
    catName = TextEditingController();
    editCatName = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    catName.dispose();
    editCatName.dispose();
    super.onClose();
  }

  void clearFields() {
    catName.clear();
    file == null;
  }

  Future<void> uploadimagefile() async {
    file = await fileuploadGallery(false) ?? file;
    update();
  }

  // Add Category
  void addCategory() async {
    if (!formState.currentState!.validate()) return;
    try {
      /// ندخل المنتج في SQLite مع الصورة + uuid + sync_queue
      final result = await dishcategories.Adddata(catName.text, file);

      if (result == true) {
        Get.back(result: true);
        clearFields();
        viewCategory();
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

  void setEditData(DishCategoryModel dishCategory) {
    editCatName.text = dishCategory.name!;
    uuid = dishCategory.uuid;
    file = dishCategory.image != null ? File(dishCategory.image!) : null;
  }

  void editCategory() async {
    try {
      var result = await dishcategories.Updatecat(
        uuid!,
        editCatName.text,
        file,
      );

      if (result == true) {
        Get.back(result: true);
        viewCategory();
      }
    } catch (e) {
      print("error in edit category : $e");
    }
  }

  void deletecat(String uuid) async {
    try {
      var result = await dishcategories.deletecat(uuid);

      if (result == true) {
        Get.back(result: true);
        viewCategory();
      }
    } catch (e) {
      print("error in edit category : $e");
    }
  }
}
