import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/Services.dart';
import '../../view/screen/Settings/Notifications.dart';
import '../../view/screen/ReservationsScreen.dart';
import '../../view/screen/EventTypesScreen.dart';
import '../../view/screen/DishCategoriesScreen.dart';
import '../../view/screen/DishesScreen.dart';
import '../../view/screen/CalendarScreen.dart';
import '../../view/screen/ExpensesScreen.dart';
import '../../view/screen/NotesScreen.dart';

class Siedbarcontroller extends GetxController {
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController confirmPassword;

  bool issobscureText = true;
  bool issobscureText2 = true;
  RxInt currentPage = 0.obs;
  RxnInt expandedIndex = RxnInt();
  RxnInt currentSubIndex = RxnInt();
  Rx<Widget Function()?> currentSubPage = Rx<Widget Function()?>(null);
  Myservices myservices = Get.find();

  String? get name => myservices.sharedPreferences!.getString("username");
  String? get emailofuser => myservices.sharedPreferences!.getString("email");

  RxBool isDarkMode = false.obs;

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    myservices.sharedPreferences!.setBool("isDarkMode", isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  final List<Map<String, dynamic>> screens = [
    {
      'name': 'calendar',
      'icon': Icons.calendar_month_rounded,
      'page': () => const CalendarScreen(),
      'subPages': [],
    },
    {
      'name': 'reservations',
      'icon': Icons.calendar_today_rounded,
      'page': () => const ReservationsScreen(),
      'subPages': [],
    },
    {
      'name': 'event_types',
      'icon': Icons.category_rounded,
      'page': () => const EventTypesScreen(),
      'subPages': [],
    },
    {
      'name': 'dish_categories',
      'icon': Icons.restaurant_menu_rounded,
      'page': () => const DishCategoriesScreen(),
      'subPages': [],
    },
    {
      'name': 'dishes',
      'icon': Icons.flatware_rounded,
      'page': () => const DishesScreen(),
      'subPages': [],
    },
    {
      'name': 'expenses',
      'icon': Icons.account_balance_wallet_outlined,
      'page': () => const ExpensesScreen(),
      'subPages': [],
    },
    {
      'name': 'notes',
      'icon': Icons.notes_rounded,
      'page': () => const NotesScreen(),
      'subPages': [],
    },
    {
      'name': 'settings',
      'icon': Icons.settings_outlined,
      'page': null,
      'subPages': [
        {
          'name': 'notifications',
          'icon': Icons.notifications_none_outlined,
          'page': () => const NotificationsScreen(),
        },
      ],
    },
  ];
  void changePage(int index) {
    currentPage.value = index;
    currentSubIndex.value = null;
    currentSubPage.value = null;
    update();
  }

  void toggleExpand(int index) {
    expandedIndex.value = expandedIndex.value == index ? null : index;
    update();
  }

  void changeSubPage(int subIndex, Widget Function() page) {
    currentSubIndex.value = subIndex;
    currentSubPage.value = page;
    update();
  }

  void showPassword() {
    issobscureText = issobscureText == true ? false : true;
    update();
  }

  void showPassword2() {
    issobscureText2 = issobscureText2 == true ? false : true;
    update();
  }

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    isDarkMode.value = myservices.sharedPreferences!.getBool("isDarkMode") ?? false;
    super.onInit();
  }
}
