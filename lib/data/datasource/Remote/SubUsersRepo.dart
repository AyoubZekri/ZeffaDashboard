import '../../../LinkApi.dart';
import '../../../core/class/Crud.dart';

class SubUsersRepo {
  final Crud crud;

  SubUsersRepo(this.crud);

  Future<dynamic> viewdata() async {
    var response = await crud.getData(Applink.subUsersGet);
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> Adddata(
    String username,
    String email,
    String password,
    int roleId,
  ) async {
    var response = await crud.postDataheaders(Applink.subUsersAdd, {
      "username": username,
      "email": email,
      "password": password,
      "role_id": roleId.toString(),
    });
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> Updatedata(
    String id,
    String username,
    String email,
    String password,
    int roleId,
  ) async {
    Map<String, dynamic> data = {
      "username": username,
      "email": email,
      "role_id": roleId.toString(),
    };
    if (password.isNotEmpty) {
      data["password"] = password;
    }
    var response = await crud.postDataheaders(
      "${Applink.subUsersUpdate}/$id",
      data,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> Deletedata(String id) async {
    var response = await crud.postDataheaders(
      "${Applink.subUsersDelete}/$id",
      {},
    );
    return response.fold((l) => l, (r) => r);
  }
}
