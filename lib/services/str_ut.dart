import 'dart:developer';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';

//static class
class StrUt {
  ///pre error, 2 chars
  static const preError = 'E:';

  static bool isEmpty(String? str) {
    return (str == null || str == '');
  }

  static bool notEmpty(String? str) {
    return !isEmpty(str);
  }

  static String getError(String msg) {
    return preError + msg;
  }

  ///check & get error msg if any
  static String checkError(String msg) {
    return isEmpty(msg)
        ? ''
        : msg.substring(0, 2) == preError
            ? msg.substring(2)
            : '';
  }

  static String addNum(String str, int num) {
    return (int.parse(str) + num).toString();
  }

  static String preZero(int len, String str, [bool? matchLen]) {
    matchLen ??= false;
    return (str.length < len)
        ? str.padLeft(len, '0')
        : matchLen
            ? str.substring(0, len)
            : str;
  }

  static String utf8Decode(String str) {
    //List<int> bytes = utf8.encode(str);
    return const Utf8Decoder().convert(utf8.encode(str));
  }

  //AES encode, data:plain text
  static String aesEncode(String data, String aesKey) {
    //var aesKey = preZero(16, await FunHp.getIp(), true);
    //var aesKey = getAesKey();
    final key = Key.fromUtf8(aesKey);
    final iv = IV.fromUtf8(aesKey);
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb, padding: 'PKCS7'));
    return encrypter.encrypt(data, iv: iv).base64;
  }

  //AES decode, data:encoded base64 string
  static String aesDecode(String data, String aesKey) {
    //var aesKey = await FunHp.getIp();
    //var aesKey = getAesKey();
    final key = Key.fromUtf8(aesKey);
    final iv = IV.fromUtf8(aesKey);
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb, padding: 'PKCS7'));
    return encrypter.decrypt(Encrypted.fromBase64(data), iv: iv);
  }

  static Map<String, dynamic>? toJson(String data, {bool showLog = true}) {
    try {
      return jsonDecode(data);
    } on Exception catch (e) {
      if (showLog) log('Error: $e');
      return null;
    }
  }
  
}//class
