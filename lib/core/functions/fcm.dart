// import 'package:zeffa/core/constant/routes.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:get/get.dart';

// class FcmHelper {
//   static final FlutterLocalNotificationsPlugin
//   _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   /// تهيئة Firebase و FCM
//   static Future<void> initFCM() async {
//     await Firebase.initializeApp();

//     await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: true,
//       sound: true,
//     );

//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidInit);

//     await _flutterLocalNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         final payload = response.payload;
//         if (payload != null) {
//           _handleNotificationTap(payload);
//         }
//       },
//     );

//     // إشعارات أثناء تشغيل التطبيق
//     FirebaseMessaging.onMessage.listen(_onMessageHandler);

//     // إشعارات عند فتح التطبيق من الخلفية
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedAppHandler);

//     // إشعار عند تشغيل التطبيق من البداية
//     RemoteMessage? initialMsg = await FirebaseMessaging.instance
//         .getInitialMessage();
//     if (initialMsg != null) {
//       _showLocalNotification(initialMsg);
//     }
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   }

//   static Future<void> _firebaseMessagingBackgroundHandler(
//     RemoteMessage message,
//   ) async {
//     // تهيئة Firebase في الخلفية
//     await Firebase.initializeApp();

//     print("🔔 إشعار في الخلفية أو عند الإغلاق: ${message.data}");

//     // تشغيل صوت الإشعار
//     FlutterRingtonePlayer().playNotification();

//     // عرض الإشعار المحلي (تأكد أن create channel و initialize تمت في main isolate)
//     final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//     const androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const notificationDetails = NotificationDetails(android: androidDetails);

//     await flutterLocalNotificationsPlugin.show(
//       message.hashCode,
//       message.notification?.title ?? '',
//       message.notification?.body ?? '',
//       notificationDetails,
//       payload: message.data['pagename'] ?? 'notifications',
//     );
//   }

//   /// معالجة الإشعار أثناء تشغيل التطبيق
//   static void _onMessageHandler(RemoteMessage message) {
//     print("🔔 إشعار أثناء التشغيل: ${message.notification?.title}");
//     FlutterRingtonePlayer().playNotification();
//     _showLocalNotification(message);
//   }

//   /// معالجة الضغط على الإشعار من الخلفية
//   static void _onMessageOpenedAppHandler(RemoteMessage message) {
//     print("🟢 تم الضغط على إشعار من الخلفية");
//     final pageName = message.data['pagename'];
//     if (pageName != null) {
//       _handleNotificationTap(pageName);
//     }
//   }

//   /// عرض الإشعار كمحلي مع تمرير البيانات (payload)
//   static Future<void> _showLocalNotification(RemoteMessage message) async {
//     final notification = message.notification;
//     final android = notification?.android;
//     final data = message.data;
//     final pageName = data['pagename'] ?? 'notifications';

//     if (notification != null && android != null) {
//       const androidDetails = AndroidNotificationDetails(
//         'channel_id',
//         'channel_name',
//         importance: Importance.max,
//         priority: Priority.high,
//       );

//       const details = NotificationDetails(android: androidDetails);

//       await _flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         details,
//         payload: pageName,
//       );
//     }
//   }

//   /// التوجيه حسب pagename
//   static void _handleNotificationTap(String pageName) {
//     print("🚀 التوجيه إلى صفحة: $pageName");

//     switch (pageName) {
//       case "notifications":
//         Get.toNamed(Approutes.notification);
//         break;
//       case "Dealer":
//         Get.toNamed(Approutes.Dealer, arguments: {"type": 1});
//         break;
//       case "Clients":
//         Get.toNamed(Approutes.Convicts, arguments: {"type": 2});
//         break;
//       default:
//         Get.toNamed(Approutes.notification);
//         break;
//     }
//   }
// }
