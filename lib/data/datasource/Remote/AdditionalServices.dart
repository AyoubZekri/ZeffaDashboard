import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import '../../../core/services/Services.dart';

class AdditionalServices {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();
  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  AdditionalServices(this.myServices);

  Future<List<Map<String, dynamic>>> viewdata() async {
    try {
      final result = await _db.readData(
        "SELECT * FROM additional_services WHERE user_id = ? ORDER BY created_at ASC",
        [id],
      );
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print("❌ viewdata error (additional_services): $e");
      return [];
    }
  }

  Future<bool> Adddata(String name, double price) async {
    final String uuid = const Uuid().v4();
    try {
      final data = {
        "uuid": uuid,
        "name": name,
        "price": price,
        "user_id": id,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("additional_services", data);
      if (result > 0) {
        await _syncService.addToQueue(
          "additional_services",
          uuid,
          "insert",
          data,
        );
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Adddata error: $e");
      return false;
    }
  }

  Future<bool> UpdateData(String uuid, String name, double price) async {
    try {
      final data = {
        "name": name,
        "price": price,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.update("additional_services", data, "uuid = ?", [
        uuid,
      ]);
      if (result > 0) {
        await _syncService.addToQueue("additional_services", uuid, "update", {
          "uuid": uuid,
          ...data,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ UpdateData error: $e");
      return false;
    }
  }

  Future<bool> deletedata(String uuid) async {
    try {
      final check = await _db.readData(
        "SELECT COUNT(*) as count FROM reservation_services WHERE service_uuid = ?",
        [uuid],
      );
      if (check.isNotEmpty && (check[0]['count'] as int? ?? 0) > 0) {
        throw 'linked_to_reservation';
      }

      final result = await _db.delete("additional_services", "uuid = ?", [
        uuid,
      ]);
      if (result > 0) {
        await _syncService.addToQueue("additional_services", uuid, "delete", {
          "uuid": uuid,
          "updated_at": DateTime.now().toIso8601String(),
        });
        // We should also delete linking records in reservation_services
        await _db.delete("reservation_services", "service_uuid = ?", [uuid]);

        return true;
      }
      return false;
    } catch (e) {
      if (e == 'linked_to_reservation') rethrow;
      print("❌ deletedata error: $e");
      return false;
    }
  }
}
