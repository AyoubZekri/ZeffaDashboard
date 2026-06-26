import 'dart:io';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/class/Crud.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import '../../../core/services/Services.dart';
import 'package:path_provider/path_provider.dart';

class Dishcategories {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  Dishcategories(this.myServices);

  viewdata() async {
    try {
      if (id == null) {
        print("❌ user_id not found in local storage");
        return [];
      }

      final result = await _db.readData(
        "SELECT * FROM cat_dishes WHERE user_id = ? ORDER BY created_at ASC",
        [id],
      );

      return result;
    } catch (e) {
      print("❌ viewdata error: $e");
      return [];
    }
  }

  Future<bool> Adddata(String name, [File? file]) async {
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
        "user_id": id,
        "name": name,
        "image": savedImagePath,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("cat_dishes", data);

      if (result > 0) {
        print("✅ data added successfully ===== $result ");
        await _syncService.addToQueue("cat_dishes", uuid, "insert", data);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Adddata error: $e");
      return false;
    }
  }

  Future<bool> Updatecat(String uuid, String name, [File? file]) async {
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
        "updated_at": DateTime.now().toIso8601String(),
        if (savedImagePath != null) "image": savedImagePath,
      };

      final result = await _db.update("cat_dishes", data, "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("cat_dishes", uuid, "update", {
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
        final check = await _db.readData(
          "SELECT COUNT(*) as count FROM dishes WHERE cat_uuid = ?",
          [uuid],
        );
        if (check.isNotEmpty && (check[0]['count'] as int? ?? 0) > 0) {
          throw 'linked_to_dishes';
        }

        final result = await _db.delete("cat_dishes", "uuid = ?", [uuid]);

        if (result > 0) {
          await _syncService.addToQueue("cat_dishes", uuid, "delete", {
            "uuid": uuid,
            "updated_at": DateTime.now().toIso8601String(),
          });
          return true;
        }
        return false;
      } catch (e) {
        if (e == 'linked_to_dishes') rethrow;
        print("Errer delete_data $e");
        return false;
      }
    } catch (e, st) {
      if (e == 'linked_to_dishes') rethrow;
      print("❌ deletecat error: $e");
      print(st);
      return false;
    }
  }
}
