import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../data/model/ReservationModel.dart';

/// Three-dots button that opens a small menu with all the reservation actions.
class ReservationActionsMenu extends StatelessWidget {
  final ReservationModel reservation;
  final ValueChanged<ReservationModel>? onView;
  final ValueChanged<ReservationModel>? onEdit;
  final ValueChanged<ReservationModel>? onDelete;
  final ValueChanged<ReservationModel>? onPrint;
  final ValueChanged<ReservationModel>? onAddPayment;
  final ValueChanged<ReservationModel>? onEditGuests;
  final ValueChanged<ReservationModel>? onExpenses;

  const ReservationActionsMenu({
    super.key,
    required this.reservation,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onPrint,
    this.onAddPayment,
    this.onEditGuests,
    this.onExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final textColor = theme.colorScheme.onSurface;

    PopupMenuItem<String> item(
      String value,
      IconData icon,
      Color color,
      String label,
    ) {
      return PopupMenuItem<String>(
        value: value,
        height: 44,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: value == 'delete' ? Colors.red : textColor,
              ),
            ),
          ],
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'actions'.tr,
      color: theme.colorScheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.borderColor),
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView?.call(reservation);
            break;
          case 'expenses':
            onExpenses?.call(reservation);
            break;
          case 'payment':
            onAddPayment?.call(reservation);
            break;
          case 'guests':
            onEditGuests?.call(reservation);
            break;
          case 'print':
            onPrint?.call(reservation);
            break;
          case 'edit':
            onEdit?.call(reservation);
            break;
          case 'delete':
            onDelete?.call(reservation);
            break;
        }
      },
      itemBuilder: (context) => [
        if (onView != null)
          item('view', Icons.visibility_outlined, AppColor.primaryPurple,
              'view_details'.tr),
        if (onExpenses != null)
          item('expenses', Icons.receipt_long_outlined, Colors.teal,
              'reservation_expenses'.tr),
        if (onAddPayment != null)
          item('payment', Icons.payments_outlined, Colors.green,
              'add_payment'.tr),
        if (onEditGuests != null)
          item('guests', Icons.group_outlined, Colors.blue, 'edit_guests'.tr),
        if (onPrint != null)
          item('print', Icons.print_outlined, Colors.blueGrey,
              'print_reservation'.tr),
        if (onEdit != null)
          item('edit', Icons.edit_outlined, Colors.amber.shade700, 'edit'.tr),
        if (onDelete != null) ...[
          const PopupMenuDivider(),
          item('delete', Icons.delete_outline_rounded, Colors.red,
              'delete'.tr),
        ],
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.inputFillColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.borderColor),
        ),
        child: Icon(Icons.more_horiz_rounded, color: textColor, size: 22),
      ),
    );
  }
}
