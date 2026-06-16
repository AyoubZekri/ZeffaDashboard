class Applink {
  static const String server = "https://zeffa.codedev.id/api";
  static const String image = "http://zeffa.codedev.id/";

  //  =============================Auth============================== //

  static const String login = "$server/User/Login";
  static const String linkSignup = "$server/User/create";
  static const String updateUser = "$server/User/update";
  static const String verfiyCode = "$server/User/verifyCode";
  static const String checkemail = "$server/User/sendCode";
  static const String resePassword = "$server/User/newpassword";
  static const String resetPasswordSetting = "$server/User/resetpassword";

  static const String logout = "$server/User/logout";
  static const String getUser = "$server/User/get";

}
