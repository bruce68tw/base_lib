import 'package:path_provider/path_provider.dart';
import 'str_ut.dart';

//static class, cannot use _Fun
class FunUt {
  /// appBar pager button gap
  //static const pageBtnGap = EdgeInsets.all(15); 
  ///constant
  static const systemError = "System Error, Please Contact Administrator.";
  static const double fontSize = 16;
  
  static const notEmpty = '不可空白。';

  ///indicate error
  static const preError = 'E:';

  //#region input parameters
  /// api is https or not
  static bool isHttps = false; 

  /// api server
  static String apiServer = ''; 
  //#endregion
  
  /// login status
  static bool isLogin = false; 

  /// app dir
  static String dirApp = '';
  static String dirTemp = '';

  /// initial
  static Future init(bool isHttps, String apiServer) async {
    if (!StrUt.isEmpty(FunUt.apiServer)) return;

    FunUt.isHttps = isHttps;
    FunUt.apiServer = apiServer;

    var dir = await getApplicationDocumentsDirectory();
    dirApp = dir.path + '/';
    dirTemp = dirApp + '_temp/';

  }

} //class
