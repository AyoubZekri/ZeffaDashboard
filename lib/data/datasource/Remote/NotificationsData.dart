import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import '../../../core/services/Services.dart';

class NotificationsData {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();
  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  NotificationsData(this.myServices);
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final result = await _db.readData(
        "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC",
        [id],
      );
      return result;
    } catch (e) {
      print("❌ getNotifications error: $e");
      return [];
    }
  }

  Future<bool> markAsRead(String uuid) async {
    try {
      final now = DateTime.now().toIso8601String();
      final result = await _db.update(
        "notifications",
        {"is_read": 1, "updated_at": now},
        "uuid = ?",
        [uuid],
      );
      if (result > 0) {
        await _syncService.addToQueue("notifications", uuid, "update", {
          "uuid": uuid,
          "is_read": 1,
          "updated_at": now,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ markAsRead error: $e");
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final now = DateTime.now().toIso8601String();
      final result = await _db.update(
        "notifications",
        {"is_read": 1, "updated_at": now},
        "user_id = ? AND is_read = 0",
        [id],
      );
      // We would ideally sync these individually, but for now just local update is fine.
      return result > 0;
    } catch (e) {
      print("❌ markAllAsRead error: $e");
      return false;
    }
  }

  Future<bool> deleteNotification(String uuid) async {
    try {
      final result = await _db.delete("notifications", "uuid = ?", [uuid]);
      if (result > 0) {
        await _syncService.addToQueue("notifications", uuid, "delete", {
          "uuid": uuid,
          "updated_at": DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ deleteNotification error: $e");
      return false;
    }
  }

  Future<bool> deleteAllNotifications() async {
    try {
      final result = await _db.delete("notifications", "user_id = ?", [id]);
      return result > 0;
    } catch (e) {
      print("❌ deleteAllNotifications error: $e");
      return false;
    }
  }

  Future<bool> addNotification(
    String title,
    String content,
    String type,
  ) async {
    try {
      final uuid = const Uuid().v4();
      final now = DateTime.now().toIso8601String();

      Map<String, dynamic> data = {
        "uuid": uuid,
        "user_id": id,
        "title": title,
        "content": content,
        "is_read": 0,
        "type": type,
        "created_at": now,
        "updated_at": now,
      };

      final result = await _db.insert("notifications", data);
      if (result > 0) {
        await _syncService.addToQueue("notifications", uuid, "insert", data);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ addNotification error: $e");
      return false;
    }
  }
}
