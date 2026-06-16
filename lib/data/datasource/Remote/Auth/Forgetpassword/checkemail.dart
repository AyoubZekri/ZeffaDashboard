import 'package:zeffa/LinkApi.dart';
import 'package:zeffa/core/class/Crud.dart';

class Checkemaildata {
  Crud crud;
  Checkemaildata(this.crud);

  postdata(String email) async {
    var response = await crud.postData(Applink.checkemail, {"email": email});
    return response.fold((l) => l, (r) => r);
  }
}
