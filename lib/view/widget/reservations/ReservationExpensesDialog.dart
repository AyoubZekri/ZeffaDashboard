import 'package:zeffa/core/functions/format_money.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../data/datasource/Remote/Expenses.dart';
import '../../../data/model/ExpenseModel.dart';
import '../../../data/model/ReservationModel.dart';

/// Expenses linked to one reservation (wedding), with the price minus expenses.
class ReservationExpensesDialog extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationExpensesDialog({super.key, required this.reservation});

  Future<List<ExpenseModel>> _load() async {
    final rows = await Expenses(Get.find()).viewByReservation(reservation.uuid);
    return ExpenseModel.fromList(rows);
  }

  String _categoryLabel(int? type) {
    switch (type) {
      case 1:
        return 'workers'.tr;
      case 4:
        return 'maintenance'.tr;
      case 2:
        return 'cleaning_materials'.tr;
      default:
        return 'other_expenses'.tr;
    }
  }

  IconData _categoryIcon(int? type) {
    switch (type) {
      case 1:
        return Icons.people_outline_rounded;
      case 4:
        return Icons.build_circle_outlined;
      case 2:
        return Icons.cleaning_services_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Color _categoryColor(int? type) {
    switch (type) {
      case 1:
        return Colors.indigo;
      case 4:
        return Colors.orange;
      case 2:
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final textColor = theme.colorScheme.onSurface;
    final isArabic = Get.locale?.languageCode == 'ar';
    // Phone: use the screen width; desktop: a narrow dialog
    final compact = MediaQuery.of(context).size.width < 600;
    final side = compact ? 14.0 : 18.0;

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
            maxWidth: compact ? double.infinity : 440,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Container(
                padding: EdgeInsets.fromLTRB(side, 14, 6, 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.borderColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColor.purpleGradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'reservation_expenses'.tr,
                            style: TextStyle(
                              fontSize: compact ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${reservation.customerName} • ${reservation.bookingDate}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close_rounded, color: colors.subtitleColor),
                    ),
                  ],
                ),
              ),

              // ── Content ──
              Flexible(
                child: FutureBuilder<List<ExpenseModel>>(
                  future: _load(),
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryPurple,
                          ),
                        ),
                      );
                    }

                    final expenses = snap.data ?? [];
                    final total = expenses.fold<double>(
                      0.0,
                      (sum, e) => sum + (e.value ?? 0.0),
                    );
                    final remaining = reservation.price - total;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (expenses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 36,
                                  color: colors.subtitleColor.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'no_reservation_expenses'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(
                                horizontal: side,
                                vertical: 4,
                              ),
                              itemCount: expenses.length,
                              separatorBuilder: (_, _) => Divider(
                                height: 1,
                                color: colors.borderColor,
                              ),
                              itemBuilder: (context, i) {
                                final e = expenses[i];
                                final color = _categoryColor(e.type);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            color.withValues(alpha: 0.1),
                                        child: Icon(
                                          _categoryIcon(e.type),
                                          size: 16,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.description ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                            Text(
                                              _categoryLabel(e.type),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${formatMoney(e.value)} DA",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                        // ── Summary ──
                        Container(
                          margin: EdgeInsets.fromLTRB(side, 4, side, side),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.primaryPurple.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColor.primaryPurple.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            children: [
                              _summaryRow(
                                'total_price'.tr,
                                reservation.price,
                                textColor,
                                colors.subtitleColor,
                              ),
                              const SizedBox(height: 6),
                              _summaryRow(
                                'total_expenses'.tr,
                                total,
                                Colors.red.shade400,
                                colors.subtitleColor,
                              ),
                              Divider(
                                height: 16,
                                color: AppColor.primaryPurple.withValues(alpha: 0.2),
                              ),
                              _summaryRow(
                                'remaining_after_expenses'.tr,
                                remaining,
                                remaining >= 0 ? Colors.green : Colors.red,
                                textColor,
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double value,
    Color valueColor,
    Color labelColor, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: labelColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "${formatMoney(value)} DA",
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
