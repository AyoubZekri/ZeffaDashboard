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

  static const String CategoriesGet = "$server/categories";
  static const String AddProdact = "$server/products/create";
  static const String GetCatProdact = "$server/products/show_cat";
  static const String Searchproduct = "$server/products/search";

  static const String GetCatProdactbytype = "$server/products/show_by_cat";

  static const String updateProdact = "$server/products/update";
  static const String ShwoProdact = "$server/products/show";
  static const String SwitchProdact = "$server/products/Switch";
  static const String deleteProdact = "$server/products/delete";

  static const String Zakat = "$server/Zakat";
  static const String shwoproductZakat = "$server/products/Zakat/show";
  static const String cashliquidity = "$server/Zakat/addCashliquidity";
  static const String switchtransactions = "$server/transactions/Switch";

  static const String Addcat = "$server/categories/create";
  static const String EditCat = "$server/categories/update";
  static const String Deletecat = "$server/categories/delete";

  static const String addtransaction = "$server/transactions/add";
  static const String Edittransaction = "$server/transactions/update";
  static const String deletetransaction = "$server/transactions/delete";
  static const String transaction = "$server/transactions/by-type";

  static const String addinvoice = "$server/invoice/add";
  static const String Editinvoise = "$server/invoice/update";
  static const String deleteinvoice = "$server/invoice/delete";

  static const String Shwoinvoice = "$server/invoice/by-transaction";
  static const String Shwoinfoinvoice = "$server/invoice/show";

  static const String addReport = "$server/Report/create";
  static const String ShwoinfoReport = "$server/Report/show";
  static const String Report = "$server/Report";
  static const String updatrReport = "$server/Report/update";
  static const String deleteReport = "$server/Report/delete";

  static const String shwoinfoNotification = "$server/Notification/shwo";
  static const String notification = "$server/Notification";
  static const String deleteNotification = "$server/Notification/delete";
}
