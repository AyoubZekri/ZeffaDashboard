import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../data/model/HallModel.dart';

/// Horizontal hall chips. Keys: '' = account hall, uuid = extra hall,
/// null = "all halls" (only when [showAll] is true).
class HallChips extends StatelessWidget {
  final List<HallModel> halls;
  final String? selectedKey;
  final ValueChanged<String?> onSelected;
  final bool showAll;

  const HallChips({
    super.key,
    required this.halls,
    required this.selectedKey,
    required this.onSelected,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;

    Widget chip(String? key, String label, IconData icon) {
      final isSelected = key == selectedKey;
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 10),
        child: ChoiceChip(
          selected: isSelected,
          onSelected: (_) => onSelected(key),
          avatar: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppColor.primaryPurple,
          ),
          label: Text(
            label,
            style: TextStyle(
              // Chips don't always pick up the theme font, so set it here
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColor.textDark : AppColor.textLight),
            ),
          ),
          showCheckmark: false,
          selectedColor: AppColor.primaryPurple,
          backgroundColor: colors.cardColor,
          side: BorderSide(
            color: isSelected ? AppColor.primaryPurple : colors.borderColor,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (showAll) chip(null, 'all_halls'.tr, Icons.apps_rounded),
          ...halls.map(
            (hall) => chip(
              hall.uuid ?? '',
              (hall.name?.isNotEmpty ?? false) ? hall.name! : 'account_hall'.tr,
              Icons.meeting_room_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
