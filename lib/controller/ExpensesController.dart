import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import '../../data/datasource/Remote/Expenses.dart';
import '../../data/model/ExpenseModel.dart';

class ExpensesController extends GetxController {
  late final TextEditingController searchController;
  final RxString searchQuery = "".obs;
  
  // 0: All, 1: Maintenance workers, 2: Cleaning materials, 3: Other expenses
  final RxInt selectedCategory = 0.obs;

  // Date range filters
  final Rxn<DateTime> startDateFilter = Rxn<DateTime>();
  final Rxn<DateTime> endDateFilter = Rxn<DateTime>();

  final RxList<ExpenseModel> allExpenses = <ExpenseModel>[].obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 5;

  // Form Fields
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController dateController;
  final RxnInt formCategory = RxnInt();
  DateTime? selectedDate;
  
  bool isEdit = false;
  String? editUuid;

  final Expenses expensesRepo = Expenses(Get.find());
  Statusrequest statusrequest = Statusrequest.none;

  @override
  void onInit() {
    searchController = TextEditingController();
    nameController = TextEditingController();
    amountController = TextEditingController();
    dateController = TextEditingController();
    
    loadExpenses();

    ever(searchQuery, (_) => currentPage.value = 1);
    ever(selectedCategory, (_) => currentPage.value = 1);
    ever(startDateFilter, (_) => currentPage.value = 1);
    ever(endDateFilter, (_) => currentPage.value = 1);

    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    amountController.dispose();
    dateController.dispose();
    super.onClose();
  }

  void clearFields() {
    nameController.clear();
    amountController.clear();
    dateController.clear();
    formCategory.value = null;
    selectedDate = null;
    isEdit = false;
    editUuid = null;
  }

  Future<void> loadExpenses() async {
    statusrequest = Statusrequest.loadeng;
    update();
    try {
      final result = await expensesRepo.viewdata();
      if (result.isEmpty) {
        statusrequest = Statusrequest.none;
        allExpenses.clear();
      } else {
        allExpenses.assignAll(ExpenseModel.fromList(result));
        statusrequest = Statusrequest.success;
      }
    } catch (e) {
      print("Error loading expenses: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  // Filter logic
  List<ExpenseModel> get filteredExpenses {
    final query = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value;
    final start = startDateFilter.value;
    final end = endDateFilter.value;

    return allExpenses.where((expense) {
      final matchesSearch = query.isEmpty ||
          (expense.description?.toLowerCase().contains(query) ?? false);
      
      final matchesCategory = cat == 0 || expense.type == cat;

      bool matchesDate = true;
      if (expense.datePerry != null) {
        try {
          final date = DateFormat('yyyy-MM-dd').parse(expense.datePerry!);
          if (start != null && date.isBefore(start)) {
            matchesDate = false;
          }
          if (end != null && date.isAfter(end)) {
            matchesDate = false;
          }
        } catch (e) {
          // If parsing fails, ignore date filtering for this item
        }
      } else if (start != null || end != null) {
        matchesDate = false;
      }

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }

  // Pagination logic
  List<ExpenseModel> get paginatedExpenses {
    final list = filteredExpenses;
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    if (startIndex >= list.length) return [];
    
    final endIndex = startIndex + itemsPerPage;
    return list.sublist(
      startIndex,
      endIndex > list.length ? list.length : endIndex,
    );
  }

  int get totalPages {
    final length = filteredExpenses.length;
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

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate = picked;
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> selectDateRangeFilter(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: startDateFilter.value != null && endDateFilter.value != null
          ? DateTimeRange(start: startDateFilter.value!, end: endDateFilter.value!)
          : null,
    );

    if (picked != null) {
      startDateFilter.value = picked.start;
      endDateFilter.value = picked.end;
    }
  }

  void clearDateFilter() {
    startDateFilter.value = null;
    endDateFilter.value = null;
  }

  Future<void> saveExpense() async {
    if (!formState.currentState!.validate()) return;
    if (formCategory.value == null) {
      showSnackbar("error".tr, "please_select_category".tr, Colors.red);
      return;
    }
    if (dateController.text.isEmpty) {
      showSnackbar("error".tr, "please_select_date".tr, Colors.red);
      return;
    }

    final double? parsedValue = double.tryParse(amountController.text);
    if (parsedValue == null) {
      showSnackbar("error".tr, "invalid_amount".tr, Colors.red);
      return;
    }

    bool success = false;
    if (isEdit) {
      success = await expensesRepo.Updatedata(
        editUuid!,
        formCategory.value!,
        nameController.text,
        parsedValue,
        dateController.text,
      );
    } else {
      success = await expensesRepo.Adddata(
        formCategory.value!,
        nameController.text,
        parsedValue,
        dateController.text,
      );
    }

    if (success) {
      Get.back();
      loadExpenses();
      clearFields();
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }

  void setEditData(ExpenseModel expense) {
    isEdit = true;
    editUuid = expense.uuid;
    nameController.text = expense.description ?? "";
    amountController.text = expense.value?.toString() ?? "";
    dateController.text = expense.datePerry ?? "";
    formCategory.value = expense.type;
    
    if (expense.datePerry != null) {
      try {
        selectedDate = DateFormat('yyyy-MM-dd').parse(expense.datePerry!);
      } catch (e) {
        selectedDate = DateTime.now();
      }
    }
  }

  Future<void> deleteExpense(String uuid) async {
    final success = await expensesRepo.Deletedata(uuid);
    if (success) {
      loadExpenses();
      showSnackbar("success".tr, "expense_deleted_success".tr, Colors.green);
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }

  double get totalExpensesSum {
    return allExpenses.fold(0.0, (sum, item) => sum + (item.value ?? 0.0));
  }
}
