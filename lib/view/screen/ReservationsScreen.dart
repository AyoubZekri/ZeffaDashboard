import 'package:zeffa/core/functions/role_permissions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zeffa/core/functions/dialogDelete.dart';
import '../../controller/Reservationscontroller.dart';
import '../widget/reservations/ReservationsHeader.dart';
import '../widget/reservations/ReservationsTable.dart';
import '../widget/halls/HallChips.dart';
import '../widget/reservations/ReservationFormDialog.dart';
import '../widget/reservations/ReservationDetailsDialog.dart';
import '../widget/reservations/AddPaymentDialog.dart';
import '../widget/reservations/EditGuestsDialog.dart';
import '../widget/reservations/ReservationExpensesDialog.dart';
import '../widget/reservations/ReservationDateFilterDialog.dart';
import '../../core/functions/print_reservation.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final controllerRe = Get.put(Reservationscontroller());

  @override
  Widget build(BuildContext context) {
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
              onAddReservation: !hasRolePermission('add_reservation')
                  ? null
                  : () {
                      controllerRe.cleardata();
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
              isFilterActive:
                  controllerRe.startDateFilter.value != null ||
                  controllerRe.endDateFilter.value != null,
              onClearFilter: () {
                controllerRe.clearDateFilter();
              },
            ),

            const SizedBox(height: 24),

            // Hall filter (only when the account has several halls)
            if (controllerRe.hasMultipleHalls) ...[
              SizedBox(
                width: double.infinity,
                child: HallChips(
                  halls: controllerRe.dbHalls,
                  selectedKey: controllerRe.hallFilter.value,
                  onSelected: (key) => controllerRe.hallFilter.value = key,
                  showAll: true,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Data Table Section
            Expanded(
              child: ReservationsTable(
                reservations: filteredReservations,
                hallName: controllerRe.hasMultipleHalls
                    ? controllerRe.hallNameOf
                    : null,
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
                    ReservationFormDialog(
                      isEdit: true,
                      reservationUuid: reservation.uuid,
                    ),
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
                  showPrintSelectionDialog(context, reservation);
                },
                onAddPayment: (reservation) {
                  Get.dialog(
                    AddPaymentDialog(reservation: reservation),
                    barrierDismissible: true,
                  );
                },
                onExpenses: (reservation) {
                  Get.dialog(
                    ReservationExpensesDialog(reservation: reservation),
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
