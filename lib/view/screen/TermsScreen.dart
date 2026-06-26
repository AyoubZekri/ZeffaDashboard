import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/TermsController.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/constant/AppTheme.dart';
import '../../core/functions/dialogDelete.dart';
import '../widget/terms/TermCard.dart';
import '../widget/terms/TermFormDialog.dart';
import '../widget/terms/TermsHeader.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';
    Get.delete<TermsController>();
    final ctrl = Get.put(TermsController());

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
              Obx(
                () => TermsHeader(
                  searchController: ctrl.searchController,
                  onSearchChanged: (val) => ctrl.searchQuery.value = val,
                  selectedFilter: ctrl.selectedTypeFilter.value,
                  onFilterChanged: (val) => ctrl.selectedTypeFilter.value = val,
                  onAddPressed: () {
                    ctrl.clearFields();
                    Get.dialog(
                      const TermFormDialog(),
                      barrierDismissible: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),

              // Responsive Terms Grid Widget
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 3;
                    if (constraints.maxWidth < 750) {
                      crossAxisCount = 1;
                    } else if (constraints.maxWidth < 1100) {
                      crossAxisCount = 2;
                    } else if (constraints.maxWidth >= 1500) {
                      crossAxisCount = 4;
                    }

                    return Obx(() {
                      final terms = ctrl.paginatedTerms;

                      if (ctrl.allTerms.isEmpty &&
                          ctrl.statusrequest == Statusrequest.none) {
                        return Center(
                          child: Text(
                            'no_terms_found'.tr,
                            style: TextStyle(
                              color: colors.subtitleColor,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      if (ctrl.statusrequest == Statusrequest.loadeng) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryPurple,
                          ),
                        );
                      }

                      if (terms.isEmpty) {
                        return Center(
                          child: Text(
                            'no_terms_found'.tr,
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
                              itemCount: terms.length,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    mainAxisExtent: 240, // Height of the card
                                  ),
                              itemBuilder: (context, index) {
                                final term = terms[index];

                                return TermCard(
                                  item: term,
                                  onEdit: () {
                                    ctrl.setEditData(term);
                                    Get.dialog(
                                      const TermFormDialog(isEdit: true),
                                      barrierDismissible: true,
                                    );
                                  },
                                  onDelete: () {
                                    dialogDelete(
                                      title: 'delete_confirm_btn'.tr,
                                      content: 'delete_term_confirm'.tr,
                                      onConfirm: () {
                                        ctrl.deleteTerm(term.uuid!);
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
                                      color:
                                          ctrl.currentPage.value <
                                              ctrl.totalPages
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
