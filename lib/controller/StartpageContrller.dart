import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../LinkApi.dart';
import '../core/class/Statusrequest.dart';
import '../core/functions/handlingdatacontroller.dart';
import '../core/services/Services.dart';
import '../data/datasource/Remote/Auth/logen_data.dart';

class Startpagecontrller extends GetxController {
  LoginData logenData = LoginData(Get.find());
  // List data = [];
  late int Status;
  Myservices myServices = Get.find();

  String date_experiment = "";

  Statusrequest statusrequest = Statusrequest.none;

  getUser() async {
    statusrequest = Statusrequest.loadeng;
    update();
    var response = await logenData.getUser();
    print("==============================$response");
    statusrequest = handlingData(response);
    if (statusrequest == Statusrequest.success) {
      if (response["status"] == 1) {
        Status = response['data']["data"][0]['status'];
        var user = response["data"]["data"][0];
        String imageUrl = user["image"] ?? "";
        String localPath = "";
        if (imageUrl.isNotEmpty) {
          String fileName = imageUrl.split("/").last;
          String fullUrl = "${Applink.image}/storage/$imageUrl";
          localPath = await downloadAndCacheImage(fullUrl, fileName);
        }
        myServices.sharedPreferences!.setString("image", localPath);

        myServices.sharedPreferences!.setInt("id", user['id']);
        myServices.sharedPreferences!.setString("email", user['email']);
        myServices.sharedPreferences!.setString("username", user["username"]);
        myServices.sharedPreferences!.setString("numperPhone", user["numperPhone"]);
        myServices.sharedPreferences!.setString("hallname", user["hallname"]);
        myServices.sharedPreferences!
            .setInt("user_notify_status", user["user_notify_status"]);
        if (user["adresse"] != null)
          myServices.sharedPreferences!.setString("adresse", user["adresse"]);
        myServices.sharedPreferences!.setInt("status", user["status"]);
        print("==================================${user["date_experiment"]}");
        if (user["date_experiment"] != null) {
          myServices.sharedPreferences!
              .setString("date_experiment", user["date_experiment"]);
          date_experiment = user["date_experiment"];
        }
      }
    }

    update();
  }

  Future<String> downloadAndCacheImage(String imageUrl, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/$fileName";

      File file = File(filePath);

      await file.parent.create(recursive: true);

      if (await file.exists()) {
        return filePath;
      }

      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }

      return "";
    } catch (e) {
      return "";
    }
  }
}
