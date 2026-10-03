import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'dart:convert';
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

  var clientId = const String.fromEnvironment("CLIENT_ID");
  var clientSecret = const String.fromEnvironment("CLIENT_SECRET");
  final dirPath = Directory.systemTemp.path + "/appdata";
  final filePath = Directory.systemTemp.path + "/appdata/test.json";

  Map<String, dynamic> getTokenData(){
    return tokenData;
}
   getToken() async{
     // print("get t");
     // print(String.fromEnvironment("CLIENT_SECRET"));
    final resp = await post(Uri.parse('https://api.intra.42.fr/oauth/token'), body: {"grant_type": "client_credentials", "client_id":clientId, "client_secret": clientSecret });
    // this.authorized = true;
    // print(this.authorized);
    // print(String.fromEnvironment('CLIENT_ID'));
    // var token_string='{"access_token":"385ddc01345b37cbdfcb9fc5102c04ec38253065a64157151d123de6ebc9b4b8","token_type":"bearer","expires_in":7200,"scope":"public","created_at":1790702845,"secret_valid_until":1790786753}';
    // tokenData='{"token": "aaaccc1111", "valid_until": "4352", "created_at" : "354643632"}';
    // tokenData = jsonDecode(token_string);
    tokenData = jsonDecode(resp.body);
    print('new_token');
    print(tokenData.runtimeType);
    print(tokenData["access_token"]);
    // var createdAt = tokenData["created_at"];
    // dummy value while internet outage
    print("string: ${tokenData.toString()}");
    storeToken(tokenData.toString());
    // readToken();

  }
  
  void storeToken(String data) async{
    // TODO: change to secure storage
    // for checking files from console: db shell  run-as com.github.rubinity.swifty ls code_cache/appdata
    final dir = Directory(dirPath);
    await dir.create(recursive: true);
    final file = File(filePath);
    // print(filePath);
    // print(data);
    file.writeAsString(data);
  }
  
  void readToken() async{
    // TODO: change to secure storage, add error handling
    final file = File(filePath);
    final text = await file.readAsString();
    final data = jsonDecode(text);
    // print(data["access_token"]);
  }
  
  bool tokenExpired(){
     return true;
  }
  

  Future<void> authorize () async {
    if (tokenData == null || tokenExpired()){
      // print("no token");
      await getToken();
      print("authorization succeeded");
    }
    // print(this.authorized);
    this.authorized = true;
    print("authorized");

  }

  bool getAuthorized()
  {
    return this.authorized;
  }

}

