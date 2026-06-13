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

    // Filter reservations dynamically based on the search query
    return Obx(() {
      final query = controllerRe.searchQuery.value.trim().toLowerCase();
      final filteredReservations = controllerRe.allReservations.where((res) {
        if (query.isEmpty) return true;
        return res.customerName.toLowerCase().contains(query) ||
            res.phoneNumber.contains(query) ||
            res.id.toString().contains(query);
      }).toList();

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
                // Implement filter logic
              },
              onExport: () {
                // Implement export logic
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
                    title: "هل تريد الحذف",
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
