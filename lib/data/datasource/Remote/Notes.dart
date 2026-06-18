import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import '../../../core/services/Services.dart';

class Notes {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  Notes(this.myServices);

  Future<List<Map<String, dynamic>>> viewdata() async {
    try {
      final result = await _db.readData(
        "SELECT * FROM notes WHERE user_id = ? ORDER BY created_at DESC",
        [id],
      );

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print("❌ viewdata error: $e");
      return [];
    }
  }

  Future<bool> Adddata(String title, String description) async {
    final String uuid = Uuid().v4();

    try {
      final data = {
        "uuid": uuid,
        "user_id": id,
        "title": title,
        "description": description,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("notes", data);
      print("============Adddata Notes===== $result =============");
      if (result > 0) {
        await _syncService.addToQueue("notes", uuid, "insert", data);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Adddata error: $e");
      return false;
    }
  }

  Future<bool> Updatedata(String uuid, String title, String description) async {
    try {
      final data = {
        "title": title,
        "description": description,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.update("notes", data, "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("notes", uuid, "update", {
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
      final result = await _db.delete("notes", "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("notes", uuid, "delete", {
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
