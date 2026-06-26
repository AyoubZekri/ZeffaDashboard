import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import '../../../core/services/Services.dart';

class ReservationsData {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();
  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  ReservationsData(this.myServices);
  Future<List<Map<String, dynamic>>> viewdata() async {
    try {
      // Main query: JOIN with party_types + GROUP_CONCAT for dishes
      final result = await _db.readData(
        '''
        SELECT 
          r.*,
          GROUP_CONCAT(DISTINCT d.name) AS dishes_names,
          GROUP_CONCAT(DISTINCT rd.dishes_uuid) AS dishes_uuids,
          GROUP_CONCAT(DISTINCT s.name) AS services_names,
          GROUP_CONCAT(DISTINCT rs.service_uuid) AS services_uuids,
          pt.name AS party_type_name,
          pt.basic_price,
          pt.seasonal_price,
          pt.icon AS party_icon
        FROM reservations r
        LEFT JOIN party_types pt ON r.type_of_party_uuid = pt.uuid
        LEFT JOIN reservation_dishes rd ON r.uuid = rd.reservation_uuid
        LEFT JOIN dishes d ON rd.dishes_uuid = d.uuid
        LEFT JOIN reservation_services rs ON r.uuid = rs.reservation_uuid
        LEFT JOIN additional_services s ON rs.service_uuid = s.uuid
        WHERE r.user_id = ?
        GROUP BY r.uuid
        ORDER BY r.created_at DESC
      ''',
        [id],
      );

      return result;
    } catch (e) {
      print("❌ viewdata error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> viewReservationDishes(
    String reservationUuid,
  ) async {
    try {
      final result = await _db.readData(
        "SELECT * FROM reservation_dishes WHERE reservation_uuid = ?",
        [reservationUuid],
      );
      return result;
    } catch (e) {
      print("❌ viewReservationDishes error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> viewReservationServices(
    String reservationUuid,
  ) async {
    try {
      final result = await _db.readData(
        "SELECT * FROM reservation_services WHERE reservation_uuid = ?",
        [reservationUuid],
      );
      return result;
    } catch (e) {
      print("❌ viewReservationServices error: $e");
      return [];
    }
  }

  Future<bool> Adddata(
    Map<String, dynamic> rawData,
    List<String> dishesUuids,
    List<String> servicesUuids,
  ) async {
    final String uuid = Uuid().v4();
    try {
      final data = {
        "uuid": uuid,
        "user_id": id,
        "numperReservation": rawData["numperReservation"],
        "username": rawData["username"],
        "phone_numper": rawData["phone_numper"],
        "booking_date": rawData["booking_date"],
        "booking_period": rawData["booking_period"],
        "type_of_party_uuid": rawData["type_of_party_uuid"],
        "price": rawData["price"],
        "notes": rawData["notes"],
        "deposit": rawData["deposit"],
        "remaining_amount": rawData["remaining_amount"],
        "number_of_men": rawData["number_of_men"],
        "number_of_women": rawData["number_of_women"],
        "added_by_name": rawData["added_by_name"],
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("reservations", data);
      if (result > 0) {
        await _syncService.addToQueue("reservations", uuid, "insert", data);

        for (String dishUuid in dishesUuids) {
          final rdUuid = Uuid().v4();
          final rdData = {
            "uuid": rdUuid,
            "reservation_uuid": uuid,
            "dishes_uuid": dishUuid,
            "created_at": DateTime.now().toIso8601String(),
            "updated_at": DateTime.now().toIso8601String(),
          };
          await _db.insert("reservation_dishes", rdData);
          await _syncService.addToQueue(
            "reservation_dishes",
            rdUuid,
            "insert",
            rdData,
          );
        }

        for (String serviceUuid in servicesUuids) {
          final rsUuid = Uuid().v4();
          final rsData = {
            "uuid": rsUuid,
            "reservation_uuid": uuid,
            "service_uuid": serviceUuid,
            "user_id": id,
            "created_at": DateTime.now().toIso8601String(),
            "updated_at": DateTime.now().toIso8601String(),
          };
          await _db.insert("reservation_services", rsData);
          await _syncService.addToQueue(
            "reservation_services",
            rsUuid,
            "insert",
            rsData,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Adddata error: $e");
      return false;
    }
  }

  Future<bool> Updatedata(
    String uuid,
    Map<String, dynamic> rawData,
    List<String> dishesUuids,
    List<String> servicesUuids,
  ) async {
    try {
      final data = {
        "username": rawData["username"],
        "phone_numper": rawData["phone_numper"],
        "booking_date": rawData["booking_date"],
        "booking_period": rawData["booking_period"],
        "type_of_party_uuid": rawData["type_of_party_uuid"],
        "price": rawData["price"],
        "notes": rawData["notes"],
        "deposit": rawData["deposit"],
        "remaining_amount": rawData["remaining_amount"],
        "number_of_men": rawData["number_of_men"],
        "number_of_women": rawData["number_of_women"],
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.update("reservations", data, "uuid = ?", [uuid]);
      if (result > 0) {
        await _syncService.addToQueue("reservations", uuid, "update", {
          "uuid": uuid,
          ...data,
        });

        // Delete old dishes and add new ones
        final oldDishes = await _db.readData("SELECT uuid FROM reservation_dishes WHERE reservation_uuid = ?", [uuid]);
        for(var row in oldDishes) {
          await _syncService.addToQueue("reservation_dishes", row['uuid'].toString(), "delete", {
            "uuid": row['uuid'],
            "updated_at": DateTime.now().toIso8601String(),
          });
        }
        await _db.delete("reservation_dishes", "reservation_uuid = ?", [uuid]);

        for (String dishUuid in dishesUuids) {
          final rdUuid = Uuid().v4();
          final rdData = {
            "uuid": rdUuid,
            "reservation_uuid": uuid,
            "dishes_uuid": dishUuid,
            "created_at": DateTime.now().toIso8601String(),
            "updated_at": DateTime.now().toIso8601String(),
          };
          await _db.insert("reservation_dishes", rdData);
          await _syncService.addToQueue(
            "reservation_dishes",
            rdUuid,
            "insert",
            rdData,
          );
        }

        // Delete old services and add new ones
        final oldServices = await _db.readData("SELECT uuid FROM reservation_services WHERE reservation_uuid = ?", [uuid]);
        for(var row in oldServices) {
          await _syncService.addToQueue("reservation_services", row['uuid'].toString(), "delete", {
            "uuid": row['uuid'],
            "updated_at": DateTime.now().toIso8601String(),
          });
        }
        await _db.delete("reservation_services", "reservation_uuid = ?", [uuid]);

        for (String serviceUuid in servicesUuids) {
          final rsUuid = Uuid().v4();
          final rsData = {
            "uuid": rsUuid,
            "reservation_uuid": uuid,
            "service_uuid": serviceUuid,
            "user_id": id,
            "created_at": DateTime.now().toIso8601String(),
            "updated_at": DateTime.now().toIso8601String(),
          };
          await _db.insert("reservation_services", rsData);
          await _syncService.addToQueue(
            "reservation_services",
            rsUuid,
            "insert",
            rsData,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Updatedata error: $e");
      return false;
    }
  }

  Future<bool> Deletedata(String uuid) async {
    try {
      final oldDishes = await _db.readData("SELECT uuid FROM reservation_dishes WHERE reservation_uuid = ?", [uuid]);
      for(var row in oldDishes) {
        await _syncService.addToQueue("reservation_dishes", row['uuid'].toString(), "delete", {
          "uuid": row['uuid'],
          "updated_at": DateTime.now().toIso8601String(),
        });
      }
      await _db.delete("reservation_dishes", "reservation_uuid = ?", [uuid]);

      final oldServices = await _db.readData("SELECT uuid FROM reservation_services WHERE reservation_uuid = ?", [uuid]);
      for(var row in oldServices) {
        await _syncService.addToQueue("reservation_services", row['uuid'].toString(), "delete", {
          "uuid": row['uuid'],
          "updated_at": DateTime.now().toIso8601String(),
        });
      }
      await _db.delete("reservation_services", "reservation_uuid = ?", [uuid]);
      final result = await _db.delete("reservations", "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("reservations", uuid, "delete", {
          "uuid": uuid,
          "updated_at": DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Deletedata error: $e");
      return false;
    }
  }

  /// Update specific fields on a reservation (e.g. deposit, guest count)
  Future<bool> updatePartialFields(
    String uuid,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields["updated_at"] = DateTime.now().toIso8601String();
      final result = await _db.update("reservations", fields, "uuid = ?", [
        uuid,
      ]);
      if (result > 0) {
        await _syncService.addToQueue("reservations", uuid, "update", {
          "uuid": uuid,
          ...fields,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ updatePartialFields error: $e");
      return false;
    }
  }
}
