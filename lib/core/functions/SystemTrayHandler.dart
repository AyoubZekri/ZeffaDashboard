import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

class SystemTrayHandler extends StatefulWidget {
  final Widget child;
  const SystemTrayHandler({super.key, required this.child});

  @override
  State<SystemTrayHandler> createState() => _SystemTrayHandlerState();
}

class _SystemTrayHandlerState extends State<SystemTrayHandler> with WindowListener, TrayListener {

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      windowManager.addListener(this);
      trayManager.addListener(this);
      _initTray();
    }
  }

  Future<void> _initTray() async {
    await windowManager.setPreventClose(true);
    
    // Use ico for Windows, png for others
    String iconPath = Platform.isWindows ? 'windows/runner/resources/app_icon.ico' : 'assets/images/Logo.png';
    await trayManager.setIcon(iconPath);
    
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'إظهار التطبيق',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'خروج',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
    }
  }

  @override
  void onTrayIconMouseDown() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.show();
      await windowManager.focus();
    } else if (menuItem.key == 'exit_app') {
      await windowManager.setPreventClose(false);
      await windowManager.destroy(); // fully close
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
