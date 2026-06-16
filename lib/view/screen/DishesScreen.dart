import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/DishesController.dart';
import '../../core/constant/AppTheme.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/functions/dialogDelete.dart';
import '../widget/dishes/DishCard.dart';
import '../widget/dishes/DishFormDialog.dart';
import '../widget/dishes/DishesHeader.dart';

class DishesScreen extends StatelessWidget {
  const DishesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isArabic = Get.locale?.languageCode == 'ar';

    // Inject the DishesController
    final ctrl = Get.put(DishesController());

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
              DishesHeader(
                onAddPressed: () {
                  Get.dialog(const DishFormDialog(), barrierDismissible: true);
                },
              ),
              const SizedBox(height: 24),

              // ── Category Filters / Chips ──
              Obx(() {
                final selectedUuid = ctrl.selectedCategoryUuid.value;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(
                            'all'.tr,
                            style: TextStyle(
                              color: selectedUuid == null
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          selected: selectedUuid == null,
                          onSelected: (selected) {
                            if (selected) {
                              ctrl.selectedCategoryUuid.value = null;
                            }
                          },
                          selectedColor: AppColor.primaryPurple,
                          backgroundColor: colors.inputFillColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: selectedUuid == null
                                  ? AppColor.primaryPurple
                                  : colors.borderColor,
                            ),
                          ),
                        ),
                      ),
                      ...ctrl.dishCategories.map((cat) {
                        final isSelected = selectedUuid == cat.uuid;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text(
                              cat.name ?? "",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                ctrl.selectedCategoryUuid.value = cat.uuid;
                              }
                            },
                            selectedColor: AppColor.primaryPurple,
                            backgroundColor: colors.inputFillColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColor.primaryPurple
                                    : colors.borderColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Responsive Dishes Grid Widget
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive column counts based on width
                    int crossAxisCount = 3;
                    if (constraints.maxWidth < 750) {
                      crossAxisCount = 2;
                    } else if (constraints.maxWidth < 1100) {
                      crossAxisCount = 3;
                    } else {
                      crossAxisCount =
                          4; // Better spread for wider desktop views
                    }

                    return Obx(() {
                      final dishes = ctrl.filteredDishes;

                      return GridView.builder(
                        itemCount: dishes.length,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          mainAxisExtent: 245,
                        ),
                        itemBuilder: (context, index) {
                          final dish = dishes[index];
                          final title = dish.name ?? "";

                          return DishCard(
                            item: dish,
                            onEdit: () {
                              ctrl.viewCategory();
                              ctrl.setEditData(dish);
                              Get.dialog(
                                DishFormDialog(isEdit: true),
                                barrierDismissible: true,
                              );
                            },
                            onDelete: () {
                              dialogDelete(
                                title: 'delete_confirm_btn'.tr,
                                content:
                                    'delete_dish_confirm_title'.tr,
                                onConfirm: () {
                                  ctrl.deleteDishes(dish.uuid!);
                                  Get.snackbar(
                                    'success'.tr,
                                    'dish_deleted_success'.tr,
                                    backgroundColor:
                                        theme.brightness == Brightness.dark
                                        ? const Color(0xFF1B5E20)
                                        : const Color(0xFFE8F5E9),
                                    colorText:
                                        theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.green.shade900,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                              );
                            },
                          );
                        },
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
