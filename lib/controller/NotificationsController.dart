import 'package:get/get.dart';
import '../data/datasource/Remote/NotificationsData.dart';
import '../data/model/NotificationModel.dart';
import '../core/class/statusrequest.dart';
import '../core/functions/handlingdatacontroller.dart';

class NotificationsController extends GetxController {
  final NotificationsData _data = NotificationsData();

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxString currentFilter = 'all'.obs; // 'all', 'unread'

  Statusrequest statusrequest = Statusrequest.none;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get filteredNotifications {
    if (currentFilter.value == 'unread') {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    update();

    final response = await _data.getNotifications();

    if (response.isNotEmpty) {
      notifications.assignAll(
        response.map((e) => NotificationModel.fromJson(e)).toList(),
      );
    } else {
      notifications.clear();
    }
    update();
  }

  Future<void> markAsRead(String uuid) async {
    final success = await _data.markAsRead(uuid);
    if (success) {
      final index = notifications.indexWhere((n) => n.uuid == uuid);
      if (index != -1) {
        notifications[index].isRead = true;
        notifications.refresh();
        update();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _data.markAllAsRead();
    if (success) {
      for (var n in notifications) {
        n.isRead = true;
      }
      notifications.refresh();
      update();
    }
  }

  Future<void> deleteNotification(String uuid) async {
    final success = await _data.deleteNotification(uuid);
    if (success) {
      notifications.removeWhere((n) => n.uuid == uuid);
      notifications.refresh();
      update();
    }
  }

  Future<void> deleteAllNotifications() async {
    final success = await _data.deleteAllNotifications();
    if (success) {
      notifications.clear();
      notifications.refresh();
      update();
    }
  }

  // Dummy helper for testing initially
  Future<void> generateDummyNotification() async {
    await _data.addNotification(
      "new_sale_success".tr,
      "notif_desc_1".tr,
      "sale",
    );
    fetchNotifications();
  }
}
