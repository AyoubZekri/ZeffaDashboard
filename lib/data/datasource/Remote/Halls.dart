import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import '../../../core/services/Services.dart';
import '../../model/HallModel.dart';

class Halls {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();
  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  Halls(this.myServices);

  /// The account's own hall (name and phones from the profile)
  HallModel get accountHall => HallModel(
    name: myServices.sharedPreferences?.getString("hallname") ?? "",
    phone1: myServices.sharedPreferences?.getString("numperPhone") ?? "",
    phone2: myServices.sharedPreferences?.getString("fieldPhone") ?? "",
    address: myServices.sharedPreferences?.getString("adresse") ?? "",
  );

  /// Extra halls added in the halls page
  Future<List<Map<String, dynamic>>> viewdata() async {
    try {
      final result = await _db.readData(
        "SELECT * FROM halls WHERE user_id = ? ORDER BY created_at ASC",
        [id],
      );
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print("❌ viewdata error (halls): $e");
      return [];
    }
  }

  /// Account hall first, then the extra halls.
  /// Only the account hall → the account works with a single hall.
  Future<List<HallModel>> allHalls() async {
    return [accountHall, ...HallModel.fromList(await viewdata())];
  }

  /// Hall used for printing: hall name, and its phones when they were
  /// added, otherwise the account phones.
  Future<HallModel> hallForPrint(String? hallUuid) async {
    final account = accountHall;
    if (hallUuid == null || hallUuid.isEmpty) return account;

    final result = await _db.readData(
      "SELECT * FROM halls WHERE uuid = ?",
      [hallUuid],
    );
    if (result.isEmpty) return account;
    final hall = HallModel.fromJson(Map<String, dynamic>.from(result.first));

    String pick(String? value, String? fallback) =>
        (value != null && value.trim().isNotEmpty) ? value : (fallback ?? "");

    return HallModel(
      uuid: hall.uuid,
      name: pick(hall.name, account.name),
      phone1: pick(hall.phone1, account.phone1),
      phone2: pick(hall.phone2, account.phone2),
      address: pick(hall.address, account.address),
    );
  }

  Future<bool> Adddata(
    String name,
    String phone1,
    String phone2,
    String address,
  ) async {
    final String uuid = const Uuid().v4();
    try {
      final data = {
        "uuid": uuid,
        "user_id": id,
        "name": name,
        "phone1": phone1,
        "phone2": phone2,
        "address": address,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.insert("halls", data);
      if (result > 0) {
        await _syncService.addToQueue("halls", uuid, "insert", data);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Adddata error (halls): $e");
      return false;
    }
  }

  Future<bool> Updatedata(
    String uuid,
    String name,
    String phone1,
    String phone2,
    String address,
  ) async {
    try {
      final data = {
        "name": name,
        "phone1": phone1,
        "phone2": phone2,
        "address": address,
        "updated_at": DateTime.now().toIso8601String(),
      };

      final result = await _db.update("halls", data, "uuid = ?", [uuid]);
      if (result > 0) {
        await _syncService.addToQueue("halls", uuid, "update", {
          "uuid": uuid,
          ...data,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Updatedata error (halls): $e");
      return false;
    }
  }

  /// Throws 'linked_to_reservation' when the hall still has reservations
  Future<bool> Deletedata(String uuid) async {
    try {
      final check = await _db.readData(
        "SELECT COUNT(*) as count FROM reservations WHERE hall_uuid = ?",
        [uuid],
      );
      if (check.isNotEmpty && (check[0]['count'] as int? ?? 0) > 0) {
        throw 'linked_to_reservation';
      }

      final result = await _db.delete("halls", "uuid = ?", [uuid]);
      if (result > 0) {
        await _syncService.addToQueue("halls", uuid, "delete", {
          "uuid": uuid,
          "updated_at": DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false;
    } catch (e) {
      if (e == 'linked_to_reservation') rethrow;
      print("❌ Deletedata error (halls): $e");
      return false;
    }
  }
}
