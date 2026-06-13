import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';

class ReservationsData {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();
  int? id = 1;

  Future<List<Map<String, dynamic>>> viewdata() async {
    try {
      if (id == null) return [];

      // Main query: JOIN with party_type + GROUP_CONCAT for dishes
      final result = await _db.readData('''
        SELECT 
          r.*,
          pt.name AS party_type_name,
          pt.basic_price AS party_basic_price,
          pt.seasonal_price AS party_seasonal_price,
          pt.icon AS party_icon,
          GROUP_CONCAT(d.name, ', ') AS dishes_names,
          GROUP_CONCAT(rd.dishes_uuid, ',') AS dishes_uuids
        FROM reservations r
        LEFT JOIN party_type pt ON r.type_of_party_uuid = pt.uuid
        LEFT JOIN reservation_dishes rd ON r.uuid = rd.reservation_uuid
        LEFT JOIN dishes d ON rd.dishes_uuid = d.uuid
        WHERE r.user_id = ?
        GROUP BY r.uuid
        ORDER BY r.created_at DESC
      ''', [id]);

      return result;
    } catch (e) {
      print("❌ viewdata error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> viewReservationDishes(String reservationUuid) async {
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

  Future<bool> Adddata(Map<String, dynamic> rawData, List<String> dishesUuids) async {
    final String uuid = Uuid().v4();
    try {
      final data = {
        "uuid": uuid,
        "user_id": id,
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
          await _syncService.addToQueue("reservation_dishes", rdUuid, "insert", rdData);
        }
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Adddata error: $e");
      return false;
    }
  }

  Future<bool> Updatedata(String uuid, Map<String, dynamic> rawData, List<String> dishesUuids) async {
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
        await _syncService.addToQueue("reservations", uuid, "update", {"uuid": uuid, ...data});

        // Delete old dishes and add new ones
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
          await _syncService.addToQueue("reservation_dishes", rdUuid, "insert", rdData);
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
      await _db.delete("reservation_dishes", "reservation_uuid = ?", [uuid]);
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
  Future<bool> updatePartialFields(String uuid, Map<String, dynamic> fields) async {
    try {
      fields["updated_at"] = DateTime.now().toIso8601String();
      final result = await _db.update("reservations", fields, "uuid = ?", [uuid]);
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
