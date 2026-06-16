import 'dart:async';
import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../class/SyncServer.dart';
import '../services/Services.dart';
import 'CheckInternat.dart';

class SyncForegroundService {
  final SyncService syncService = SyncService();
  Timer? _timer;

  void start() {
    syncService.initSyncListener(); // هذا السطر يجعل المزامنة تعمل عند عودة الإنترنت

    if (Platform.isAndroid) {
      AndroidAlarmManager.periodic(
        const Duration(minutes: 15),
        123,
        syncCallback,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    } else {
      // هذا السطر يجعل المزامنة تعمل كل 15 دقيقة على ويندوز
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(minutes: 15), (_) async {
        if (await checkInternet()) {
          print("🔔 تنفيذ مهمة مزامنة دورية (foreground timer)...");
          await syncService.syncAll();
        }
      });
    }
  }

  void stop() {
    if (Platform.isAndroid) {
      AndroidAlarmManager.cancel(123);
      print("AlarmManager stopped");
    } else {
      _timer?.cancel();
      _timer = null;
      print("Timer stopped");
    }
  }
}
@pragma('vm:entry-point')
void syncCallback() async {
  await initialServices();
  if (await checkInternet()) {
    print("🔔 تنفيذ مهمة مزامنة دورية (background isolate)...");
    final sync = SyncService();
    await sync.syncAll();
  }

  print("SYNC 🔥 running in background isolate");
}
