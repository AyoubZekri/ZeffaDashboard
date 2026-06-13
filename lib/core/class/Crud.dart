import 'dart:convert';
import 'dart:io';

import 'package:zeffa/core/services/Services.dart';
import 'package:dartz/dartz.dart';
import 'package:zeffa/core/class/Statusrequest.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zeffa/core/functions/CheckInternat.dart';
import 'package:path/path.dart';

class Crud {
  Future<Either<Statusrequest, Map>> postDataheaders(
    String linkurl,
    Map data,
  ) async {
    try {
      if (await checkInternet()) {
        var uri = Uri.parse(linkurl);
        var request = http.Request("POST", uri);

        String? token = Get.find<Myservices>().sharedPreferences?.getString(
          "token",
        );

        Map<String, String> _myheaders = {
          "Accept": "application/json",
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        };
        request.headers.addAll(_myheaders);

        request.body = jsonEncode(data);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          print(responsebody);
          return Right(responsebody);
        } else {
          Map responsebody = jsonDecode(response.body);
          print("============================$responsebody");

          return const Left(Statusrequest.failure);
        }
      } else {
        return const Left(Statusrequest.serverfailure);
      }
    } catch (_) {
      return const Left(Statusrequest.failure);
    }
  }

  Future<Either<Statusrequest, Map>> postDataheadersLogout(
    String linkurl,
  ) async {
    try {
      if (await checkInternet()) {
        var uri = Uri.parse(linkurl);
        var request = http.Request("POST", uri);

        String? token = Get.find<Myservices>().sharedPreferences?.getString(
          "token",
        );

        Map<String, String> _myheaders = {
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        };
        request.headers.addAll(_myheaders);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          print(responsebody);
          return Right(responsebody);
        } else {
          Map responsebody = jsonDecode(response.body);
          print("============================$responsebody");
          return const Left(Statusrequest.failure);
        }
      } else {
        return const Left(Statusrequest.serverfailure);
      }
    } catch (_) {
      return const Left(Statusrequest.failure);
    }
  }

  Future<Either<Statusrequest, Map>> postData(String linkurl, Map data) async {
    try {
      if (await checkInternet()) {
        var response = await http.post(
          Uri.parse(linkurl),
          body: data,
          headers: {'Accept': 'application/json'},
        );

        print(response.statusCode);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          print(responsebody);
          return Right(responsebody);
        } else {
          Map responsebody = jsonDecode(response.body);
          print("❌ API Error Response: $responsebody");

          return const Left(Statusrequest.failure);
        }
      } else {
        return const Left(Statusrequest.serverfailure);
      }
    } catch (e, stackTrace) {
      print("❌ Exception caught in Crud: $e");
      print("🔍 StackTrace: $stackTrace");
      return const Left(Statusrequest.failure);
    }
  }

  Future<Either<Statusrequest, Map>> getData(String linkurl) async {
    try {
      if (await checkInternet()) {
        var uri = Uri.parse(linkurl);
        var request = http.Request("GET", uri);

        String? token = Get.find<Myservices>().sharedPreferences?.getString(
          "token",
        );

        Map<String, String> _myheaders = {
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        };

        request.headers.addAll(_myheaders);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print(response.statusCode);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else {
          Map responsebody = jsonDecode(response.body);
          print(responsebody);

          return const Left(Statusrequest.failure);
        }
      } else {
        return const Left(Statusrequest.serverfailure);
      }
    } catch (e) {
      print("Exception: $e");
      return const Left(Statusrequest.failure);
    }
  }

  Future<Either<Statusrequest, Map>> addRequestWithImageOne(
    String url,
    Map data,
    File? image, [
    String? namerequest,
  ]) async {
    namerequest ??= "image";

    String? token = Get.find<Myservices>().sharedPreferences?.getString(
      "token",
    );

    Map<String, String> _myheaders = {
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    if (await checkInternet()) {
      var uri = Uri.parse(url);
      var request = http.MultipartRequest("POST", uri);
      request.headers.addAll(_myheaders);

      if (image != null) {
        var length = await image.length();
        var stream = http.ByteStream(image.openRead());
        stream.cast();
        var multipartFile = http.MultipartFile(
          namerequest,
          stream,
          length,
          filename: basename(image.path),
        );
        request.files.add(multipartFile);
      }

      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      var myrequest = await request.send();
      var response = await http.Response.fromStream(myrequest);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
        Map responsebody = jsonDecode(response.body);
        return Right(responsebody);
      } else {
        print("Server failure: ${response.statusCode} - ${response.body}");
        return const Left(Statusrequest.failure);
      }
    } else {
      return const Left(Statusrequest.serverfailure);
    }
  }
}
