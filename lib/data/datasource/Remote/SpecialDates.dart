import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/services/Services.dart';

class SpecialDates {
  final SQLDB sqldb = SQLDB();

  Myservices myServices;

  SpecialDates(this.myServices);

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  Future<List<Map<String, dynamic>>> viewdata() async {
    try {
      final List<Map<String, dynamic>> response = await sqldb.readData(
        '''
        SELECT 
          sd.*,
          r.username AS customer_name,
          r.phone_numper AS customer_phone,
          r.id AS booking_id,
          pt.name AS event_type
        FROM special_dates sd
        LEFT JOIN reservations r ON sd.reservation_uuid = r.uuid
        LEFT JOIN party_type pt ON r.type_of_party_uuid = pt.uuid
        WHERE sd.user_id = ? 
        ORDER BY sd.id DESC
        ''',
        [id],
      );
      return response;
    } catch (e) {
      print("❌ viewdata error: $e");
      return [];
    }
  }

  // Add Special Day (Single date)
  Future<bool> AddSpecialDay(String title, String type, String date) async {
    final String uuid = Uuid().v4();

    try {
      final data = {
        "uuid": uuid,
        "user_id": id,
        "title": title,
        "type": type,
        "date": date,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      int result = await sqldb.insert("special_dates", data);
      return result > 0;
    } catch (e) {
      print("❌ AddSpecialDay Error: $e");
      return false;
    }
  }

  // Add Special Period (Start - End)
  Future<bool> AddSpecialPeriod(
    String title,
    String type,
    String startDate,
    String endDate,
  ) async {
    final String uuid = Uuid().v4();

    try {
      final data = {
        "uuid": uuid,
        "user_id": id,
        "title": title,
        "type": type,
        "start_date": startDate,
        "end_date": endDate,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };

      int result = await sqldb.insert("special_dates", data);
      return result > 0;
    } catch (e) {
      print("❌ AddSpecialPeriod Error: $e");
      return false;
    }
  }

  // Update Special Date (Common for both)
  Future<bool> Updatedata(
    String uuid,
    String title,
    String type, {
    String? startDate,
    String? endDate,
    String? date,
  }) async {
    try {
      final data = {
        "title": title,
        "type": type,
        "updated_at": DateTime.now().toIso8601String(),
      };

      if (date != null) data["date"] = date;
      if (startDate != null) data["start_date"] = startDate;
      if (endDate != null) data["end_date"] = endDate;

      int result = await sqldb.update("special_dates", data, "uuid = ?", [
        uuid,
      ]);
      return result > 0;
    } catch (e) {
      print("❌ Updatedata Error: $e");
      return false;
    }
  }

  Future<bool> Deletedata(String uuid) async {
    try {
      int result = await sqldb.delete("special_dates", "uuid = ?", [uuid]);
      return result > 0;
    } catch (e) {
      print("❌ Deletedata Error: $e");
      return false;
    }
  }

  Future<int> getReservationsCountForMonth(int year, int month) async {
    try {
      final String monthStr = month.toString().padLeft(2, '0');
      final String yearStr = year.toString();
      final List<Map<String, dynamic>> response = await sqldb.readData(
        '''
        SELECT COUNT(*) as count 
        FROM reservations 
        WHERE user_id = ? 
          AND booking_date LIKE ?
        ''',
        [id, '$yearStr-$monthStr-%'],
      );
      
      if (response.isNotEmpty) {
        final countRaw = response.first['count'];
        return countRaw != null ? int.tryParse(countRaw.toString()) ?? 0 : 0;
      }
      return 0;
    } catch (e) {
      print("❌ getReservationsCountForMonth error: $e");
      return 0;
    }
  }
}

