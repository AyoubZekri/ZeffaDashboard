import 'dart:io';

Future<bool> checkInternet() async {
  try {
    // Check connection to the actual API domain instead of google.com
    var result = await InternetAddress.lookup("zeffa.codedev.id");
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
  return false;
}