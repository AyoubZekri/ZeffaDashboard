import 'package:zeffa/LinkApi.dart';
import 'package:zeffa/core/class/Crud.dart';

class Verifycodedata {
  Crud crud;
  Verifycodedata(this.crud);

  postdata(String verifiycode, String email) async {
    var response = await crud.postData(Applink.verfiyCode, {
      "email": email,
      "code": verifiycode,
    });
    return response.fold((l) => l, (r) => r);
  }

  // resendverfiycode(
  //   String email,
  // ) async {
  //   var response = await crud.postData(Applink.resendverfiycode, {
  //     "email": email,
  //   });
  //   return response.fold((l) => l, (r) => r);
  // }
}
