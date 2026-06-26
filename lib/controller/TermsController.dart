import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import 'dart:convert';
import '../../data/datasource/Remote/Terms.dart';
import '../../data/model/TermModel.dart';

class RequiredMaterialItem {
  RxString unit = 'كلغ'.obs; // Default 'كلغ', 'لتر', 'عدد'
  TextEditingController quantityController = TextEditingController();
  TextEditingController coversGuestsController = TextEditingController();

  void dispose() {
    quantityController.dispose();
    coversGuestsController.dispose();
  }

  void clear() {
    unit.value = 'كلغ';
    quantityController.clear();
    coversGuestsController.clear();
  }
}

class TermsController extends GetxController {
  late final TextEditingController searchController;
  final RxString searchQuery = "".obs;

  final RxList<TermModel> allTerms = <TermModel>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 6;

  // Filter type: 'all', 'internal_rules', 'contract_terms', 'required_procedures', 'required_documents'
  final RxString selectedTypeFilter = "all".obs;

  // Form Fields
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController
  contentController; // Kept for backwards compatibility
  final RxList<TextEditingController> detailControllers =
      <TextEditingController>[].obs;
  final RequiredMaterialItem singleMaterial = RequiredMaterialItem();
  final RxString selectedType = "internal_rules".obs;

  bool isEdit = false;
  String? editUuid;

  late final Terms termsRepo;
  Statusrequest statusrequest = Statusrequest.none;

  @override
  void onInit() {
    termsRepo = Terms(Get.find());
    searchController = TextEditingController();
    titleController = TextEditingController();
    contentController = TextEditingController();

    loadTerms();

    ever(searchQuery, (_) => currentPage.value = 1);
    ever(selectedTypeFilter, (_) => currentPage.value = 1);

    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    titleController.dispose();
    contentController.dispose();
    for (var c in detailControllers) {
      c.dispose();
    }
    singleMaterial.dispose();
    super.onClose();
  }

  void addDetailField() {
    detailControllers.add(TextEditingController());
  }

  void removeDetailField(int index) {
    detailControllers[index].dispose();
    detailControllers.removeAt(index);
  }

  void clearFields() {
    titleController.clear();
    contentController.clear();
    for (var c in detailControllers) {
      c.dispose();
    }
    detailControllers.clear();
    singleMaterial.clear();
    selectedType.value = "internal_rules";
    isEdit = false;
    editUuid = null;
  }

  Future<void> loadTerms() async {
    statusrequest = Statusrequest.loadeng;
    update();
    try {
      final result = await termsRepo.viewdata();
      if (result.isEmpty) {
        statusrequest = Statusrequest.none;
        allTerms.clear();
      } else {
        allTerms.assignAll(TermModel.fromList(result));
        statusrequest = Statusrequest.success;
      }
    } catch (e) {
      print("Error loading terms: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  // Filter logic
  List<TermModel> get filteredTerms {
    final query = searchQuery.value.trim().toLowerCase();
    final filterType = selectedTypeFilter.value;

    return allTerms.where((term) {
      final matchesSearch =
          query.isEmpty ||
          (term.title?.toLowerCase().contains(query) ?? false) ||
          term.contents.any((c) => c.toLowerCase().contains(query));

      final matchesType = filterType == "all" || term.type == filterType;

      return matchesSearch && matchesType;
    }).toList();
  }

  // Pagination logic
  List<TermModel> get paginatedTerms {
    final list = filteredTerms;
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    if (startIndex >= list.length) return [];

    final endIndex = startIndex + itemsPerPage;
    return list.sublist(
      startIndex,
      endIndex > list.length ? list.length : endIndex,
    );
  }

  int get totalPages {
    final length = filteredTerms.length;
    if (length == 0) return 1;
    return (length / itemsPerPage).ceil();
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  Future<void> saveTerm() async {
    if (!formState.currentState!.validate()) return;

    List<String> details = [];

    if (selectedType.value == 'required_documents') {
      final Map<String, dynamic> data = {
        "unit": singleMaterial.unit.value,
        "quantity":
            double.tryParse(singleMaterial.quantityController.text) ?? 1.0,
        "covers_guests":
            int.tryParse(singleMaterial.coversGuestsController.text) ?? 100,
      };
      details.add(jsonEncode(data));
    } else {
      details = detailControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
    }

    bool success = false;
    if (isEdit) {
      success = await termsRepo.Updatedata(
        editUuid!,
        titleController.text,
        selectedType.value,
        details,
      );
    } else {
      success = await termsRepo.Adddata(
        titleController.text,
        selectedType.value,
        details,
      );
    }

    if (success) {
      Get.back();
      loadTerms();
      clearFields();
      showSnackbar(
        "success".tr,
        isEdit ? "term_updated_success".tr : "term_added_success".tr,
        Colors.green,
      );
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }

  void setEditData(TermModel term) {
    isEdit = true;
    editUuid = term.uuid;
    titleController.text = term.title ?? "";
    contentController.text = term.content;
    selectedType.value = term.type ?? "internal_rules";

    for (var c in detailControllers) {
      c.dispose();
    }
    detailControllers.clear();

    singleMaterial.clear();

    if (term.type == 'required_documents') {
      if (term.contents.isNotEmpty) {
        try {
          final decoded = jsonDecode(term.contents.first);

          String loadedUnit = decoded['unit']?.toString() ?? 'كلغ';
          if (loadedUnit == 'kg') loadedUnit = 'كلغ';
          if (loadedUnit == 'liter') loadedUnit = 'لتر';
          if (loadedUnit == 'count') loadedUnit = 'عدد';
          singleMaterial.unit.value = loadedUnit;

          singleMaterial.quantityController.text =
              decoded['quantity']?.toString().replaceAll(RegExp(r'\.0$'), '') ??
              '1';
          singleMaterial.coversGuestsController.text =
              decoded['covers_guests']?.toString() ?? '100';
        } catch (e) {
          // Fallback
        }
      }
    } else {
      detailControllers.assignAll(
        term.contents
            .map((detail) => TextEditingController(text: detail))
            .toList(),
      );
    }
  }

  Future<void> deleteTerm(String uuid) async {
    final success = await termsRepo.Deletedata(uuid);
    if (success) {
      loadTerms();
      showSnackbar("success".tr, "term_deleted_success".tr, Colors.green);
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }
}
