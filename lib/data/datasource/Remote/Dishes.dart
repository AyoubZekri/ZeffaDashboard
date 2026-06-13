import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../../core/class/Crud.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/services/Services.dart';

class Dishes {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  Dishes(this.myServices);

  viewdata() async {
    try {
      if (id == null) {
        print("❌ user_id not found in local storage");
        return [];
      }

      final result = await _db.readData(
        "SELECT * FROM dishes WHERE user_id = ? ORDER BY created_at ASC",
        [id],
      );

      return result;
    } catch (e) {
      print("❌ viewdata error: $e");
      return [];
    }
  }

  Future<bool> Adddata(String name, String catUuid, [File? file]) async {
    String? savedImagePath;
    final String uuid = Uuid().v4();

    try {
      if (file != null) {
        final dir = await getApplicationDocumentsDirectory();
        final imagePath =
            "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png";
        await file.copy(imagePath);
        savedImagePath = imagePath;
      }

      final data = {
        "uuid": uuid,
        "cat_uuid": catUuid,
        "name": name,
        "user_id": id,
        "image": savedImagePath,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("dishes", data);
      print("============Adddata===== $result =============");
      if (result > 0) {
        await _syncService.addToQueue("dishes", uuid, "insert", data);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Adddata error: $e");
      return false;
    }
  }

  Future<bool> Updatecat(
    String uuid,
    String name,
    String catUuid, [
    File? file,
  ]) async {
    try {
      String? savedImagePath;

      if (file != null) {
        final dir = await getApplicationDocumentsDirectory();
        final imagePath =
            "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png";
        await file.copy(imagePath);
        savedImagePath = imagePath;
      }

      final data = {
        "name": name,
        "cat_uuid": catUuid,
        "updated_at": DateTime.now().toIso8601String(),
        if (savedImagePath != null) "image": savedImagePath,
      };

      final result = await _db.update("dishes", data, "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("dishes", uuid, "update", {
          "uuid": uuid,
          ...data,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Updatecat error: $e");
      return false;
    }
  }

  Future<bool> deletecat(String uuid) async {
    try {
      try {
        final result = await _db.delete("dishes", "uuid = ?", [uuid]);

        if (result > 0) {
          await _syncService.addToQueue("dishes", uuid, "delete", {
            "uuid": uuid,
            "updated_at": DateTime.now().toIso8601String(),
          });
          return true;
        }
        return false;
      } catch (e) {
        print("Errer delete_data $e");
        return false;
      }
    } catch (e, st) {
      print("❌ deletecat error: $e");
      print(st);
      return false;
    }
  }
}
