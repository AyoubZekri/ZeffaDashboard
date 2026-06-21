import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../controller/Reservationscontroller.dart';
import '../../../data/model/ReservationModel.dart';

class AddPaymentDialog extends StatefulWidget {
  final ReservationModel reservation;

  const AddPaymentDialog({super.key, required this.reservation});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final paymentController = TextEditingController();
  double newPayment = 0;

  double get currentDeposit => widget.reservation.deposit;
  double get reservationPrice => widget.reservation.price;
  double get newTotalDeposit => currentDeposit + newPayment;
  double get newRemaining => reservationPrice - newTotalDeposit;
  bool get exceedsPrice => newTotalDeposit > reservationPrice;

  @override
  void dispose() {
    paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = colors.subtitleColor;
    final bgColor = theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: bgColor,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.payments_outlined, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('add_payment'.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 4),
                      Text('add_payment_desc'.tr, style: TextStyle(fontSize: 12, color: subtitleColor)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close, color: textColor)),
              ],
            ),
            const SizedBox(height: 24),

            // Customer info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColor.primaryPurple.withValues(alpha: 0.1),
                    child: Text(widget.reservation.avatarInitials, style: const TextStyle(color: AppColor.primaryPurple, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.reservation.customerName, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 15)),
                        Text(widget.reservation.partyTypeName ?? '', style: TextStyle(fontSize: 12, color: subtitleColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Current info row
            Row(
              children: [
                Expanded(child: _buildInfoCard('reservation_price'.tr, reservationPrice.toStringAsFixed(1), AppColor.primaryPurple, colors)),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoCard('current_deposit'.tr, currentDeposit.toStringAsFixed(1), Colors.green, colors)),
              ],
            ),
            const SizedBox(height: 20),

            // Payment input
            Text('new_payment_amount'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 8),
            TextFormField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              onChanged: (val) {
                setState(() {
                  newPayment = double.tryParse(val) ?? 0;
                });
              },
              decoration: InputDecoration(
                hintText: 'new_payment_hint'.tr,
                hintStyle: TextStyle(color: subtitleColor, fontSize: 13),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.green, size: 20),
                filled: true,
                fillColor: colors.inputFillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 1.5)),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Preview
            if (newPayment > 0) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: exceedsPrice ? Colors.red.withValues(alpha: 0.08) : Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: exceedsPrice ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _buildPreviewRow('new_total_deposit'.tr, newTotalDeposit.toStringAsFixed(1), exceedsPrice ? Colors.red : Colors.green),
                    const SizedBox(height: 8),
                    _buildPreviewRow('new_remaining'.tr, exceedsPrice ? '---' : newRemaining.toStringAsFixed(1), textColor),
                    if (exceedsPrice) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text('payment_exceeds_price'.tr, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: colors.borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('cancel'.tr),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (newPayment > 0 && !exceedsPrice) ? () {
                      final ctrl = Get.find<Reservationscontroller>();
                      ctrl.addPayment(widget.reservation.uuid, currentDeposit, reservationPrice, newPayment);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('confirm_payment'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: colors.subtitleColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
