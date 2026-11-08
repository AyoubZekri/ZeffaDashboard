import 'package:uuid/uuid.dart';
import '../../../core/class/Crud.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import '../../../core/services/Services.dart';

class Expenses {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  Expenses(this.myServices);

  Future<List<Map<String, dynamic>>> viewdata() async {
    try {
      final result = await _db.readData(
        "SELECT * FROM expenses WHERE user_id = ? ORDER BY date_perry DESC",
        [id],
      );

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print("❌ viewdata error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> viewByReservation(String reservationUuid) async {
    try {
      final result = await _db.readData(
        "SELECT * FROM expenses WHERE user_id = ? AND reservation_uuid = ? ORDER BY created_at",
        [id, reservationUuid],
      );
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print("❌ viewByReservation error: $e");
      return [];
    }
  }

  Future<bool> Adddata(
    int type,
    String description,
    double value,
    String datePerry, {
    String? reservationUuid,
    int? workersCount,
    int? femaleWorkersCount,
    double? workerPrice,
    double? femaleWorkerPrice,
  }) async {
    final String uuid = Uuid().v4();

    try {
      final data = {
        "uuid": uuid,
        "user_id": id,
        "reservation_uuid": reservationUuid,
        "workers_count": workersCount,
        "female_workers_count": femaleWorkersCount,
        "worker_price": workerPrice,
        "female_worker_price": femaleWorkerPrice,
        "type": type,
        "description": description,
        "value": value,
        "date_perry": datePerry,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("expenses", data);
      print("============Adddata Expenses===== $result =============");
      if (result > 0) {
        await _syncService.addToQueue("expenses", uuid, "insert", data);
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
    int type,
    String description,
    double value,
    String datePerry, {
    String? reservationUuid,
    int? workersCount,
    int? femaleWorkersCount,
    double? workerPrice,
    double? femaleWorkerPrice,
  }) async {
    try {
      final data = {
        "reservation_uuid": reservationUuid,
        "workers_count": workersCount,
        "female_workers_count": femaleWorkersCount,
        "worker_price": workerPrice,
        "female_worker_price": femaleWorkerPrice,
        "type": type,
        "description": description,
        "value": value,
        "date_perry": datePerry,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.update("expenses", data, "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("expenses", uuid, "update", {
          "uuid": uuid,
          ...data,
        });
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
      final result = await _db.delete("expenses", "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("expenses", uuid, "delete", {
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
}
