import 'dart:io';

import 'package:zeffa/LinkApi.dart';
import 'package:zeffa/core/class/Crud.dart';

class Userdata {
  Crud crud;
  Userdata(this.crud);

  updateuser(
    String username,
    String phone,
    String adresse,
    String hallname,
    String fieldPhone,
    File? file,
  ) async {
    var response;

    if (file == null) {
      response = await crud.postDataheaders(Applink.updateUser, {
        "adresse": adresse,
        "username": username,
        "hallname": hallname,
        "numperPhone": phone,
        "fieldPhone": fieldPhone,
      });
    } else {
      response = await crud.addRequestWithImageOne(
        Applink.updateUser,
        {
          "adresse": adresse,
          "username": username,
          "hallname": hallname,
          "numperPhone": phone,
          "fieldPhone": fieldPhone,
        },
        file,
        "image",
      );
    }

    return response.fold((l) => l, (r) => r);
  }


}
