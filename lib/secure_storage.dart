import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage{
  static const _storage = FlutterSecureStorage();

  Future<void> saveData(String data) async{
  await _storage.write(key: "data", value: data);
  }

  Future<String?> getData() async{
    return await _storage.read(key: "data");
  }

}