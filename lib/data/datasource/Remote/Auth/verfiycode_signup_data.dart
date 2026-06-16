import 'package:zeffa/LinkApi.dart';
import 'package:zeffa/core/class/Crud.dart';

class VerfiycodeSignUpData {
  Crud crud;
  VerfiycodeSignUpData(this.crud);

  postdata(String email, String verifycode) async {
    var response = await crud.postData(Applink.verfiyCode, {
      "email": email,
      "code": verifycode,
    });
    return response.fold((l) => l, (r) => r);
  }

  resendCode(String email) async {
    var response = await crud.postData(Applink.checkemail, {
      "email": email,
    });
    return response.fold((l) => l, (r) => r);
  }
}
