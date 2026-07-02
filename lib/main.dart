import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'package:zeffa/Bindings/Initialbindings.dart';
import 'package:zeffa/core/localizations/ChengeLocal.dart';
import 'package:zeffa/core/localizations/Translation.dart';
import 'package:zeffa/core/services/Services.dart';
import 'package:zeffa/core/constant/AppTheme.dart';
import 'package:zeffa/routes.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/functions/callback.dart';
import 'core/functions/SystemTrayHandler.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// 👇 Listener باش نراقبو resize وحفظ حالة النافذة
class MyWindowListener extends WindowListener {
  @override
  void onWindowResize() async {
    final size = await windowManager.getSize();
    if (size.width < 1000 || size.height < 800) {
      await windowManager.setSize(const Size(1000, 800));
    }
    saveWindowState();
  }

  @override
  void onWindowMove() async {
    saveWindowState();
  }

  @override
  void onWindowMaximize() async {
    saveWindowState();
  }

  @override
  void onWindowUnmaximize() async {
    saveWindowState();
  }

  @override
  void onWindowRestore() async {
    saveWindowState();
  }
}

void saveWindowState() async {
  try {
    final prefs = Get.find<Myservices>().sharedPreferences;
    if (prefs == null) return;

    bool isMaximized = await windowManager.isMaximized();
    await prefs.setBool("window_maximized", isMaximized);

    if (!isMaximized) {
      final size = await windowManager.getSize();
      final pos = await windowManager.getPosition();
      
      if (size.width >= 1000 && size.height >= 800) {
        await prefs.setDouble("window_width", size.width);
        await prefs.setDouble("window_height", size.height);
      }
      await prefs.setDouble("window_x", pos.dx);
      await prefs.setDouble("window_y", pos.dy);
    }
  } catch (e) {
    print("Error saving window state: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await initialServices();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  /// 👇 تهيئة window_manager
  await windowManager.ensureInitialized();

  /// 👇 إضافة listener
  windowManager.addListener(MyWindowListener());

  final prefs = Get.find<Myservices>().sharedPreferences;
  bool isMaximized = prefs?.getBool("window_maximized") ?? true;
  double? width = prefs?.getDouble("window_width");
  double? height = prefs?.getDouble("window_height");
  double? px = prefs?.getDouble("window_x");
  double? py = prefs?.getDouble("window_y");

  /// 👇 إعدادات النافذة
  WindowOptions windowOptions = WindowOptions(
    size: Size(width ?? 1200, height ?? 800),
    minimumSize: const Size(1000, 800), // الحد الأدنى
    center: px == null || py == null,
    title: "Zeffa",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (px != null && py != null) {
      await windowManager.setPosition(Offset(px, py));
    }
    if (isMaximized) {
      await windowManager.maximize();
    } else {
      await windowManager.unmaximize();
    }
    await windowManager.show();
    await windowManager.focus();
  });
  
  final syncForeground = SyncForegroundService();
  syncForeground.start();
  
  runApp(const SystemTrayHandler(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    LocalController controller = Get.put(LocalController());
    Get.put(RefreshService());
    return GetMaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      navigatorObservers: [routeObserver],
      translations: MyTranslation(),
      debugShowCheckedModeBanner: false,
      title: 'zeffa',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          Get.find<Myservices>().sharedPreferences!.getBool("isDarkMode") ??
              false
          ? ThemeMode.dark
          : ThemeMode.light,
      locale: controller.language,
      initialBinding: Initialbindings(),
      getPages: routes,

      /// 👇 نحبسو تكبير الخط فقط
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
