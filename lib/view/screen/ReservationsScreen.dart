import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/functions/dialogDelete.dart';
import '../../controller/Reservationscontroller.dart';
import '../../core/constant/Colorapp.dart';
import '../../core/constant/AppTheme.dart';
import '../../controller/SiedBarController.dart';
import '../../data/model/ReservationModel.dart';
import '../widget/reservations/ReservationsHeader.dart';
import '../widget/reservations/ReservationsTable.dart';
import '../widget/reservations/ReservationFormDialog.dart';
import '../widget/reservations/ReservationDetailsDialog.dart';
import '../widget/reservations/AddPaymentDialog.dart';
import '../widget/reservations/EditGuestsDialog.dart';
import '../widget/reservations/ReservationDateFilterDialog.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final controllerRe = Get.put(Reservationscontroller());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Obx(() {
      final filteredReservations = controllerRe.filteredReservations;

      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Header Section
            ReservationsHeader(
              searchController: controllerRe.searchController,
              onSearchChanged: (value) {
                controllerRe.searchQuery.value = value;
              },
              onAddReservation: () {
                controllerRe.fetchInitialData();
                Get.dialog(
                  const ReservationFormDialog(),
                  barrierDismissible: true,
                );
              },
              onFilter: () {
                Get.dialog(
                  const ReservationDateFilterDialog(),
                  barrierDismissible: true,
                );
              },
              onExport: () {
                controllerRe.exportToExcel();
              },
              isFilterActive: controllerRe.startDateFilter.value != null || controllerRe.endDateFilter.value != null,
              onClearFilter: () {
                controllerRe.clearDateFilter();
              },
            ),

            const SizedBox(height: 24),

            // Data Table Section
            Expanded(
              child: ReservationsTable(
                reservations: filteredReservations,
                onView: (reservation) {
                  Get.dialog(
                    ReservationDetailsDialog(reservation: reservation),
                    barrierDismissible: true,
                  );
                },
                onEdit: (reservation) {
                  controllerRe.fetchInitialData();
                  controllerRe.setEditData(reservation);
                  Get.dialog(
                    ReservationFormDialog(isEdit: true, reservationUuid: reservation.uuid),
                    barrierDismissible: true,
                  );
                },
                onDelete: (reservation) {
                  dialogDelete(
                    onConfirm: () {
                      controllerRe.deleteReservation(reservation.uuid);
                      Get.back();
                    },
                    title: 'do_you_want_to_delete'.tr,
                    content: "",
                  );
                },
                onPrint: (reservation) {
                  Get.snackbar(
                    'print_reservation'.tr,
                    "${'print_preparing_msg'.tr} ${reservation.customerName}",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.grey.shade800,
                    colorText: Colors.white,
                  );
                },
                onAddPayment: (reservation) {
                  Get.dialog(
                    AddPaymentDialog(reservation: reservation),
                    barrierDismissible: true,
                  );
                },
                onEditGuests: (reservation) {
                  Get.dialog(
                    EditGuestsDialog(reservation: reservation),
                    barrierDismissible: true,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
