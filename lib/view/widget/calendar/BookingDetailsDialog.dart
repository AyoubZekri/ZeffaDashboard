import 'package:zeffa/core/functions/role_permissions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/CalendarController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';

class BookingDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> event;

  const BookingDetailsDialog({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final isArabic = Get.locale?.languageCode == 'ar';

    final bookingId = event['bookingId'] ?? '#---';
    final eventType = event['title'] ?? event['type_of_party_uuid'] ?? '---';
    final customerName = event['customerName'] ?? '---';
    final customerPhone = event['customerPhone'] ?? '---';

    final List<dynamic> reservations = event['reservations'] ?? [];

    final CalendarController ctrl = Get.find();

    // Day booked for only one period → the other one can still be reserved
    // (3 = evening booked → morning free, 4 = morning booked → evening free)
    final int? bookedPeriod = event['booking_period'] as int?;
    final int? freePeriod = bookedPeriod == 3
        ? 4
        : (bookedPeriod == 4 ? 3 : null);
    final String? dayDate = reservations.isNotEmpty
        ? reservations.first['date']?.toString()
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColor.purpleGradient,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'booking_details'.tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // ── Details Cards ──
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (reservations.isNotEmpty)
                        ...reservations.map((res) {
                          final resId = res['bookingId'] ?? '#---';
                          final resType =
                              res['title'] ??
                              res['type_of_party_uuid'] ??
                              '---';
                          final resName = res['customerName'] ?? '---';
                          final resPhone = res['customerPhone'] ?? '---';
                          final periodKey = res['booking_period'];
                          final periodStr = periodKey == 3
                              ? 'period_evening'.tr
                              : (periodKey == 4
                                    ? 'period_morning'.tr
                                    : 'period_full_day'.tr);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.inputFillColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${'booking_details'.tr} $resId ($periodStr)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryPurple,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailItem(
                                  context,
                                  icon: Icons.celebration_rounded,
                                  label: 'event_type_label'.tr,
                                  value: resType,
                                  colors: colors,
                                ),
                                const SizedBox(height: 8),
                                _buildDetailItem(
                                  context,
                                  icon: Icons.person_rounded,
                                  label: 'customer_name_label'.tr,
                                  value: resName,
                                  colors: colors,
                                ),
                                const SizedBox(height: 8),
                                _buildDetailItem(
                                  context,
                                  icon: Icons.phone_android_rounded,
                                  label: 'phone_number_label'.tr,
                                  value: resPhone,
                                  colors: colors,
                                  valueDirection: TextDirection.ltr,
                                ),
                              ],
                            ),
                          );
                        }).toList()
                      else ...[
                        _buildDetailItem(
                          context,
                          icon: Icons.tag_rounded,
                          label: 'booking_id_label'.tr,
                          value: bookingId,
                          colors: colors,
                          valueColor: AppColor.primaryPurple,
                          isBold: true,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          context,
                          icon: Icons.celebration_rounded,
                          label: 'event_type_label'.tr,
                          value: eventType,
                          colors: colors,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          context,
                          icon: Icons.person_rounded,
                          label: 'customer_name_label'.tr,
                          value: customerName,
                          colors: colors,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          context,
                          icon: Icons.phone_android_rounded,
                          label: 'phone_number_label'.tr,
                          value: customerPhone,
                          colors: colors,
                          valueDirection: TextDirection.ltr,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Free period card ──
              if (freePeriod != null &&
                  dayDate != null &&
                  hasRolePermission('add_reservation')) ...[
                _buildFreePeriodCard(
                  context,
                  freePeriod: freePeriod,
                  colors: colors,
                  onBook: () {
                    Get.back();
                    ctrl.addReservationForDate(
                      DateTime.parse(dayDate),
                      period: freePeriod,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // ── Action Buttons ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Show Delete only if we have a UUID (e.g. not a hardcoded placeholder missing it) and it's not a reservation
                  if (event['uuid'] != null && event['type'] != 'reserved')
                    TextButton.icon(
                      onPressed: () async {
                        Get.back();
                        await ctrl.deleteSpecialDate(event['uuid']);
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      label: Text(
                        'delete'.tr,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ok'.tr,
                      style: const TextStyle(
                        fontSize: 15,
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
    );
  }

  Widget _buildFreePeriodCard(
    BuildContext context, {
    required int freePeriod,
    required AppColors colors,
    required VoidCallback onBook,
  }) {
    final theme = Theme.of(context);
    final isMorning = freePeriod == 4;
    final accent = isMorning ? Colors.orange : Colors.indigo;
    final periodName = isMorning ? 'period_morning'.tr : 'period_evening'.tr;

    final info = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isMorning ? Icons.light_mode_rounded : Icons.nights_stay_rounded,
            color: accent,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'period_available'.trParams({'period': periodName}),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'period_available_desc'.tr,
                style: TextStyle(fontSize: 12, color: colors.subtitleColor),
              ),
            ],
          ),
        ),
      ],
    );

    final button = ElevatedButton.icon(
      onPressed: onBook,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(
        'book_this_period'.tr,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      // Narrow (phone) → button under the text, wide → side by side
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 380) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [info, const SizedBox(height: 12), button],
            );
          }
          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required AppColors colors,
    Color? valueColor,
    bool isBold = false,
    TextDirection? valueDirection,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.inputFillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColor.primaryPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: colors.subtitleColor),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  textDirection: valueDirection,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    color: valueColor ?? theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
