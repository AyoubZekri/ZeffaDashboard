class Applink {
  static const String server = "https://zeffa.codedev.id/api";
  static const String image = "https://zeffa.codedev.id";

  //  =============================Auth============================== //

  static const String login = "$server/User/Login";
  static const String linkSignup = "$server/User/create";
  static const String updateUser = "$server/User/update";
  static const String verfiyCode = "$server/User/verifyCode";
  static const String checkemail = "$server/User/sendCode";
  static const String resePassword = "$server/User/newpassword";
  static const String resetPasswordSetting = "$server/User/resetpassword";

  static const String getUser = "$server/User/get";

  // =============================Roles============================== //
  static const String rolesGet = "$server/roles/get";
  static const String rolesAdd = "$server/roles/add";
  static const String rolesUpdate = "$server/roles/update";
  static const String rolesDelete = "$server/roles/delete";

  // =============================Sub Users============================== //
  static const String subUsersGet = "$server/sub-users/get";
  static const String subUsersAdd = "$server/sub-users/add";
  static const String subUsersUpdate = "$server/sub-users/update";
  static const String subUsersDelete = "$server/sub-users/delete";
}
