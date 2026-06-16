import 'package:zeffa/LinkApi.dart';
import 'package:zeffa/core/class/Crud.dart';

class ResetpasswordData {
  Crud crud;
  ResetpasswordData(this.crud);

  postdata(String password, String confermPassword, String email) async {
    var response = await crud.postData(Applink.resePassword, {
      "password": password,
      "password_confirmation": confermPassword,
      "email": email,
    });
    return response.fold((l) => l, (r) => r);
  }

  Resset(String Oldpassword, String password, String confermPassword) async {
    var response = await crud.postDataheaders(Applink.resetPasswordSetting, {
      "old_password": Oldpassword,
      "password": password,
      "password_confirmation": confermPassword,
    });
    return response.fold((l) => l, (r) => r);
  }
}
