import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../data/model/ReservationModel.dart';

class ReservationDetailsDialog extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationDetailsDialog({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    // Determine colors from global theme
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = colors.subtitleColor;
    final cardColor = colors.cardColor;
    final borderColor = colors.borderColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: bgColor,
      child: Container(
        width: 850,
        height: 750,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor.primaryPurple,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.local_offer, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'booking_confirmation'.tr, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                              const TextSpan(text: ' '),
                              TextSpan(text: reservation.id?.toString() ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: subtitleColor, fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(reservation.statusKey.tr, style: TextStyle(fontSize: 14, color: subtitleColor, fontFamily: 'Cairo')),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        // Trigger edit dialog callback here if needed
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text('edit_btn'.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.primaryPurple,
                        side: BorderSide(color: AppColor.primaryPurple.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: textColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top row cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Identity
                        Expanded(
                          flex: 3,
                          child: _buildCard(
                            cardColor, borderColor,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCardHeader('customer_identity'.tr, Icons.person_outline, AppColor.primaryPurple),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColor.primaryPurple.withOpacity(0.1),
                                      child: Text(reservation.avatarInitials, style: const TextStyle(fontSize: 20, color: AppColor.primaryPurple, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('full_name'.tr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 1.2)),
                                          const SizedBox(height: 2),
                                          Text(reservation.customerName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('contact'.tr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 1.2)),
                                          const SizedBox(height: 2),
                                          Text(reservation.phoneNumber, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor, fontFamily: 'Cairo')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Event Type
                        Expanded(
                          flex: 2,
                          child: _buildCard(
                            cardColor, borderColor,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCardHeader('event_type_label'.tr, Icons.celebration_outlined, AppColor.primaryPurple),
                                const SizedBox(height: 16),
                                Text(reservation.partyTypeName ?? 'N/A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: AppColor.primaryPurple, borderRadius: BorderRadius.circular(20)),
                                      child: Text('vip_service'.tr, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('confirmed_days_ago'.tr, style: TextStyle(fontSize: 12, color: subtitleColor)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Middle row cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date & Time
                        Expanded(
                          flex: 2,
                          child: _buildCard(
                            cardColor, borderColor,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCardHeader('date_and_time'.tr, Icons.calendar_today_outlined, AppColor.primaryPurple),
                                const SizedBox(height: 16),
                                Text('scheduled_date'.tr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 1.2)),
                                const SizedBox(height: 4),
                                Text(reservation.bookingDate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                                const SizedBox(height: 16),
                                Text('duration'.tr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 1.2)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: AppColor.primaryPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text(_getPeriodLabel(reservation.bookingPeriod), style: const TextStyle(fontSize: 12, color: AppColor.primaryPurple, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Guest Count
                        Expanded(
                          flex: 2,
                          child: _buildCard(
                            cardColor, borderColor,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCardHeader('guest_count_label'.tr, Icons.people_alt_outlined, AppColor.primaryPurple),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text("${reservation.numberOfMen}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
                                        Text('gentlemen'.tr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 1.2)),
                                      ],
                                    ),
                                    Container(width: 1, height: 40, color: borderColor),
                                    Column(
                                      children: [
                                        Text("${reservation.numberOfWomen}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
                                        Text('ladies'.tr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor, letterSpacing: 1.2)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Financials
                        Expanded(
                          flex: 2,
                          child: _buildCard(
                            isDark ? const Color(0xFF1E1E2C) : const Color(0xFF2C2C3E), // Dark card for financials regardless of light mode
                            Colors.transparent,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCardHeader('financials_label'.tr, Icons.money, Colors.white),
                                const SizedBox(height: 16),
                                _buildFinancialRow('paid_amount'.tr, "\$${reservation.deposit}", AppColor.primaryPurple),
                                const SizedBox(height: 8),
                                _buildFinancialRow('remaining_amount'.tr, "\$${reservation.remainingAmount}", Colors.white),
                                const SizedBox(height: 16),
                                Container(height: 1, color: Colors.white24),
                                const SizedBox(height: 16),
                                _buildFinancialRow('total_label'.tr, "\$${reservation.price}", Colors.white, isBold: true),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bottom row cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Culinary Selection
                        Expanded(
                          flex: 3,
                          child: _buildCard(
                            cardColor, borderColor,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCardHeader('culinary_selection'.tr, Icons.restaurant_menu, AppColor.primaryPurple),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: reservation.dishesNameList.isNotEmpty
                                      ? reservation.dishesNameList.map((name) => _buildChip(name)).toList()
                                      : [Text('no_dishes_selected'.tr, style: TextStyle(fontSize: 13, color: subtitleColor))],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Special Requests
                        Expanded(
                          flex: 2,
                          child: _buildCard(
                            AppColor.primaryPurple, Colors.transparent,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCardHeader('special_requests'.tr, Icons.notes, Colors.white),
                                const SizedBox(height: 16),
                                Text(
                                  reservation.notes != null && reservation.notes!.isNotEmpty ? reservation.notes! : 'no_notes'.tr,
                                  style: const TextStyle(fontSize: 13, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('dismiss'.tr, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text('send_receipt'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Color color, Color borderColor, Widget child) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (borderColor != Colors.transparent) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo', letterSpacing: 1.1)),
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isBold ? 14 : 13, color: isBold ? Colors.white : Colors.white70)),
        Text(value, style: TextStyle(fontSize: isBold ? 18 : 16, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildChip(String label, {bool isOutlined = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : AppColor.primaryPurple.withOpacity(0.1),
        border: isOutlined ? Border.all(color: AppColor.primaryPurple.withOpacity(0.3)) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOutlined) ...[
            const CircleAvatar(radius: 3, backgroundColor: AppColor.primaryPurple),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.primaryPurple)),
        ],
      ),
    );
  }

  String _getPeriodLabel(int? period) {
    switch (period) {
      case 1: return 'period_full_day'.tr;
      case 2: return 'period_half_day'.tr;
      case 3: return 'period_evening'.tr;
      case 4: return 'period_morning'.tr;
      default: return 'N/A';
    }
  }
}
