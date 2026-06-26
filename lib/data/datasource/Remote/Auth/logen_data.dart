import 'package:zeffa/LinkApi.dart';
import 'package:zeffa/core/class/Crud.dart';

class LoginData {
  Crud crud;
  LoginData(this.crud);

  postdata(String password, String email) async {
    var response = await crud.postData(Applink.login, {
      "email": email,
      "password": password,
    });
    return response.fold((l) => l, (r) => r);
  }



  getUser() async {
    var response = await crud.getData(Applink.getUser);
    return response.fold((l) => l, (r) => r);
  }
}
