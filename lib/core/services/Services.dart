import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Myservices extends GetxService {
  SharedPreferences? sharedPreferences;

  Future<Myservices> init() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } on FormatException catch (e) {
      // Desktop: the settings file got corrupted (e.g. closed while saving).
      // Set it aside and start with fresh settings instead of failing at launch.
      print("⚠️ shared_preferences.json corrupted, resetting: $e");
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
        final dir = await getApplicationSupportDirectory();
        final file = File(
          '${dir.path}${Platform.pathSeparator}shared_preferences.json',
        );
        if (await file.exists()) {
          await file.rename(
            '${file.path}.corrupt-${DateTime.now().millisecondsSinceEpoch}',
          );
        }
      }
      sharedPreferences = await SharedPreferences.getInstance();
    }
    return this;
  }
}

class RefreshService extends GetxService {
  var refreshTrigger = false.obs;

  void fire() {
    refreshTrigger.value = !refreshTrigger.value;
  }
}

initialServices() async {
  print("initialServices running");
  await Get.putAsync(() => Myservices().init());
  print("initialServices done");
}
