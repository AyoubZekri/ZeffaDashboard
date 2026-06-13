import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/NotesController.dart';
import '../../core/constant/AppTheme.dart';
import '../../core/functions/dialogDelete.dart';
import '../widget/notes/NoteCard.dart';
import '../widget/notes/NoteFormDialog.dart';
import '../widget/notes/NotesHeader.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';

    final ctrl = Get.put(NotesController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Widget
              NotesHeader(
                searchController: ctrl.searchController,
                onSearchChanged: (val) => ctrl.searchQuery.value = val,
                onAddPressed: () {
                  ctrl.clearFields();
                  Get.dialog(
                    const NoteFormDialog(),
                    barrierDismissible: true,
                  );
                },
              ),
              const SizedBox(height: 36),

              // Responsive Notes Grid Widget
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 3;
                    if (constraints.maxWidth < 750) {
                      crossAxisCount = 2;
                    } else if (constraints.maxWidth < 1100) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth >= 1500) {
                      crossAxisCount = 4;
                    }

                    return Obx(() {
                      final notes = ctrl.paginatedNotes;

                      if (ctrl.allNotes.isEmpty) {
                        return Center(
                          child: Text(
                            'no_notes_found'.tr,
                            style: TextStyle(
                              color: colors.subtitleColor,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              itemCount: notes.length,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                mainAxisExtent: 220, // Height of the card
                              ),
                              itemBuilder: (context, index) {
                                final note = notes[index];
                                final title = note.title ?? '';

                                return NoteCard(
                                  item: note,
                                  onEdit: () {
                                    ctrl.setEditData(note);
                                    Get.dialog(
                                      const NoteFormDialog(isEdit: true),
                                      barrierDismissible: true,
                                    );
                                  },
                                  onDelete: () {
                                    dialogDelete(
                                      title: 'delete_confirm_btn'.tr,
                                      content:
                                          "${'delete_note_confirm'.tr} \n($title)؟",
                                      onConfirm: () {
                                        ctrl.deleteNote(note.uuid!);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          
                          // Pagination Controls
                          if (ctrl.totalPages > 1)
                            Container(
                              padding: const EdgeInsets.only(top: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: ctrl.prevPage,
                                    icon: Icon(
                                      isArabic
                                          ? Icons.chevron_right_rounded
                                          : Icons.chevron_left_rounded,
                                      color: ctrl.currentPage.value > 1
                                          ? theme.colorScheme.onSurface
                                          : colors.subtitleColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${ctrl.currentPage.value} / ${ctrl.totalPages}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    onPressed: ctrl.nextPage,
                                    icon: Icon(
                                      isArabic
                                          ? Icons.chevron_left_rounded
                                          : Icons.chevron_right_rounded,
                                      color: ctrl.currentPage.value < ctrl.totalPages
                                          ? theme.colorScheme.onSurface
                                          : colors.subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
