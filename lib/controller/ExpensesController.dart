import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/class/Sqldb.dart';
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
  final RxList<Map<String, dynamic>> allReservations =
      <Map<String, dynamic>>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 5;

  // Form Fields
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController dateController;

  // ── Workers expense (category 1) by count: amount = count × price ──
  late TextEditingController workersCountController;
  late TextEditingController femaleWorkersCountController;
  late TextEditingController workerPriceController;
  late TextEditingController femaleWorkerPriceController;
  // Not linked to a reservation: enter the total, or switch to counting
  final RxBool workersByCount = false.obs;
  final RxDouble workersTotal = 0.0.obs;
  // Per-person prices of each event type: uuid → {worker, female}
  final Map<String, Map<String, double>> partyWorkerPrices = {};

  bool get isWorkersCategory => formCategory.value == 1;

  /// Amount comes from the counts (linked reservation, or counting chosen)
  bool get isWorkersComputed =>
      isWorkersCategory && (linkToReservation.value || workersByCount.value);

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

  void recalcWorkers() {
    workersTotal.value =
        _num(workersCountController) * _num(workerPriceController) +
        _num(femaleWorkersCountController) * _num(femaleWorkerPriceController);
  }

  String _plain(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// Fill the per-person prices from the linked reservation's event type
  void applyPartyWorkerPrices() {
    if (!isWorkersCategory || !linkToReservation.value) return;
    final res = allReservations.firstWhereOrNull(
      (r) => r['uuid'] == formReservationUuid.value,
    );
    final prices = partyWorkerPrices[res?['type_of_party_uuid']?.toString()];
    if (prices == null) return;
    if ((prices['worker'] ?? 0) > 0) {
      workerPriceController.text = _plain(prices['worker']!);
    }
    if ((prices['female'] ?? 0) > 0) {
      femaleWorkerPriceController.text = _plain(prices['female']!);
    }
    recalcWorkers();
  }

  void onCategoryChanged(int? value) {
    formCategory.value = value;
    applyPartyWorkerPrices();
  }

  void onReservationChanged(String? uuid) {
    formReservationUuid.value = uuid;
    _applyReservationDate();
    applyPartyWorkerPrices();
  }

  /// Linked expense → its date is the reservation's date (still editable)
  void _applyReservationDate() {
    final res = allReservations.firstWhereOrNull(
      (r) => r['uuid'] == formReservationUuid.value,
    );
    final raw = res?['booking_date']?.toString();
    if (raw == null || raw.isEmpty) return;
    final date = DateTime.tryParse(raw.replaceAll('/', '-'));
    if (date == null) return;
    selectedDate = date;
    dateController.text = DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _loadPartyWorkerPrices() async {
    try {
      final rows = await _db.readData(
        "SELECT uuid, worker_price, female_worker_price FROM party_types WHERE user_id = ?",
        [expensesRepo.id],
      );
      partyWorkerPrices.clear();
      for (final r in rows) {
        partyWorkerPrices[r['uuid'].toString()] = {
          'worker': (r['worker_price'] as num?)?.toDouble() ?? 0.0,
          'female': (r['female_worker_price'] as num?)?.toDouble() ?? 0.0,
        };
      }
    } catch (e) {
      print("Error loading worker prices: $e");
    }
  }

  final RxnInt formCategory = RxnInt();
  // Optional reservation (wedding) this expense belongs to
  final RxnString formReservationUuid = RxnString();
  // Switch "linked to a reservation"; off → general expense
  final RxBool linkToReservation = false.obs;

  void setLinkToReservation(bool value) {
    linkToReservation.value = value;
    if (!value) formReservationUuid.value = null;
    applyPartyWorkerPrices();
  }

  DateTime? selectedDate;

  bool isEdit = false;
  String? editUuid;

  final Expenses expensesRepo = Expenses(Get.find());
  final SQLDB _db = SQLDB();
  Statusrequest statusrequest = Statusrequest.none;

  @override
  void onInit() {
    searchController = TextEditingController();
    nameController = TextEditingController();
    amountController = TextEditingController();
    dateController = TextEditingController();
    workersCountController = TextEditingController();
    femaleWorkersCountController = TextEditingController();
    workerPriceController = TextEditingController();
    femaleWorkerPriceController = TextEditingController();

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
    workersCountController.dispose();
    femaleWorkersCountController.dispose();
    workerPriceController.dispose();
    femaleWorkerPriceController.dispose();
    super.onClose();
  }

  void clearFields() {
    nameController.clear();
    amountController.clear();
    dateController.clear();
    workersCountController.clear();
    femaleWorkersCountController.clear();
    workerPriceController.clear();
    femaleWorkerPriceController.clear();
    workersByCount.value = false;
    workersTotal.value = 0;
    formCategory.value = null;
    formReservationUuid.value = null;
    linkToReservation.value = false;
    selectedDate = null;
    isEdit = false;
    editUuid = null;
  }

  Future<List<Map<String, dynamic>>> fetchReservations() async {
    try {
      final int userId = expensesRepo.id;
      final result = await _db.readData(
        "SELECT uuid, username, deposit, remaining_amount, booking_date, type_of_party_uuid FROM reservations WHERE user_id = ? ORDER BY booking_date DESC",
        [userId],
      );
      return result;
    } catch (e) {
      print("Error fetching reservations for expenses income: $e");
      return [];
    }
  }

  /// "Customer name - date" label of a linked reservation
  String? reservationLabel(String? uuid) {
    if (uuid == null || uuid.isEmpty) return null;
    final res = allReservations.firstWhereOrNull((r) => r['uuid'] == uuid);
    if (res == null) return null;
    return "${res['username'] ?? ''} - ${res['booking_date'] ?? ''}";
  }

  /// Customer name only of a linked reservation (used in table and search)
  String? reservationName(String? uuid) {
    if (uuid == null || uuid.isEmpty) return null;
    final res = allReservations.firstWhereOrNull((r) => r['uuid'] == uuid);
    return res?['username']?.toString();
  }

  Future<void> loadExpenses() async {
    statusrequest = Statusrequest.loadeng;
    update();
    try {
      final result = await expensesRepo.viewdata();
      final resResult = await fetchReservations();
      await _loadPartyWorkerPrices();

      allReservations.assignAll(resResult);

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
      final matchesSearch =
          query.isEmpty ||
          (expense.description?.toLowerCase().contains(query) ?? false) ||
          (reservationName(
                expense.reservationUuid,
              )?.toLowerCase().contains(query) ??
              false);

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
      initialDateRange:
          startDateFilter.value != null && endDateFilter.value != null
          ? DateTimeRange(
              start: startDateFilter.value!,
              end: endDateFilter.value!,
            )
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
    if (linkToReservation.value && formReservationUuid.value == null) {
      showSnackbar("error".tr, "select_reservation".tr, Colors.red);
      return;
    }

    final bool computed = isWorkersComputed;
    if (computed) recalcWorkers();
    if (computed && workersTotal.value <= 0) {
      showSnackbar("error".tr, "enter_workers_count".tr, Colors.red);
      return;
    }
    final double? parsedValue = computed
        ? workersTotal.value
        : double.tryParse(amountController.text);
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
        reservationUuid: formReservationUuid.value,
        workersCount: computed ? _num(workersCountController).toInt() : null,
        femaleWorkersCount: computed
            ? _num(femaleWorkersCountController).toInt()
            : null,
        workerPrice: computed ? _num(workerPriceController) : null,
        femaleWorkerPrice: computed ? _num(femaleWorkerPriceController) : null,
      );
    } else {
      success = await expensesRepo.Adddata(
        formCategory.value!,
        nameController.text,
        parsedValue,
        dateController.text,
        reservationUuid: formReservationUuid.value,
        workersCount: computed ? _num(workersCountController).toInt() : null,
        femaleWorkersCount: computed
            ? _num(femaleWorkersCountController).toInt()
            : null,
        workerPrice: computed ? _num(workerPriceController) : null,
        femaleWorkerPrice: computed ? _num(femaleWorkerPriceController) : null,
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
    amountController.text = expense.value?.toInt().toString() ?? "";
    dateController.text = expense.datePerry ?? "";
    formCategory.value = expense.type;
    formReservationUuid.value = expense.reservationUuid;
    linkToReservation.value = expense.reservationUuid != null;
    final hasCounts =
        expense.workersCount != null || expense.femaleWorkersCount != null;
    workersByCount.value = hasCounts;
    workersCountController.text = expense.workersCount?.toString() ?? '';
    femaleWorkersCountController.text =
        expense.femaleWorkersCount?.toString() ?? '';
    workerPriceController.text = expense.workerPrice != null
        ? _plain(expense.workerPrice!)
        : '';
    femaleWorkerPriceController.text = expense.femaleWorkerPrice != null
        ? _plain(expense.femaleWorkerPrice!)
        : '';
    recalcWorkers();

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
    final hasFilter =
        searchQuery.value.isNotEmpty ||
        selectedCategory.value != 0 ||
        startDateFilter.value != null ||
        endDateFilter.value != null;

    if (hasFilter) {
      return filteredExpenses.fold(
        0.0,
        (sum, item) => sum + (item.value ?? 0.0),
      );
    } else {
      final now = DateTime.now();
      return allExpenses
          .where((item) {
            if (item.datePerry == null) return false;
            try {
              final date = DateFormat('yyyy-MM-dd').parse(item.datePerry!);
              return date.month == now.month && date.year == now.year;
            } catch (e) {
              return false;
            }
          })
          .fold(0.0, (sum, item) => sum + (item.value ?? 0.0));
    }
  }

  double get totalIncomeSum {
    final start = startDateFilter.value;
    final end = endDateFilter.value;
    final hasDateFilter = start != null && end != null;

    double sum = 0.0;
    final now = DateTime.now();

    for (var res in allReservations) {
      final double deposit =
          double.tryParse(res['deposit']?.toString() ?? '0.0') ?? 0.0;
      final String? dateStr = res['booking_date'];
      if (dateStr == null || dateStr.isEmpty) continue;

      try {
        final date = DateTime.parse(dateStr.replaceAll('/', '-'));
        if (hasDateFilter) {
          final nDate = DateTime(date.year, date.month, date.day);
          final nStart = DateTime(start.year, start.month, start.day);
          final nEnd = DateTime(end.year, end.month, end.day);
          if (!nDate.isBefore(nStart) && !nDate.isAfter(nEnd)) {
            sum += deposit;
          }
        } else {
          if (date.month == now.month && date.year == now.year) {
            sum += deposit;
          }
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return sum;
  }

  double get totalDebtsSum {
    final start = startDateFilter.value;
    final end = endDateFilter.value;
    final hasDateFilter = start != null && end != null;

    double sum = 0.0;
    final now = DateTime.now();

    for (var res in allReservations) {
      final double debt =
          double.tryParse(res['remaining_amount']?.toString() ?? '0.0') ?? 0.0;
      final String? dateStr = res['booking_date'];
      if (dateStr == null || dateStr.isEmpty) continue;

      try {
        final date = DateTime.parse(dateStr.replaceAll('/', '-'));
        if (hasDateFilter) {
          final nDate = DateTime(date.year, date.month, date.day);
          final nStart = DateTime(start.year, start.month, start.day);
          final nEnd = DateTime(end.year, end.month, end.day);
          if (!nDate.isBefore(nStart) && !nDate.isAfter(nEnd)) {
            sum += debt;
          }
        } else {
          if (date.month == now.month && date.year == now.year) {
            sum += debt;
          }
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return sum;
  }

  double get totalProfitsSum {
    return totalIncomeSum - totalExpensesSum;
  }
}
