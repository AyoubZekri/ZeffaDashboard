import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import '../../data/datasource/Remote/Terms.dart';
import '../../data/model/TermModel.dart';

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
  late TextEditingController contentController; // Kept for backwards compatibility
  final RxList<TextEditingController> detailControllers = <TextEditingController>[].obs;
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
      final matchesSearch = query.isEmpty ||
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

    final List<String> details = detailControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

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
      showSnackbar("success".tr, isEdit ? "term_updated_success".tr : "term_added_success".tr, Colors.green);
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
    detailControllers.assignAll(
      term.contents.map((detail) => TextEditingController(text: detail)).toList()
    );
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
