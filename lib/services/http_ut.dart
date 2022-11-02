//1.dart sdk
import 'dart:io';
import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';
//2.flutter sdk
import 'package:flutter/widgets.dart';
//3.3rd package
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
//4.base_lib
import 'package:base_lib/all.dart';

//static class
class HttpUt {
  /// jwt token
  static String _token = '';

  static void setToken(String token) {
    _token = token;
  }

  //get api uri
  static Uri _apiUri(String action, [Map<String, dynamic>? json]) {
    return FunUt.isHttps
        ? Uri.https(FunUt.apiServer, action, json)
        : Uri.http(FunUt.apiServer, action, json);
  }

  /*
  static String _apiUrl(String action) {
    var uri = _apiUrl(action);
    return uri.toString();
  }
  */

  static Future getStrAsync(BuildContext? context, String action,
      bool jsonArg, [Map<String, dynamic>? json, Function? fnOk]) async {
    await _rpcAsync(context, action, jsonArg, false, json, fnOk);
  }

  static Future getJsonAsync(
      BuildContext? context, String action, bool jsonArg, 
      [Map<String, dynamic>? json, Function? fnOk]) async {
    await _rpcAsync(context, action, jsonArg, true, json, fnOk);
  }

  static Future<Image?> getImageAsync(BuildContext? context, 
      String action, [Map<String, dynamic>? json]) async {
    var resp = await _getRespAsync(context, action, false, json);
    return (resp == null) ? null : Image.memory(resp.bodyBytes);
  }

  ///download and unzip
  ///return file index(base 1) if not batch
  static Future<int> saveUnzipAsync(BuildContext context, String action, 
      Map<String, dynamic> json, String dirSave) async {

    //create folder if need
    var dir = Directory(dirSave);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    //if no file, download it
    //var action = isBatch ? 'GetBatchImage' : 'GetStepImage';
    var bytes = await _getFileBytesAsync(context, action, json);    
    if (bytes == null) return 0;

    var fileName = '';
    var files = ZipDecoder().decodeBytes(bytes);
    var dirBase = dir.path + '/';
    for (var file in files) {
      //..cascade operator
      fileName = file.name;
      File(dirBase + file.name)
        ..createSync()
        ..writeAsBytesSync(file.content as List<int>, flush:true);
    }

    //get file sort
    var cols = fileName.split('_');
    return (cols.length < 3) ? 0 : int.parse(cols[0]);
  }

  static Future<Uint8List?> _getFileBytesAsync(BuildContext? context, 
      String action, [Map<String, dynamic>? json]) async {
    var resp = await _getRespAsync(context, action, false, json);
    return (resp == null) ? null : resp.bodyBytes;
  }

  ///get response
  ///called by: _rpcAsync, getFileBytesAsync
  static Future<http.Response?> _getRespAsync(BuildContext? context,
      String action, [bool jsonArg = false, Map<String, dynamic>? json]) async {
        
    String body = '';
    String conType;
    Map<String, dynamic>? arg;
    //1.set content type
    if (jsonArg){
      body = (json == null) ? '' : jsonEncode(json);
      conType = 'application/json';
    } else {
      conType = 'plain/text';
      arg = json; //as query string
    }
    var headers = {
      'Content-Type': conType + '; charset=utf-8',
      //'Access-Control-Allow-Origin': '*',
      //'Cache-Control': 'no-cache',
    };

    //2.add token if existed
    if (!StrUt.isEmpty(_token)) headers['Authorization'] = 'Bearer ' + _token;

    //3.show waiting
    ToolUt.openWait(context);

    //4.http request
    http.Response? resp;
    try {
      resp = await http
          .post(
            _apiUri(action, arg),
            headers: headers,
            body: body)
          .timeout(const Duration(seconds: 30));
    /*
    } on TimeoutException {
      log('Error: 連線時間超過20秒。');
      return null;
    */
    } catch (e) {
      log('Error: $e');
    } finally {	
      //close waiting
      ToolUt.closeWait(context);
    }

    return resp;
  }

  static Future _rpcAsync(BuildContext? context, String action, bool jsonArg, 
      bool jsonOut, [Map<String, dynamic>? json, Function? fnOk]) async {
        
    //get response & check error
    var resp = await _getRespAsync(context, action, jsonArg, json);
    if (resp == null) {
      ToolUt.msg(context, '無法存取遠端資料 !!');
      return;
    } else if (resp.statusCode == 401){
      ToolUt.msg(context, '因為長時間閒置, 系統已經離線, 請重新執行這個程式。');
      return;
    } else if (resp.statusCode >= 400){
      ToolUt.msg(context, 'Error: ${resp.reasonPhrase}!(${resp.statusCode})');
      return;
    }

    //show error msg if any
    var str = utf8.decode(resp.bodyBytes);
    if (jsonOut){
      var json2 = StrUt.toJson(str, showLog:false); //return null when failed.
      var error = (json2 == null)
        ? _strToMsg(str)        //remove pre error 
        : _resultToMsg(json2);  //get result error msg
      if (error != ''){
        ToolUt.msg(context, error);
        return;
      }

      if (fnOk != null) fnOk(json2);
    } else {
      if (fnOk != null) fnOk(str);
    }

    /*
    //callback
    if (fnOk != null){
      fnOk(jsonOut ? json2 : str);
    }
    */
  }

  ///result to error msg
  static String _resultToMsg(dynamic result){
    return (result['ErrorMsg'] == null)
        ? '' : _strToMsg(result['ErrorMsg']);
  }

  ///string to error msg
  static String _strToMsg(String str){
      return StrUt.isEmpty(str) ? '' :
        (str.substring(0, 2) == FunUt.preError) ? str.substring(2) :
        '';
  }

  /*
  //get public ip address
  static Future<String> getIp() async {
    if (isDev)
      return ':::1';

    var uri = Uri.https('api.ipify.org', '');
    var response = await http.get(uri);
    return (response.statusCode == 200)
        ? response.body
        : '';
  }
  */

} //class
