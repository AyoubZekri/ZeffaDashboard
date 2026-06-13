import 'package:uuid/uuid.dart';
import '../../../core/class/Crud.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';

class Expenses {
  final Crud crud;
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  int? id = 1; // user_id fallback to 1 as in Dishes.dart

  Expenses(this.crud);

  Future<List<Map<String, dynamic>>> viewdata() async {
    try {
      if (id == null) {
        print("❌ user_id not found");
        return [];
      }

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

  Future<bool> Adddata(int type, String description, double value, String datePerry) async {
    final String uuid = Uuid().v4();

    try {
      final data = {
        "uuid": uuid,
        "user_id": id,
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
    String datePerry,
  ) async {
    try {
      final data = {
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
