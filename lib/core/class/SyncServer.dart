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
  final String baseUrl = "https://silaaty_desktop.codedev.id/api/sync";

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
          if (table == "products") filePath = data["Product_image"];
          if (table == "categoris") filePath = data["categoris_image"];

          bool hasImage = filePath != null && File(filePath).existsSync();

          if (hasImage) {
            // إزالة الحقل قبل الإرسال
            if (table == "products") data.remove("Product_image");
            if (table == "categoris") data.remove("categoris_image");

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
            final fieldName = table == "categoris"
                ? "categoris_image"
                : "Product_image";

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

  Future<void> _processQueueRow(Map row) async {
    final table = row["table_name"];
    final operation = row["operation"];
    final data = row["data"] != null ? jsonDecode(row["data"]) : {};
    data["uuid"] = row["row_id"];

    final token = Get.find<Myservices>().sharedPreferences?.getString("token");
    final headers = {
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    try {
      http.Response res;

      if (operation == "delete") {
        res = await _deleteRequest(table, data, headers);
      } else {
        res = await _sendDataRequest(table, data, headers);
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

  Future<http.Response> _deleteRequest(
    String table,
    Map data,
    Map<String, String> headers,
  ) {
    print("🗑️ حذف uuid=${data["uuid"]} من جدول $table");
    return http.post(
      Uri.parse("$baseUrl/delete/$table"),
      body: jsonEncode({"uuid": data["uuid"]}),
      headers: {...headers, "Content-Type": "application/json"},
    );
  }

  Future<http.Response> _sendDataRequest(
    String table,
    Map<String, dynamic> data,
    Map<String, String> headers,
  ) async {
    String? filePath;

    // تحديد الصورة حسب الجدول
    if (table == "products") {
      filePath = data["Product_image"];
    } else if (table == "categoris") {
      filePath = data["categoris_image"];
    }

    bool hasImage = filePath != null && File(filePath).existsSync();

    if (hasImage) {
      // إزالة المسار المحلي من JSON قبل الإرسال
      if (table == "products") data.remove("Product_image");
      if (table == "categoris") data.remove("categoris_image");
      print("=====================prodact");
      return _sendMultipart(table, data, headers, filePath);
    }
    print("=====================noprodact");

    // إرسال البيانات بدون صورة
    return http.post(
      Uri.parse("$baseUrl/$table"),
      body: jsonEncode(data),
      headers: {...headers, "Content-Type": "application/json"},
    );
  }

  Future<http.Response> _sendMultipart(
    String table,
    Map<String, dynamic> data,
    Map<String, String> headers,
    String filePath,
  ) async {
    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/$table"));
    request.headers.addAll(headers);

    // إضافة الحقول العادية
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // اسم الحقل حسب الجدول
    final fieldName = table == "categoris"
        ? "categoris_image"
        : "Product_image";

    // إضافة الملف نفسه
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    print("📤 رفع Multipart => $filePath");

    final streamed = await request.send();
    return http.Response.fromStream(streamed);
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

        if (serverData.isEmpty) {
          hasMore = false;
          break;
        }
        final serverCount = serverData.length;
        if (table != "zakats" && table != "products" && table != "categoris") {
          final deletedUuids = serverData
              .where((e) => e["is_delete"] == 1 || e["is_delete"] == "1")
              .map((e) => e["uuid"].toString())
              .toList();
          if (deletedUuids.isNotEmpty) {
            await _syncDeletedLocalRows(table, deletedUuids);
          }
          serverData.removeWhere(
            (e) => e["is_delete"] == 1 || e["is_delete"] == "1",
          );
        }

        await _syncServerRecords(table, serverData);

        print("📥 دفعة ${page + 1}: ${serverData.length} سجل");

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

  Future<List<String>> _syncDeletedLocalRows(
    String table,
    List<String> deletedUuids,
  ) async {
    if (deletedUuids.isEmpty) return [];

    List<String> foundLocally = [];

    for (final uuid in deletedUuids) {
      final row = await _db.readData("SELECT uuid FROM $table WHERE uuid = ?", [
        uuid,
      ]);

      if (row.isNotEmpty) {
        await _db.delete(table, "uuid = ?", [uuid]);
        print("🗑️ حذف محلي => $uuid");
        foundLocally.add(uuid);
      }
    }

    return foundLocally;
  }

  Future<void> _syncServerRecords(
    String table,
    List<dynamic> serverData,
  ) async {
    for (var record in serverData) {
      final uuid = record["uuid"];

      // معالجة الصور
      if (record["categoris_image"] != null &&
          record["categoris_image"] != "") {
        record["categoris_image"] = await _downloadAndSaveImage(
          record["categoris_image"],
        );
      }
      if (record["Product_image"] != null && record["Product_image"] != "") {
        record["Product_image"] = await _downloadAndSaveImage(
          record["Product_image"],
        );
      }

      record.remove("id");

      final existing = await _db.readData(
        "SELECT * FROM $table WHERE uuid='$uuid'",
      );

      if (existing.isEmpty) {
        await _db.insert(table, Map<String, Object?>.from(record));
      } else {
        final local = existing.first;
        final serverUpdated =
            DateTime.tryParse(record["updated_at"] ?? "") ?? DateTime(1970);
        final rawDate = local["updated_at"];

        final localUpdated =
            (rawDate != null &&
                rawDate.toString().isNotEmpty &&
                rawDate.toString() != "null")
            ? DateTime.tryParse(rawDate.toString()) ?? DateTime(1970)
            : DateTime(1970);
        if (serverUpdated.isAfter(localUpdated)) {
          await _db.update(
            table,
            Map<String, Object?>.from(record),
            "uuid='$uuid'",
          );
        }
      }
    }
  }

  // ---------------------------------------------------------
  // FULL SYNC
  // ---------------------------------------------------------

  Future<void> syncAll() async {
    if (!await checkInternet()) {
      print("🚫 مافيش انترنت");
      return;
    }

    print("🌐 بدء المزامنة…");

    await pushQueue("categoris");
    await pushQueue("transactions");
    await pushQueue("invoies");
    await pushQueue("products");
    await pushQueue("sales");
    await pushQueue("notifications");
    await pushQueue("reports");
    await pushQueue("zakats");

    await pullFromServer("categoris");
    await pullFromServer("transactions");
    await pullFromServer("invoies");
    await pullFromServer("products");
    await pullFromServer("sales");
    await pullFromServer("notifications");
    await pullFromServer("reports");
    await pullFromServer("zakats");

    print("✅ كل المزامنة كملت بنجاح");

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
          print("🌐 الانترنت رجع — تشغيل syncAll()");
          await syncAll();
        }
      } else {
        print("📴 الانترنت انقطع");
      }
    });
  }
}
