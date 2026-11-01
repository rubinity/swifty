import 'package:http/http.dart';
import 'package:swifty/common/exceptions.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService();

  Map<String, dynamic> _tokenData = {};
  static const _storage = FlutterSecureStorage();

  String getToken(){
    if (_tokenData.containsKey("access_token"))
        return _tokenData["access_token"];
    return "";
  }

  Future<int> _fetchToken(String clientId, String clientSecret) async{
    try {
      final resp = await post(Uri.parse('https://api.intra.42.fr/oauth/token'),
          body: {
            "grant_type": "client_credentials",
            "client_id": clientId,
            "client_secret": clientSecret
          });
      if (resp.statusCode == 200) {
        _tokenData = jsonDecode(resp.body);
        _tokenData["received_at"] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await storeToken(jsonEncode(_tokenData));
      }
      return resp.statusCode;
    }
    catch(e) {
      return 0;
    }
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

  Future<void> storeToken(String data) async{
    await _storage.write(key: "tokenData", value: data);
  }

  Future<Map<String, dynamic>> readToken() async{
    String? rawData = await _storage.read(key: "tokenData");
    if (rawData == null) {
        return {};
      }
    final data = jsonDecode(rawData);
    return data;
  }

  bool tokenExpired(Map<String, dynamic> data){
    DateTime receivedAt = DateTime.fromMillisecondsSinceEpoch(data["received_at"] * 1000);
    DateTime expiresAt = receivedAt.add(Duration(seconds: data["expires_in"]));
    // print("token created at ${receivedAt.toString()}");
    expiresAt = expiresAt.subtract(Duration(minutes: 1));
    // print("token data ${data}");
    // print("token expires at ${expiresAt.toString()}");
    DateTime now = DateTime.now();
    // print("now is ${now.toString()}");
    return (now.isAfter(expiresAt));
  }

  Future<List<String>> _readCreds() async{
    List<String> creds = await readCredentials();
    if (creds.isEmpty) {
      throw NoCredsException;
    }
    return creds;
  }

  Future<int> authenticate(String clientId, String clientSecret) async {
    int status = await _fetchToken(clientId, clientSecret);
    if (status == 200)
      await storeCredentials(clientId, clientSecret);
   return status;
  }

  Future<int> loadTokenData() async {
    int status = 200;
    if (_tokenData.isEmpty){
      _tokenData = await readToken();
    }
    if (_tokenData.isEmpty || tokenExpired(_tokenData)){
      // print("getting token from API");
      List<String> creds = await _readCreds();
      status = await _fetchToken(creds[0], creds[1]);
      if (status == 429){
        await Future.delayed(Duration(seconds: 1));
        status = await _fetchToken(creds[0], creds[1]);
      }
    }
    return status;
  }


}

