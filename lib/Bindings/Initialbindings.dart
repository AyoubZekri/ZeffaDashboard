import 'package:zeffa/core/class/Crud.dart';
import 'package:zeffa/core/services/Services.dart';
import 'package:get/get.dart';


class Initialbindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
    Get.put(Myservices());
    // Get.lazyPut(() => HomescreencontrollerImp());
  }
}
