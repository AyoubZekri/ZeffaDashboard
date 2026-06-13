import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class CustemDropDownField<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?) onChanged;

  final String? hint;

  const CustemDropDownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final bgColor = colors.inputFillColor;
    final borderColor = colors.borderColor;
    final iconColor = theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(width: 1, color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          hint: hint != null 
              ? Text(hint!, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13)) 
              : null,
          items: items,
          value: value,
          onChanged: onChanged,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surface,
              border: Border.all(color: borderColor),
            ),
            elevation: 8,
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            iconSize: 24,
            iconEnabledColor: iconColor,
          ),
        ),
      ),
    );
  }
}
