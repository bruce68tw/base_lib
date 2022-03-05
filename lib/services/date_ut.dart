import 'package:intl/intl.dart';

//static class
class DateUt {
  static const _dtCsFormat = 'yyyy/MM/dd HH:mm:ss';
  static const _dtCsFormat2 = 'yyyy/MM/dd HH:mm';

  //yyyy/MM/dd hh:mm
  static String format2(String dts) {
    //var format = 'yyyy-MM-dd HH:mm';
    var dt = DateFormat(_dtCsFormat).parse(dts);
    //var dt = dateFormat.parse(dts);
    return DateFormat(_dtCsFormat2).format(dt);
  }
} //class
