import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';
import '../../../core/services/Services.dart';

class Terms {
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  Myservices myServices;

  int get id => myServices.sharedPreferences?.getInt("id") ?? 1;

  Terms(this.myServices);

  Future<List<Map<String, dynamic>>> viewdata() async {
    try {
      final result = await _db.readData(
        '''
        SELECT t.*, tc.content
        FROM terms t 
        LEFT JOIN terms_content tc ON t.uuid = tc.term_uuid 
        WHERE t.user_id = ? 
        ORDER BY t.created_at DESC
        ''',
        [id],
      );

      // Group by Term uuid to collect all content items
      final Map<String, Map<String, dynamic>> termsMap = {};
      for (final row in result) {
        final termUuid = row["uuid"] as String;
        if (!termsMap.containsKey(termUuid)) {
          termsMap[termUuid] = {
            "id": row["id"],
            "uuid": termUuid,
            "user_id": row["user_id"],
            "title": row["title"],
            "type": row["type"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
            "contents": <String>[],
          };
        }
        final content = row["content"];
        if (content != null && (content as String).isNotEmpty) {
          (termsMap[termUuid]!["contents"] as List<String>).add(content);
        }
      }

      return termsMap.values.toList();
    } catch (e) {
      print("❌ viewdata error for Terms: $e");
      return [];
    }
  }

  Future<bool> Adddata(String title, String type, List<String> contents) async {
    final String termUuid = Uuid().v4();
    final String nowStr = DateTime.now().toIso8601String();

    try {
      final termData = {
        "uuid": termUuid,
        "user_id": id,
        "title": title,
        "type": type,
        "created_at": nowStr,
        "updated_at": nowStr,
      };

      // 1. Insert into Terms
      final resultTerm = await _db.insert("terms", termData);
      if (resultTerm <= 0) return false;

      // Add to Sync queue for terms
      await _syncService.addToQueue("terms", termUuid, "insert", termData);

      // 2. Insert into terms_content for each item
      for (final content in contents) {
        if (content.trim().isEmpty) continue;
        final contentData = {
          "term_uuid": termUuid,
          "user_id": id,
          "content": content,
          "created_at": nowStr,
          "updated_at": nowStr,
        };
        final resultContent = await _db.insert("terms_content", contentData);
        if (resultContent > 0) {
          // Use termUuid as row_id for sync, just like in original code
          await _syncService.addToQueue("terms_content", termUuid, "insert", contentData);
        }
      }

      return true;
    } catch (e) {
      print("❌ Adddata error for terms: $e");
      return false;
    }
  }

  Future<bool> Updatedata(String uuid, String title, String type, List<String> contents) async {
    final String nowStr = DateTime.now().toIso8601String();

    try {
      final termData = {
        "title": title,
        "type": type,
        "updated_at": nowStr,
      };

      // 1. Update terms
      final resultTerm = await _db.update("terms", termData, "uuid = ?", [uuid]);

      // 2. Delete existing local contents for this term
      await _db.delete("terms_content", "term_uuid = ?", [uuid]);

      // Add a delete to sync queue using uuid (term_uuid)
      await _syncService.addToQueue("terms_content", uuid, "delete", {
        "term_uuid": uuid,
        "updated_at": nowStr,
      });

      // 3. Insert new contents
      for (final content in contents) {
        if (content.trim().isEmpty) continue;
        final contentData = {
          "term_uuid": uuid,
          "user_id": id,
          "content": content,
          "created_at": nowStr,
          "updated_at": nowStr,
        };
        final insertResult = await _db.insert("terms_content", contentData);
        if (insertResult > 0) {
          await _syncService.addToQueue("terms_content", uuid, "insert", contentData);
        }
      }

      if (resultTerm > 0) {
        await _syncService.addToQueue("terms", uuid, "update", {
          "uuid": uuid,
          ...termData,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Updatedata error for terms: $e");
      return false;
    }
  }

  Future<bool> Deletedata(String uuid) async {
    try {
      // Delete from terms
      final resultTerm = await _db.delete("terms", "uuid = ?", [uuid]);

      // Delete from terms_content
      await _db.delete("terms_content", "term_uuid = ?", [uuid]);
      await _syncService.addToQueue("terms_content", uuid, "delete", {
        "term_uuid": uuid,
        "updated_at": DateTime.now().toIso8601String(),
      });

      if (resultTerm > 0) {
        await _syncService.addToQueue("terms", uuid, "delete", {
          "uuid": uuid,
          "updated_at": DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Deletedata error for terms: $e");
      return false;
    }
  }
}
