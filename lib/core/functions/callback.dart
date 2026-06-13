// import 'dart:async';
import 'package:zeffa/core/class/SyncServer.dart';
import 'package:zeffa/core/functions/CheckInternat.dart';
import 'package:zeffa/core/services/Services.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class SyncForegroundService {
  final SyncService syncService = SyncService();
  // Timer? _timer;

  void start() {
    syncService.initSyncListener();

    //   _timer?.cancel();
    //   _timer = Timer.periodic(const Duration(minutes: 15), (_) async {
    //     if (await checkInternet()) {
    //       print("🔔 تنفيذ مهمة مزامنة دورية (foreground)...");
    //       await syncService.syncAll();
    //     }
    //   });

    AndroidAlarmManager.periodic(
      const Duration(minutes: 15),
      123,
      syncCallback,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  // void stop() {
  //   _timer?.cancel();
  //   _timer = null;
  // }

  void stop() {
    AndroidAlarmManager.cancel(123);
    print("AlarmManager stopped");
  }
}

void syncCallback() async {
  await initialServices();
  if (await checkInternet()) {
    print("🔔 تنفيذ مهمة مزامنة دورية (background isolate)...");
    final sync = SyncService();
    await sync.syncAll();
  }

  print("SYNC 🔥 running in background isolate");
}
