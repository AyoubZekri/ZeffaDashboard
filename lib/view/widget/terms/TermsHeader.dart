import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class TermsHeader extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onAddPressed;
  final TextEditingController? searchController;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const TermsHeader({
    super.key,
    this.onSearchChanged,
    this.onAddPressed,
    this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textColor = theme.colorScheme.onSurface;
    final isArabic = Get.locale?.languageCode == 'ar';

    final filters = [
      {"key": "all", "label": "all".tr},
      {"key": "internal_rules", "label": "internal_rules".tr},
      {"key": "contract_terms", "label": "contract_terms".tr},
      {"key": "required_procedures", "label": "required_procedures".tr},
      {"key": "required_documents", "label": "required_documents".tr},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'terms_management'.tr,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? "إدارة ومتابعة البنود والوثائق الرسمية الخاصة بالقاعة"
                      : "Manage and track hall official terms and documents",
                  style: TextStyle(fontSize: 14, color: colors.subtitleColor),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: colors.inputFillColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'search_terms'.tr,
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: colors.subtitleColor,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colors.subtitleColor,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: onAddPressed,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'add_term'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 21,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Filter tabs selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filters.map((filter) {
              final isSelected = selectedFilter == filter["key"];
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: ChoiceChip(
                  label: Text(
                    filter["label"]!,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Cairo',
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColor.primaryPurple,
                  backgroundColor: colors.inputFillColor,
                  showCheckmark: false,

                  onSelected: (val) {
                    if (val) {
                      onFilterChanged(filter["key"]!);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : colors.borderColor,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
