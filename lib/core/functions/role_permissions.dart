import 'dart:convert';
import 'package:get/get.dart';
import '../services/Services.dart';

/// Role check for an action / page. The owner (no role) and full roles can do
/// everything; a partial role only what its permissions list contains.
bool hasRolePermission(String permission) {
  final prefs = Get.find<Myservices>().sharedPreferences;
  if ((prefs?.getString("type") ?? "") != "partial") return true;
  try {
    final perms = jsonDecode(prefs?.getString("permissions") ?? "[]") as List;
    return perms.map((e) => e.toString()).contains(permission);
  } catch (e) {
    return false;
  }
}
