import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
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

  Map<String, dynamic> tokenData = {};
  bool authorized;
  static const _storage = FlutterSecureStorage();

  // final appPath = "";

  // String clientId = "";
  // const String.fromEnvironment("CLIENT_ID");
  // String clientSecret = "";
  // const String.fromEnvironment("CLIENT_SECRET");
  // String appPath;
  late final dirPath = appPath + "/appdata";
  late final filePath = appPath + "/appdata/test.json";



  Map<String, dynamic> getTokenData(){
    return tokenData;
}
  Future<void> getToken() async{
     // print("get t");
     // print(String.fromEnvironment("CLIENT_SECRET"));
    List<String> creds = await readCredentials();
    if (creds.isEmpty)
      creds = [const String.fromEnvironment("CLIENT_ID"), const String.fromEnvironment("CLIENT_SECRET")];//TODO change for auth form
    final resp = await post(Uri.parse('https://api.intra.42.fr/oauth/token'), body: {"grant_type": "client_credentials", "client_id":creds[0], "client_secret": creds[1]});
    // this.authorized = true;
    // print(this.authorized);
    // print(String.fromEnvironment('CLIENT_ID'));
    // var token_string='{"access_token":"385ddc01345b37cbdfcb9fc5102c04ec38253065a64157151d123de6ebc9b4b8","token_type":"bearer","expires_in":7200,"scope":"public","created_at":1790702845,"secret_valid_until":1790786753}';
    // tokenData='{"token": "aaaccc1111", "valid_until": "4352", "created_at" : "354643632"}';
    // tokenData = jsonDecode(token_string);
    tokenData = jsonDecode(resp.body);
    // print(resp.body);
    print('new_token');
    print(tokenData.runtimeType);
    print(tokenData["access_token"]);
    // var createdAt = tokenData["created_at"];
    // dummy value while internet outage
    // print("testing token string: ${tokenData}");
    await storeToken(resp.body);
    // await readToken();

  }

  Future <void> storeCredentials(String clientId, String clientSecret) async{
    await _storage.write(key: "id", value: clientId);
    await _storage.write(key: "secret", value: clientSecret);
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
    // TODO: change to secure storage, add error handling
    try {
    //   print("opening file: ${filePath}");
    //   final file = File(filePath);
    // final text = await file.readAsString();
    //   print("text $text");
      String? rawData = await _storage.read(key: "tokenData");
      if (rawData == null)
        throw Exception("token data null");
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
    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(data["created_at"] * 1000);
    DateTime expiresAt = createdAt.add(Duration(seconds: data["expires_in"]));
    print("token created at ${createdAt.toString()}");
    expiresAt = expiresAt.subtract(Duration(minutes: 1));
    print("data ${data}");
    print("token expires at ${expiresAt.toString()}");
    DateTime now = DateTime.now();
    print("now is ${now.toString()}");
    return (now.isAfter(expiresAt));
  }

  Future<void> Authent() async{

  }

  Future<void> authorize () async {
    if (tokenData.isEmpty){
      tokenData = await readToken();
      print("token data is retrieved from file");
      print(tokenData);
    }
    print("token data is: ${tokenData}");
    if (tokenData.isEmpty || tokenExpired(tokenData)){
      print("getting token from website");
      // print("no token");|| tokenExpired()
      await getToken();
      print("authorization succeeded");
    }
    // print(this.authorized);
    this.authorized = true;
    print("authorized");

  }
  // bool tokenExpired(){
  //   return true;
  // }

  bool getAuthorized()
  {
    return this.authorized;
  }

}

