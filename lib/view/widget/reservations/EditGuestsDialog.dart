import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../controller/Reservationscontroller.dart';
import '../../../data/model/ReservationModel.dart';

class EditGuestsDialog extends StatefulWidget {
  final ReservationModel reservation;

  const EditGuestsDialog({super.key, required this.reservation});

  @override
  State<EditGuestsDialog> createState() => _EditGuestsDialogState();
}

class _EditGuestsDialogState extends State<EditGuestsDialog> {
  late TextEditingController menController;
  late TextEditingController womenController;

  int get menCount => int.tryParse(menController.text) ?? 0;
  int get womenCount => int.tryParse(womenController.text) ?? 0;
  int get totalGuests => menCount + womenCount;

  @override
  void initState() {
    super.initState();
    menController = TextEditingController(text: widget.reservation.numberOfMen.toString());
    womenController = TextEditingController(text: widget.reservation.numberOfWomen.toString());
  }

  @override
  void dispose() {
    menController.dispose();
    womenController.dispose();
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
        width: 460,
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
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.group_outlined, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('edit_guests'.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor, )),
                      const SizedBox(height: 4),
                      Text('edit_guests_desc'.tr, style: TextStyle(fontSize: 12, color: subtitleColor)),
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
                        Text(widget.reservation.bookingDate, style: TextStyle(fontSize: 12, color: subtitleColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Guest count fields
            Row(
              children: [
                Expanded(child: _buildGuestField(
                  label: 'men_count'.tr,
                  controller: menController,
                  icon: Icons.man,
                  color: Colors.blue,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  colors: colors,
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildGuestField(
                  label: 'women_count'.tr,
                  controller: womenController,
                  icon: Icons.woman,
                  color: Colors.pink,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  colors: colors,
                )),
              ],
            ),
            const SizedBox(height: 20),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primaryPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.primaryPurple.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: AppColor.primaryPurple, size: 20),
                      const SizedBox(width: 8),
                      Text('total_guests'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                    ],
                  ),
                  Text('$totalGuests', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColor.primaryPurple)),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
                    onPressed: () {
                      final ctrl = Get.find<Reservationscontroller>();
                      ctrl.updateGuestCount(widget.reservation.uuid, menCount, womenCount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('save'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color subtitleColor,
    required AppColors colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: subtitleColor, fontSize: 13),
            prefixIcon: Icon(icon, color: color, size: 22),
            filled: true,
            fillColor: colors.inputFillColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 1.5)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
