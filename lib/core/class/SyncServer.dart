import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../LinkApi.dart';
import '../services/Services.dart';
import '../functions/CheckInternat.dart';
import 'sqldb.dart';

class SyncService {
  final SQLDB _db = SQLDB();
  final String baseUrl = "https://zeffa.codedev.id/api/sync";

  // ---------------------------------------------------------
  // QUEUE
  // ---------------------------------------------------------

  Future<void> addToQueue(
    String table,
    String uuid,
    String operation,
    Map<String, dynamic>? data,
  ) async {
    data?["uuid"] = uuid;
    data?["updated_at"] = DateTime.now().toIso8601String();

    await _db.insert("sync_queue", {
      "table_name": table,
      "row_id": uuid,
      "operation": operation,
      "data": data != null ? jsonEncode(data) : null,
      "synced": 0,
    });
  }

  Future<void> pushQueue(String table) async {
    final unsynced = await _db.readData(
      "SELECT * FROM sync_queue WHERE synced = 0 AND table_name = ?",
      [table],
    );

    if (unsynced.isEmpty) {
      print(" $tableℹ️ لا توجد بيانات لرفعها");
      return;
    }

    const int batchSize = 50;
    print("🚀 بدء الرفع: ${unsynced.length} عنصر");

    for (int i = 0; i < unsynced.length; i += batchSize) {
      final batch = unsynced.sublist(
        i,
        (i + batchSize > unsynced.length) ? unsynced.length : i + batchSize,
      );

      for (final row in batch) {
        final data = row["data"] != null
            ? Map<String, dynamic>.from(jsonDecode(row["data"] as String))
            : <String, dynamic>{};
        data["uuid"] = row["row_id"];

        final token = Get.find<Myservices>().sharedPreferences?.getString(
          "token",
        );
        final headers = {
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        };

        try {
          http.Response res;

          // تحقق إذا كانت صورة موجودة للمنتجات أو الفئات
          String? filePath;
          if (table == "cat_dishes") filePath = data["image"];
          if (table == "dishes") filePath = data["image"];

          bool hasImage = filePath != null && File(filePath).existsSync();

          if (hasImage) {
            // إزالة الحقل قبل الإرسال
            if (table == "cat_dishes") data.remove("image");
            if (table == "dishes") data.remove("image");

            final request = http.MultipartRequest(
              "POST",
              Uri.parse("$baseUrl/$table"),
            );
            request.headers.addAll(headers);

            // إضافة الحقول العادية
            data.forEach((key, value) {
              request.fields[key] = value.toString();
            });

            // اسم الحقل حسب الجدول
            final fieldName = "image";

            // إضافة الملف
            request.files.add(
              await http.MultipartFile.fromPath(fieldName, filePath),
            );

            final streamed = await request.send();
            res = await http.Response.fromStream(streamed);
            print("📤 رفع Multipart => $filePath");
          } else {
            // إرسال JSON عادي إذا ما فيه صورة
            res = await http.post(
              Uri.parse("$baseUrl/$table"),
              body: jsonEncode(data),
              headers: {...headers, "Content-Type": "application/json"},
            );
          }

          if (res.statusCode == 200) {
            await _db.update("sync_queue", {"synced": 1}, "id=${row["id"]}");
            print("✅ نجاح رفع ${data["uuid"]}");
          } else {
            print("❌ HTTP ${res.statusCode}: ${res.body}");
          }
        } catch (e) {
          print("❌ استثناء: $e");
        }
      }

      print("$table نجاح رفع دفعة ${i ~/ batchSize + 1} (${batch.length} سجل)");
    }

    print("🏁 انتهى الرفع.");
  }

  // ---------------------------------------------------------
  // IMAGE DOWNLOAD
  // ---------------------------------------------------------

