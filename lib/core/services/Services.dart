import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Myservices extends GetxService {
  SharedPreferences? sharedPreferences;

  Future<Myservices> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
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
