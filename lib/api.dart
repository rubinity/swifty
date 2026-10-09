import 'package:swifty/oauth.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/services.dart' show rootBundle;

// Future<Map<String, dynamic>> loadJson() async {
//   final text = await rootBundle.loadString('assets/test.json');
//   return jsonDecode(text) as Map<String, dynamic>;
// }
// import 'package:json_annotation/json_annotation.dart';
// Future<String> getText() async {
//   final file = await rootBundle.loadString('lib/text.txt');
//   return file;
// }
// final file = File('lib/text.txt');
// final content = '[{"id":275158,"email":"htest@student.42heilbronn.de","login":"htest","first_name":"Hn","last_name":"Test67","usual_full_name":"Hn Test67","usual_first_name":"Hn","url":"https://api.intra.42.fr/v2/users/htest","phone":"hidden","displayname":"Hn Test67","kind":"student","image":{"link":null,"versions":{"large":null,"medium":null,"small":null,"micro":null}},"staff?":false,"correction_point":5,"pool_month":"august","pool_year":"2026","location":null,"wallet":5,"anonymize_date":"2029-09-01T00:00:00.000+02:00","data_erasure_date":"2029-09-01T00:00:00.000+02:00","created_at":"2026-08-31T12:46:49.038Z","updated_at":"2026-09-01T08:24:33.191Z","alumnized_at":null,"alumni?":false,"active?":true},{"id":273930,"email":"bwang@student.42heilbronn.de","login":"bwang","first_name":"Bingxuan","last_name":"Wang","usual_full_name":"Bingxuan Wang","usual_first_name":"Bingxuan","url":"https://api.intra.42.fr/v2/users/bwang","phone":"hidden","displayname":"Bingxuan Wang","kind":"student","image":{"link":"https://cdn.intra.42.fr/users/76a7150efce1eb14d69de9573628d459/bwang.jpg","versions":{"large":"https://cdn.intra.42.fr/users/fc67d394131108bc4453a191ac99871d/large_bwang.jpg","medium":"https://cdn.intra.42.fr/users/cf1510d12d4e40d736f22e335dcc9c9a/medium_bwang.jpg","small":"https://cdn.intra.42.fr/users/f69c0109f1e8e566b2a3566f28caed01/small_bwang.jpg","micro":"https://cdn.intra.42.fr/users/fa3871bf564c638a237bb81b8f591549/micro_bwang.jpg"}},"staff?":false,"correction_point":1,"pool_month":"august","pool_year":"2026","location":null,"wallet":0,"anonymize_date":"2029-09-04T00:00:00.000+02:00","data_erasure_date":"2029-09-04T00:00:00.000+02:00","created_at":"2026-08-12T07:34:34.533Z","updated_at":"2026-09-02T13:55:51.680Z","alumnized_at":null,"alumni?":false,"active?":false},{"id":273886,"email":"hgondali@student.42heilbronn.de","login":"hgondali","first_name":"Hetvi","last_name":"Gondaliya","usual_full_name":"Hetvi Gondaliya","usual_first_name":"Hetvi","url":"https://api.intra.42.fr/v2/users/hgondali","phone":"hidden","displayname":"Hetvi Gondaliya","kind":"student","image":{"link":"https://cdn.intra.42.fr/users/34799d1cd77416f5c1fd52e9762314cf/hgondali.jpg","versions":{"large":"https://cdn.intra.42.fr/users/f7be508cc2a6aca2f6e8b099291a1238/large_hgondali.jpg","medium":"https://cdn.intra.42.fr/users/4e11006bf751fd10619a95d81a1e4cb8/medium_hgondali.jpg","small":"https://cdn.intra.42.fr/users/19adeae4c027b38574d11d22c6f99679/small_hgondali.jpg","micro":"https://cdn.intra.42.fr/users/cc10af17ccda490c2ec7de0f7fe0346b/micro_hgondali.jpg"}},"staff?":false,"correction_point":0,"pool_month":"august","pool_year":"2026","location":null,"wallet":0,"anonymize_date":"2029-08-20T00:00:00.000+02:00","data_erasure_date":"2029-08-20T00:00:00.000+02:00","created_at":"2026-08-10T11:31:34.726Z","updated_at":"2026-08-20T14:36:33.655Z","alumnized_at":null,"alumni?":false,"active?":false}]';
// final students = json.decode(content);
class Api42{

  Api42({required this.authService});

  AuthService authService;
  List<dynamic> students = [];
  String errorStatus = "";


  Future<void> getData() async {
    print("getting data");
    // Map <String, String> map;
    var token = authService.getTokenData()["access_token"];
    if (token == null) {
      await authService.authorize();
      token = authService.getTokenData()["access_token"];
    }
    // var a = token["access_token"];
    print("token ${token}");
    Response resp = await get(
          Uri.parse('https://api.intra.42.fr/v2/campus/39/users?page[size]=20'),
          // 'https://api.intra.42.fr/v2/campus/39/users?page[size]=20'
          headers: {"Authorization": "Bearer $token"});
    // final nString = "4553etewt".substring(0, 3);
    //
    //     print("headers: ${resp.headers}");
          final status = getStatus(resp.headers);

          if (status != 200) {
            errorStatus = resp.headers["status"]!;
          }

          print("status: ${status}");
          students = await json.decode(resp.body);

          print("we got students");
    // HttpHeaders
   // Response resp = await get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));

   // print(students[0]);
   // print(students.runtimeType);
   //

   // print(students[0]);
   //  students = json.decode(content);
  }

  int getStatus(Map<String, String> headers){
    String statusString = headers["status"]!.substring(0, 3);
    int status = int.parse(statusString) ;
    return status;
  }

  String getErrorStatus() {
    return errorStatus;
  }
}