  Future<String?> _downloadAndSaveImage(String path) async {
    try {
      if (path.isEmpty) return null;
      if (path.startsWith("/data/")) return path;

      final url = "${Applink.image}storage/$path";
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
        final file = File(filePath);
        await file.writeAsBytes(res.bodyBytes);
        return file.path;
      }
    } catch (e) {
      print("❌ فشل تحميل الصورة: $e");
    }
    return null;
  }

  // ---------------------------------------------------------
  // PULL FROM SERVER
  // ---------------------------------------------------------

  Future<void> pullFromServer(String table) async {
    try {
      final id = Get.find<Myservices>().sharedPreferences?.getInt("id");
      if (id == null) return;

      final lastSyncRow = await _db.readData(
        "SELECT last_sync FROM sync_metadata WHERE table_name='$table' AND user_id = $id",
      );
      final lastSync = lastSyncRow.isNotEmpty
          ? lastSyncRow.first["last_sync"]
          : "1970-01-01T00:00:00Z";

      final token = Get.find<Myservices>().sharedPreferences?.getString(
        "token",
      );

      int limit = 50;
      int page = 0;
      int totalDownloaded = 0;
      bool hasMore = true;

      while (hasMore) {
        final res = await http.get(
          Uri.parse(
            "$baseUrl/$table?since=$lastSync&limit=$limit&offset=${page * limit}",
          ),
          headers: {
            "Accept": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
        );
        if (res.statusCode != 200) {
          print("⚠️ HTTP ${res.statusCode}");
          break;
        }

        final List<dynamic> serverData = jsonDecode(res.body);
        totalDownloaded += serverData.length;
        print(
          "📥 دفعة ${page + 1}: تم استلام ${serverData.length} سجل (الإجمالي: $totalDownloaded)",
        );

        if (serverData.isNotEmpty) {
          print("📄 آخر سجل مستلم في هذه الدفعة: ${serverData.last}");
        }

        if (serverData.isEmpty) {
          hasMore = false;
          break;
        }
        final serverCount = serverData.length;
        // if (table != "zakats" && table != "products" && table != "categoris") {
        //   final deletedUuids = serverData
        //       .where((e) => e["is_delete"] == 1 || e["is_delete"] == "1")
        //       .map((e) => e["uuid"].toString())
        //       .toList();
        //   if (deletedUuids.isNotEmpty) {
        //     await _syncDeletedLocalRows(table, deletedUuids);
        //   }
        //   serverData
        //       .removeWhere((e) => e["is_delete"] == 1 || e["is_delete"] == "1");
        // }

        await _syncServerRecords(table, serverData);

        hasMore = serverCount == limit;
        page++;
      }

      final now = DateTime.now().toIso8601String();
      await _db.delete(
        "sync_metadata",
        "table_name = '$table' AND user_id = $id",
      );
      await _db.insert("sync_metadata", {
        "table_name": table,
        "user_id": id,
        "last_sync": now,
      });

      print("✅ اكتملت مزامنة جدول $table");
    } catch (e) {
      print("❌ pullFromServer failed: $e");
    }
  }

  Future<void> _syncServerRecords(
    String table,
    List<dynamic> serverData,
  ) async {
    final columns = await getTableColumns(_db, table);

    for (var record in serverData) {
      try {
        final uuid = record["uuid"];
        if (uuid == null) continue;

        // images
        if ((record["image"] ?? "") != "") {
          record["image"] = await _downloadAndSaveImage(record["image"]);
        }

        record.remove("id");

        final filtered = filterRecord(
          Map<String, dynamic>.from(record),
          columns,
        );

        final existing = await _db.readData(
          "SELECT * FROM $table WHERE uuid = ?",
          [uuid],
        );

        if (existing.isEmpty) {
          await _db.insert(table, filtered);
          print("📥 تم حفظ سجل جديد: $uuid في جدول $table");
        } else {
          final local = existing.first;

          final serverUpdated =
              DateTime.tryParse(record["updated_at"] ?? "") ?? DateTime(1970);

          final rawDate = local["updated_at"];
          final localUpdated = (rawDate != null)
              ? DateTime.tryParse(rawDate.toString()) ?? DateTime(1970)
              : DateTime(1970);

          if (serverUpdated.isAfter(localUpdated)) {
            await _db.update(table, filtered, "uuid = ?", [uuid]);
            print("🔄 تم تحديث سجل موجود: $uuid في جدول $table");
          }
        }
      } catch (e) {
        print("❌ فشل معالجة سجل في جدول $table: $e");
      }
    }
  }

  Map<String, Object?> filterRecord(
    Map<String, dynamic> record,
    Set<String> columns,
  ) {
    // توحيد أسماء الأعمدة لتكون حروف صغيرة للمقارنة
    final lowerColumns = columns.map((e) => e.toLowerCase()).toSet();

    return Map.fromEntries(
      record.entries
          .where((e) {
            final key = e.key.toLowerCase();
            return lowerColumns.contains(key);
          })
          .map((e) {
            // نستخدم اسم العمود الأصلي من القاعدة للحفاظ على التوافق
            final originalKey = columns.firstWhere(
              (col) => col.toLowerCase() == e.key.toLowerCase(),
              orElse: () => e.key,
            );
            return MapEntry(originalKey, e.value);
          }),
    );
  }

  Future<Set<String>> getTableColumns(SQLDB db, String table) async {
    final res = await db.readData('PRAGMA table_info($table)');
    return res.map((e) => e['name'] as String).toSet();
  }
  // ---------------------------------------------------------
  // FULL SYNC
  // ---------------------------------------------------------

  Future<void> syncAll() async {
    if (!await checkInternet()) {
      print('no_internet'.tr);
      return;
    }

    print('start_syncing'.tr);

    await pushQueue("party_types");
    await pushQueue("cat_dishes");
    await pushQueue("dishes");
    await pushQueue("special_dates");
    await pushQueue("reservations");
    await pushQueue("reservation_dishes");
    await pushQueue("expenses");
    await pushQueue("notes");
    await pushQueue("notifications");

    await pullFromServer("party_types");
    await pullFromServer("cat_dishes");
    await pullFromServer("dishes");
    await pullFromServer("special_dates");
    await pullFromServer("reservations");
    await pullFromServer("reservation_dishes");
    await pullFromServer("expenses");
    await pullFromServer("notes");
    await pullFromServer("notifications");

    print('all_sync_completed_successfully'.tr);

    Get.find<RefreshService>().fire();
  }

  // ---------------------------------------------------------
  // INTERNET LISTENER
  // ---------------------------------------------------------

  void initSyncListener() {
    print("🔄 initSyncListener started…");

    Connectivity().onConnectivityChanged.listen((results) async {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        if (await checkInternet()) {
          print('internet_restored_run_sync_all'.tr);
          await syncAll();
        }
      } else {
        print('internet_disconnected'.tr);
      }
    });
  }
}
