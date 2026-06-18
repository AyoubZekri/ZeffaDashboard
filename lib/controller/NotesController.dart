import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import '../../data/datasource/Remote/Notes.dart';
import '../../data/model/NoteModel.dart';

class NotesController extends GetxController {
  late final TextEditingController searchController;
  final RxString searchQuery = "".obs;

  final RxList<NoteModel> allNotes = <NoteModel>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 5;

  // Form Fields
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  bool isEdit = false;
  String? editUuid;

  final Notes notesRepo = Notes(Get.find());
  Statusrequest statusrequest = Statusrequest.none;

  @override
  void onInit() {
    searchController = TextEditingController();
    titleController = TextEditingController();
    descriptionController = TextEditingController();

    loadNotes();

    ever(searchQuery, (_) => currentPage.value = 1);

    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void clearFields() {
    titleController.clear();
    descriptionController.clear();
    isEdit = false;
    editUuid = null;
  }

  Future<void> loadNotes() async {
    statusrequest = Statusrequest.loadeng;
    update();
    try {
      final result = await notesRepo.viewdata();
      if (result.isEmpty) {
        statusrequest = Statusrequest.none;
        allNotes.clear();
      } else {
        allNotes.assignAll(NoteModel.fromList(result));
        statusrequest = Statusrequest.success;
      }
    } catch (e) {
      print("Error loading notes: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  // Filter logic
  List<NoteModel> get filteredNotes {
    final query = searchQuery.value.trim().toLowerCase();

    return allNotes.where((note) {
      final matchesSearch =
          query.isEmpty ||
          (note.title?.toLowerCase().contains(query) ?? false) ||
          (note.description?.toLowerCase().contains(query) ?? false);

      return matchesSearch;
    }).toList();
  }

  // Pagination logic
  List<NoteModel> get paginatedNotes {
    final list = filteredNotes;
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    if (startIndex >= list.length) return [];

    final endIndex = startIndex + itemsPerPage;
    return list.sublist(
      startIndex,
      endIndex > list.length ? list.length : endIndex,
    );
  }

  int get totalPages {
    final length = filteredNotes.length;
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

  Future<void> saveNote() async {
    if (!formState.currentState!.validate()) return;

    bool success = false;
    if (isEdit) {
      success = await notesRepo.Updatedata(
        editUuid!,
        titleController.text,
        descriptionController.text,
      );
    } else {
      success = await notesRepo.Adddata(
        titleController.text,
        descriptionController.text,
      );
    }

    if (success) {
      Get.back();
      loadNotes();
      clearFields();
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }

  void setEditData(NoteModel note) {
    isEdit = true;
    editUuid = note.uuid;
    titleController.text = note.title ?? "";
    descriptionController.text = note.description ?? "";
  }

  Future<void> deleteNote(String uuid) async {
    final success = await notesRepo.Deletedata(uuid);
    if (success) {
      loadNotes();
      showSnackbar("success".tr, "note_deleted_success".tr, Colors.green);
    } else {
      showSnackbar("error".tr, "operation_failed".tr, Colors.red);
    }
  }
}
