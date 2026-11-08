import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:get/get.dart';
import 'package:win32/win32.dart';

import '../services/Services.dart';

/// "Remember me" storage for the desktop app.
///
/// Values are encrypted with Windows DPAPI (CryptProtectData), bound to the
/// current Windows user, and kept in the app settings. Replaces
/// flutter_secure_storage, whose Windows plugin needs Visual Studio's ATL.
class SecureLoginStorage {
  static const _prefix = "secure_";

  static Future<String?> read(String key) async {
    final prefs = Get.find<Myservices>().sharedPreferences;
    final stored = prefs?.getString("$_prefix$key");
    if (stored == null || stored.isEmpty) return null;
    try {
      final bytes = base64Decode(stored);
      return utf8.decode(Platform.isWindows ? _dpapi(bytes, encrypt: false) : bytes);
    } catch (e) {
      // Unreadable (other Windows user / damaged): forget it
      await delete(key);
      return null;
    }
  }

  static Future<void> write(String key, String value) async {
    final prefs = Get.find<Myservices>().sharedPreferences;
    final bytes = Uint8List.fromList(utf8.encode(value));
    final data = Platform.isWindows ? _dpapi(bytes, encrypt: true) : bytes;
    await prefs?.setString("$_prefix$key", base64Encode(data));
  }

  static Future<void> delete(String key) async {
    await Get.find<Myservices>().sharedPreferences?.remove("$_prefix$key");
  }

  /// Encrypt / decrypt with DPAPI for the current Windows user
  static Uint8List _dpapi(Uint8List data, {required bool encrypt}) {
    final input = calloc<CRYPT_INTEGER_BLOB>();
    final output = calloc<CRYPT_INTEGER_BLOB>();
    final buffer = calloc<Uint8>(data.isEmpty ? 1 : data.length);
    try {
      buffer.asTypedList(data.length).setAll(0, data);
      input.ref
        ..cbData = data.length
        ..pbData = buffer;

      final ok = encrypt
          ? CryptProtectData(input, nullptr, nullptr, nullptr, nullptr, 0, output)
          : CryptUnprotectData(input, nullptr, nullptr, nullptr, nullptr, 0, output);
      if (ok == 0) {
        throw StateError("DPAPI failed (${GetLastError()})");
      }

      final result = Uint8List.fromList(
        output.ref.pbData.asTypedList(output.ref.cbData),
      );
      LocalFree(output.ref.pbData);
      return result;
    } finally {
      calloc.free(buffer);
      calloc.free(input);
      calloc.free(output);
    }
  }
}
