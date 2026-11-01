import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:swifty/common/exceptions.dart';
import 'dart:convert';
import 'package:swifty/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package: path/parth.dart';
//
// import 'package:oauth2/oauth2.dart' as oauth2;
//
// class OAuth{
//
// }



class AuthService {
  AuthService({this.authorized = false});

  Map<String, dynamic> _tokenData = {};
  bool authorized;
  static const _storage = FlutterSecureStorage();

  // final appPath = "";

  // String clientId = "";
  // const String.fromEnvironment("CLIENT_ID");
  // String clientSecret = "";
  // const String.fromEnvironment("CLIENT_SECRET");
  // String appPath;
  // late final dirPath = appPath + "/appdata";
  // late final filePath = appPath + "/appdata/test.json";



//   Map<String, dynamic> getTokenData(){
//     return tokenData;
// }

  String getToken(){
    if (_tokenData.containsKey("access_token"))
        return _tokenData["access_token"];
    return "";
  }


  Future<int> _fetchToken(String clientId, String clientSecret) async{
    // List<String> creds = await _loadCreds();
    // print("creds $creds");
    try {
      final resp = await post(Uri.parse('https://api.intra.42.fr/oauth/token'),
          body: {
            "grant_type": "client_credentials",
            "client_id": clientId,
            "client_secret": clientSecret
          });
      print(resp.statusCode);
      if (resp.statusCode == 200) {
        _tokenData = jsonDecode(resp.body);
        _tokenData["received_at"] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        print("token data after fetching $_tokenData");
        await storeToken(jsonEncode(_tokenData));
      }
      return resp.statusCode;
      print(resp.body);
      print(resp.statusCode);
    }
    catch(e)
    {
      return 0;
    }

    print('token fetched');
    print(_tokenData.runtimeType);
    print(_tokenData["access_token"]);
    // var createdAt = tokenData["created_at"];
    // dummy value while internet outage
    // print("testing token string: ${tokenData}");

    // await readToken();

  }

  Future <void> storeCredentials(String clientId, String clientSecret) async{
    await _storage.write(key: "id", value: clientId);
    await _storage.write(key: "secret", value: clientSecret);
  }

  Future <void> clearCredentials() async{
    await _storage.delete(key: "id");
    await _storage.delete(key: "secret");
  }

  Future <void> clearToken() async{
    _tokenData = {};
    await _storage.delete(key: "tokenData");
  }

  Future <List<String>> readCredentials() async{
    String? id = await _storage.read(key: "id");
    String? secret = await _storage.read(key: "secret");
    if (id != null && secret != null)
      return [id, secret];
    return[];
  }

  // Future<void> storeData(String key, String value) async{
  //   await _storage.write(key: key, value: value);
  // }
  //
  // Future<String?> readData(String key) async{
  //   return await _storage.read(key: "data");
  // }
  //
  Future<void> storeToken(String data) async{
    // TODO: add error handling

    await _storage.write(key: "tokenData", value: data);
    // getApplicationDocumentsDirectory();
    // for checking files from console: db shell  run-as com.github.rubinity.swifty ls code_cache/appdata
    // Directory appDir = await getApplicationDocumentsDirectory();
    // String dirPath = appDir.path + "/appdata";
    // filePath = Directory.systemTemp.path + "/appdata/test.json";
  //   print("dir ${appPath}");
  //
  //   final dir = Directory(dirPath);
  //   await dir.create(recursive: true);
  //   final file = File(filePath);
  //   print("testing json string");
  //   print(data);
  //   file.writeAsString(data);
  }

  // Future<void> storeTest(String data) async{
  //   // TODO: change to secure storage
  // _secureStorage.saveData(data);
  // }

  // Future<void> extractTest() async{
  //   // TODO: change to secure storage
  //   String? data = await _secureStorage.getData();
  //   print("data: $data");
  // }

  Future<Map<String, dynamic>> readToken() async{
    // TODO: add error handling
    try {
      String? rawData = await _storage.read(key: "tokenData");
      if (rawData == null) {
        throw Exception("token data null");
      }
    final data = jsonDecode(rawData!);
      print("text after extraction $data");
    DateTime createdAt = DateTime.fromMicrosecondsSinceEpoch(data["created_at"] * 1000);
    // print(data["access_token"]);
    print("created at: ${createdAt.toString()}");
    return data;
    }
    catch(e){
      print("error in read $e");
      return {};
    }
  }

  // String expiresAt(){
  //
  // }

  bool tokenExpired(Map<String, dynamic> data){
    DateTime receivedAt = DateTime.fromMillisecondsSinceEpoch(data["received_at"] * 1000);
    DateTime expiresAt = receivedAt.add(Duration(seconds: data["expires_in"]));
    print("token created at ${receivedAt.toString()}");
    expiresAt = expiresAt.subtract(Duration(minutes: 1));
    print("token data ${data}");
    print("token expires at ${expiresAt.toString()}");
    DateTime now = DateTime.now();
    print("now is ${now.toString()}");
    return (now.isAfter(expiresAt));
  }

  Future<List<String>> _readCreds() async{
    List<String> creds = await readCredentials();
    if (creds.isEmpty) {
      print("throwing");
      throw NoCredsException;
    }
    // creds = [
    //   const String.fromEnvironment("CLIENT_ID"),
    //   const String.fromEnvironment("CLIENT_SECRET")
    // ];
    // await storeCredentials(creds[0], creds[1]);
    return creds;
  }

  Future<int> authenticate(String clientId, String clientSecret) async {
    int status = await _fetchToken(clientId, clientSecret);
    if (status == 200)
      await storeCredentials(clientId, clientSecret);
   print("id $clientId");
   print("secret $clientSecret");
   return status;
  }

  Future<int> loadTokenData() async {
    int status = 200;
    if (_tokenData.isEmpty){
      _tokenData = await readToken();
    }
    if (_tokenData.isEmpty || tokenExpired(_tokenData)){
      print("getting token from API");
      List<String> creds = await _readCreds();
      status = await _fetchToken(creds[0], creds[1]);
      if (status == 429){
        await Future.delayed(Duration(seconds: 1));
        status = await _fetchToken(creds[0], creds[1]);
      }
    }
    print("token data is: ${_tokenData}");
    return status;
  }

  bool getAuthorized()
  {
    return this.authorized;
  }

}

