import '../../../LinkApi.dart';
import '../../../core/class/Crud.dart';

class RolesRepo {
  final Crud crud;

  RolesRepo(this.crud);

  Future<dynamic> viewdata() async {
    var response = await crud.getData(Applink.rolesGet);
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> Adddata(String name, String type, String permissions) async {
    var response = await crud.postDataheaders(Applink.rolesAdd, {
      "name": name,
      "type": type,
      "permissions": permissions,
    });
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> Updatedata(String id, String name, String type, String permissions) async {
    var response = await crud.postDataheaders("${Applink.rolesUpdate}/$id", {
      "name": name,
      "type": type,
      "permissions": permissions,
    });
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> Deletedata(String id) async {
    var response = await crud.postDataheaders("${Applink.rolesDelete}/$id", {});
    return response.fold((l) => l, (r) => r);
  }
}
