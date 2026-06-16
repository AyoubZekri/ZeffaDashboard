import 'package:zeffa/LinkApi.dart';
import 'package:zeffa/core/class/Crud.dart';

class SignupData {
  Crud crud;
  SignupData(this.crud);

  postdata(
    String username,
    String password,
    String email,
    String phone,
    String confermPassword,
    String hallname,
    String adresse,
  ) async {
    var response = await crud.postData(Applink.linkSignup, {
      "username": username,
      "password": password,
      "password_confirmation": confermPassword,
      "hallname": hallname,
      "email": email,
      "numperPhone": phone,
      "adresse": adresse,
    });
    return response.fold((l) => l, (r) => r);
  }
}
