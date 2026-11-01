import 'package:swifty/services/oauth.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:swifty/common/exceptions.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:swifty/utils/utils.dart';
import 'package:swifty/utils/urls.dart';
import 'package:swifty/utils/network.dart';
import 'package:swifty/common/constants.dart';

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
  dynamic students = [];
  Map<String,String> links = {"first":"", "prev" : "", "next" : "", "last": ""};
  dynamic test = [];
  Map<String, dynamic> student = {};
  String _errorMsg = "";
  int? _statusCode;
  int? _tokenStatus;

  int? getStatusCode(){return _statusCode;}
  String getErrorMsg(){return _errorMsg;}
  void clearLinks() {
    links = {"first":"", "prev" : "", "next" : "", "last": ""};
  }

  bool linkExists(String type){
    if (links[type] != "")
      return true;
    return false;
  }

  bool isLastPage() {
    return (!linkExists("last"));
  }

  bool isFirstPage() {
    return (!linkExists("first"));
  }


  Future<List<dynamic>> fetchStudents(String type, int campusId, { Map<String, String> params = const {} }) async {
    String url = "https://api.intra.42.fr/v2/users";
    print("fetchStudents links $links, $type");
    // print("links exist ${linkExists(type)}");
    if (type == "current") {
      if (campusId != -1)
        url = "https://api.intra.42.fr/v2/campus/${campusId.toString()}/users";
      if (params != {})
        url = buildUrl(url, params);
    }
    else if (linkExists(type)) {
      url = links[type]!;
      print("fetchStudents url $url");
    }
    else {
      throw NoScrollException(type);
    }

    print("url $url");
    print("we got students");
    List<dynamic> students = await _fetchData(url, type);//TODO error handling
    return students;
    // print("students in api ${students.toString()}");
  }

  void updateLink(String type, String page){
    print("trying to trim $page");
    String url = "";
    for (String value in links.values){
      if (value.isNotEmpty){
        url = value;
        break;
      }
    }
    // if (type == "next") {
    //   url = links["last"]!;
    //   print(url);
    // }
    // else
    //   url = links["first"]!;
    List l = getPageFromUrl(url);
    String newUrl = replacePage(url, page, l[1], l[2]);
    links[type] = newUrl;
    print("link updated after trimming: $type - $newUrl");
  }

  Future<List<dynamic>> fetchCampuses() async {
    String url = "https://api.intra.42.fr/v2/campus?per_page=100";
    List<dynamic> campuses = await _fetchData(url, null);//TODO error handling
    return campuses;
  }

  // this function is for testing urls - remove at the end
  Future<void> getTest(int id) async {
    // /v2/users/:id/locations_stats
    // String url = addToUrl('https://api.intra.42.fr/v2/users', '/locations_stats', id);
    // String url = addToUrl('https://api.intra.42.fr/v2/cursus', '', id);

    String url = "https://api.intra.42.fr/v2/projects/21";
    // print(url);
    test = await _fetchData(url, null); //TODO error handling
    // print("test: ${test.toString()}");
    test.forEach((entry) => {print('entry: $entry')});
    // print(test.toString());
  }

  Future<Map<String, dynamic>> fetchStudent(int id) async {
    String url = addToUrl('https://api.intra.42.fr/v2/users', '', id);
    // String url = "https://api.intra.42.fr/v2/skills";
    print(url);
    final student = await _fetchData(url, null); //TODO error handling
    print("studenttt $student");
    if (student == [])
      return {};
    return student;
    // print("test: ");
    // print(test.toString());
  }


// getActual
//gets any data
//   Todo: ensure token is active
  Future<dynamic> _fetchData(String urlString, String? getLink) async {
    String? link = "";
    // int status;
    var token;
    Response resp;

    //getting token

    _tokenStatus = await authService.loadTokenData();
    print("token status $_tokenStatus");
    if (_tokenStatus != 200)
      return [];
    token = authService.getToken();
    try
    {
      // if (getLink == null)
      //   token = "";
      //fetching data
      resp = await get(
          Uri.parse(urlString),
          headers: {"Authorization": "Bearer $token"});
      _statusCode = resp.statusCode;
      if (_statusCode == 429) {
        await Future.delayed(Duration(seconds: 1));
        resp = await get(
            Uri.parse(urlString),
            headers: {"Authorization": "Bearer $token"});
      }
      print("status: ${_statusCode}");
      if (_statusCode != 200) {
        _errorMsg = resp.headers["status"]!;
        print("error: ${_errorMsg}");
        // if (_statusCode == 401)
        return [];
      }
      dynamic data = json.decode(resp.body);
      link = resp.headers["link"];
      if (getLink != null && link != null) {
        parseHeaders(link, getLink, links);
        print("scroll type $getLink");
        print("raw links: $link");
        print("links: $links");
      }
      print("we got data");
      return data;
    }
    catch(e)
    {
      print("error");
      return [];
    }
    // print("resp ${resp.body.toString()}");




  }

  // int getStatus(Map<String, String> headers){
  //   String statusString = headers["status"]!.substring(0, 3);
  //   int status = int.parse(statusString) ;
  //   return status;
  // }

  // Future<dynamic> getStats(id) async{
  //
  // }
  Image getImage(data, type, {double width = 0, double height = 0}){
    //Todo simplify images, wrap in a box
    // print("type: $type");
    // print("type: : ${data["image"]["versions"]}");
    var url = data["image"]["versions"][type];
    if (url != null){
      // print("test image");
        var image = fetchNetImage(url, width: width, height: height);
        return image;

    }
    return Image(image: AssetImage("assets/42.jpg") , width: 25, height: 25,);
  }

  Image fetchNetImage(String url, {double width = 0, double height = 0}){
    var token = authService.getToken();
    Image image;
    if (width == 0){
      image = Image.network(url, headers: {"Authorization": "Bearer $token"},
        errorBuilder: (context, error, stackTrace){ print("image error $error");
        return Image(image: AssetImage("assets/42.jpg") , width: 25, height: 25,);
        },
      ) ;
      // print()
    }
    else {
      image = Image.network(url, headers: {"Authorization": "Bearer $token"}, width: width, height: height,
        errorBuilder: (context, error, stackTrace){ print("image error $error");
        return Image(image: AssetImage("assets/42.jpg") , width: 25, height: 25,);
        },
      );}
    return image;
  }

String getErrorStatus() {
    return _errorMsg;
  }
}


