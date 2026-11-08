import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/constant/AppTheme.dart';
import '../../../core/constant/Colorapp.dart';
import '../CustemTextField.dart';

/// Date filter: one day, or a period (from / to).
/// A day is applied as start = end = that day.
class DateFilterDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final void Function(DateTime? start, DateTime? end) onApply;
  final VoidCallback onReset;

  const DateFilterDialog({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<DateFilterDialog> createState() => _DateFilterDialogState();
}

class _DateFilterDialogState extends State<DateFilterDialog> {
  final _fmt = DateFormat('yyyy-MM-dd');
  bool isDayMode = false;
  DateTime? day;
  DateTime? start;
  DateTime? end;

  late TextEditingController dayController;
  late TextEditingController startController;
  late TextEditingController endController;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void initState() {
    super.initState();
    start = widget.initialStart;
    end = widget.initialEnd;
    // Reopened on a one-day filter → day mode
    if (start != null && end != null && _sameDay(start!, end!)) {
      isDayMode = true;
      day = start;
    }
    dayController = TextEditingController(
      text: day != null ? _fmt.format(day!) : "",
    );
    startController = TextEditingController(
      text: start != null ? _fmt.format(start!) : "",
    );
    endController = TextEditingController(
      text: end != null ? _fmt.format(end!) : "",
    );
  }

  @override
  void dispose() {
    dayController.dispose();
    startController.dispose();
    endController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime? initial) {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  void _apply() {
    if (isDayMode) {
      widget.onApply(day, day);
    } else {
      // Keep the period in order if the dates were picked the other way round
      if (start != null && end != null && end!.isBefore(start!)) {
        widget.onApply(end, start);
      } else {
        widget.onApply(start, end);
      }
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = colors.subtitleColor;
    final borderColor = colors.borderColor;
    final isArabic = Get.locale?.languageCode == 'ar';
    final compact = MediaQuery.of(context).size.width < 600;

    Widget modeButton(bool dayMode, IconData icon, String label) {
      final selected = isDayMode == dayMode;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => isDayMode = dayMode),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColor.primaryPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : subtitleColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Dialog(
      insetPadding: compact
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: compact ? double.infinity : 460,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(compact ? 16 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColor.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColor.primaryPurple,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'filter_by_date'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close_rounded, color: subtitleColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Day / period switch
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.inputFillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      modeButton(
                        true,
                        Icons.today_rounded,
                        'filter_one_day'.tr,
                      ),
                      const SizedBox(width: 4),
                      modeButton(
                        false,
                        Icons.date_range_rounded,
                        'filter_period'.tr,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (isDayMode)
                  CustemTextField(
                    controller: dayController,
                    label: 'select_date'.tr,
                    hint: 'YYYY-MM-DD',
                    icon: Icons.today_rounded,
                    readOnly: true,
                    onTap: () async {
                      final picked = await _pick(day);
                      if (picked != null) {
                        setState(() {
                          day = picked;
                          dayController.text = _fmt.format(picked);
                        });
                      }
                    },
                  )
                else ...[
                  CustemTextField(
                    controller: startController,
                    label: 'select_start_date'.tr,
                    hint: 'YYYY-MM-DD',
                    icon: Icons.date_range_rounded,
                    readOnly: true,
                    onTap: () async {
                      final picked = await _pick(start);
                      if (picked != null) {
                        setState(() {
                          start = picked;
                          startController.text = _fmt.format(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CustemTextField(
                    controller: endController,
                    label: 'select_end_date'.tr,
                    hint: 'YYYY-MM-DD',
                    icon: Icons.date_range_rounded,
                    readOnly: true,
                    onTap: () async {
                      final picked = await _pick(end ?? start);
                      if (picked != null) {
                        setState(() {
                          end = picked;
                          endController.text = _fmt.format(picked);
                        });
                      }
                    },
                  ),
                ],
                const SizedBox(height: 24),

                // Footer
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        widget.onReset();
                        Get.back();
                      },
                      child: Text(
                        'reset'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'apply'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
