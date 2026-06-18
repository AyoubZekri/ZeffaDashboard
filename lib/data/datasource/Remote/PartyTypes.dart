import 'package:uuid/uuid.dart';
import '../../../core/class/Crud.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';

import '../../../core/services/Services.dart';

class PartyTypes {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  PartyTypes(this.myServices);

  Future<List<Map<String, dynamic>>> viewdata() async {
    try {


      final result = await _db.readData(
        "SELECT * FROM party_types WHERE user_id = ? ORDER BY created_at DESC",
        [id],
      );

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print("❌ viewdata error: $e");
      return [];
    }
  }

  Future<bool> Adddata(
    String name,
    String content,
    double basicPrice,
    double seasonalPrice,
    String icon,
  ) async {
    final String uuid = Uuid().v4();

    try {
      final data = {
        "uuid": uuid,
        "user_id": id,
        "name": name,
        "content": content,
        "basic_price": basicPrice,
        "seasonal_price": seasonalPrice,
        "icon": icon,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("party_types", data);
      print("============Adddata PartyType===== $result =============");
      if (result > 0) {
        await _syncService.addToQueue("party_types", uuid, "insert", data);
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
    String name,
    String content,
    double basicPrice,
    double seasonalPrice,
    String icon,
  ) async {
    try {
      final data = {
        "name": name,
        "content": content,
        "basic_price": basicPrice,
        "seasonal_price": seasonalPrice,
        "icon": icon,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.update("party_types", data, "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("party_types", uuid, "update", {
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
      final result = await _db.delete("party_types", "uuid = ?", [uuid]);

      if (result > 0) {
        await _syncService.addToQueue("party_types", uuid, "delete", {
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
