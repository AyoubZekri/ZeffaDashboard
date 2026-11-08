import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/constant/AppTheme.dart';
import '../../../data/model/ReservationModel.dart';
import '../../../core/services/Services.dart';
import 'ReservationActionsMenu.dart';

class ReservationsTable extends StatelessWidget {
  final List<ReservationModel> reservations;
  final ValueChanged<ReservationModel>? onView;
  final ValueChanged<ReservationModel>? onEdit;
  final ValueChanged<ReservationModel>? onDelete;
  final ValueChanged<ReservationModel>? onPrint;
  final ValueChanged<ReservationModel>? onAddPayment;
  final ValueChanged<ReservationModel>? onEditGuests;
  final ValueChanged<ReservationModel>? onExpenses;
  // Hall name of a reservation; null when the account has a single hall
  final String Function(ReservationModel)? hallName;

  const ReservationsTable({
    super.key,
    required this.reservations,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onPrint,
    this.onAddPayment,
    this.onEditGuests,
    this.onExpenses,
    this.hallName,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScroll = ScrollController();
    final horizontalScroll = ScrollController();
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return LayoutBuilder(
      builder: (context, box) {
        // Fill the card; scroll horizontally only when narrower than 1000px
        final tableWidth = math.max(box.maxWidth - 48, 1000.0);
        return Container(
          height: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: horizontalScroll,
                  thumbVisibility: true,
                  thickness: 8,
                  radius: const Radius.circular(8),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.touch,
                        PointerDeviceKind.stylus,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: SingleChildScrollView(
                      controller: horizontalScroll,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: Scrollbar(
                          controller: verticalScroll,
                          notificationPredicate: (notif) => notif.depth == 1,
                          child: SingleChildScrollView(
                            controller: verticalScroll,
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                _buildTableHeader(context),
                                const SizedBox(height: 8),
                                Divider(color: colors.borderColor, height: 1),
                                if (reservations.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 64,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'no_reservations_found'.tr,
                                        style: TextStyle(
                                          color: colors.subtitleColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...List.generate(
                                    reservations.length,
                                    (index) => _buildTableRow(
                                      context,
                                      reservations[index],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildPagination(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final style = TextStyle(
      fontSize: 14,
      color: colors.subtitleColor,
      fontWeight: FontWeight.bold,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        textDirection: TextDirection.rtl,
        spacing: 12,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'reservation_number'.tr,
              textAlign: TextAlign.right,
              maxLines: 2,
              style: style,
            ),
          ),

          Expanded(
            flex: 5,
            child: Text(
              'customer_name'.tr,
              textAlign: TextAlign.right,
              maxLines: 2,
              style: style,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'phone_number'.tr,
              textAlign: TextAlign.right,
              maxLines: 2,
              style: style,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'reservation_date'.tr,
              textAlign: TextAlign.right,
              maxLines: 2,
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'added_by'.tr,
              textAlign: TextAlign.right,
              maxLines: 2,
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                'status'.tr,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'actions'.tr,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, ReservationModel item) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textColor = theme.colorScheme.onSurface;

    final myServices = Get.find<Myservices>();
    final supervisorName =
        myServices.sharedPreferences?.getString("username") ?? '';
    final addedBy = (item.addedByName != null && item.addedByName!.isNotEmpty)
        ? item.addedByName!
        : supervisorName;

    final Color statusColor;
    switch (item.statusKey) {
      case 'fully_paid':
        statusColor = Colors.green;
        break;
      case 'partially_paid':
        statusColor = Colors.orange;
        break;
      default: // unpaid
        statusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        textDirection: TextDirection.rtl,
        spacing: 12,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "#${item.numperReservation}",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColor.primaryPurple.withOpacity(0.1),
                  child: Text(
                    item.avatarInitials,
                    style: const TextStyle(
                      color: AppColor.primaryPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.customerName,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.customerType ?? 'client'.tr,
                        style: TextStyle(
                          color: colors.subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: Text(
              item.phoneNumber,
              maxLines: 2,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.bookingDate,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildHallLine(item),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              addedBy,
              style: TextStyle(
                color: colors.subtitleColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.statusKey.tr,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: ReservationActionsMenu(
                reservation: item,
                onView: onView,
                onExpenses: onExpenses,
                onAddPayment: onAddPayment,
                onEditGuests: onEditGuests,
                onPrint: onPrint,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Small "hall" line shown under the date when there are several halls
  Widget _buildHallLine(ReservationModel item) {
    if (hallName == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.meeting_room_outlined,
            size: 14,
            color: AppColor.primaryPurple,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              hallName!(item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColor.primaryPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.rtl,
      children: [
        Text(
          "${'show'.tr} 1-${reservations.length} ${'of'.tr} ${reservations.length} ${'booking'.tr}",
          style: TextStyle(color: colors.subtitleColor, fontSize: 14),
        ),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            _buildPageItem(context, '<', false),
            _buildPageItem(context, '1', true),
            _buildPageItem(context, '>', false),
          ],
        ),
      ],
    );
  }

  Widget _buildPageItem(BuildContext context, String label, bool active) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColor.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active ? null : Border.all(color: colors.borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
