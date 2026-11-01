import 'package:swifty/services/oauth.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:swifty/common/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:swifty/utils/urls.dart';
import 'package:swifty/utils/network.dart';

class Api42{

  Api42({required this._authService});

  final AuthService _authService;
  Map<String,String> _links = {"first":"", "prev" : "", "next" : "", "last": ""};
  Map<String, dynamic> _student = {};
  String _errorMsg = "";
  int? _statusCode;
  int? _tokenStatus;

  int? getStatusCode(){return _statusCode;}
  String getErrorMsg(){return _errorMsg;}
  void clearLinks() {
    _links = {"first":"", "prev" : "", "next" : "", "last": ""};
  }

  bool linkExists(String type){
    if (_links[type] != "")
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
    if (type == "current") {
      if (campusId != -1)
        url = "https://api.intra.42.fr/v2/campus/${campusId.toString()}/users";
      if (params != {})
        url = buildUrl(url, params);
    }
    else if (linkExists(type)) {
      url = _links[type]!;
    }
    else {
      throw NoScrollException(type);
    }
    // print("url $url");
    List<dynamic> students = await _fetchData(url, type);//TODO error handling
    return students;
  }

  void updateLink(String type, String page){
    String url = "";
    for (String value in _links.values){
      if (value.isNotEmpty){
        url = value;
        break;
      }
    }
    List l = getPageFromUrl(url);
    String newUrl = replacePage(url, page, l[1], l[2]);
    _links[type] = newUrl;
    // print("link updated after trimming: $type - $newUrl");
  }

  Future<List<dynamic>> fetchCampuses() async {
    String url = "https://api.intra.42.fr/v2/campus?per_page=100";
    List<dynamic> campuses = await _fetchData(url, null);//TODO error handling
    return campuses;
  }

  Future<Map<String, dynamic>> fetchStudent(int id) async {
    String url = addToUrl('https://api.intra.42.fr/v2/users', '', id);
    final student = await _fetchData(url, null); //TODO error handling
    if (student == [])
      return {};
    return student;
  }



//gets any data
  Future<dynamic> _fetchData(String urlString, String? getLink) async {
    String? link = "";
    String token;
    Response resp;

    //getting token
    _tokenStatus = await _authService.loadTokenData();
    if (_tokenStatus != 200)
      return [];
    token = _authService.getToken();
    try
    {
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
      if (_statusCode != 200) {
        _errorMsg = resp.headers["status"]!;
        print("error: ${_errorMsg}");
        return [];
      }
      dynamic data = json.decode(resp.body);
      link = resp.headers["link"];
      if (getLink != null && link != null) {
        parseHeaders(link, getLink, _links);
        // print("scroll type $getLink");
        // print("raw links: $link");
        // print("links: $_links");
      }
      return data;
    }
    catch(e)
    {
      _statusCode = 0;
      return [];
    }
    // print("resp ${resp.body.toString()}");
  }

  Image getImage(data, type, {double width = 0, double height = 0}){
    String? url = data["image"]["versions"][type];
    if (url != null){
        Image image = fetchNetImage(url, width: width, height: height);
        return image;
    }
    return Image(image: AssetImage("assets/42.jpg") , width: 25, height: 25,);
  }

  Image fetchNetImage(String url, {double width = 0, double height = 0}){
    var token = _authService.getToken();
    Image image;
    if (width == 0){
      image = Image.network(url, headers: {"Authorization": "Bearer $token"},
        errorBuilder: (context, error, stackTrace){
        return Image(image: AssetImage("assets/42.jpg") , width: 25, height: 25,);
        },
      ) ;
    }
    else {
      image = Image.network(url, headers: {"Authorization": "Bearer $token"}, width: width, height: height,
        errorBuilder: (context, error, stackTrace){
        return Image(image: AssetImage("assets/42.jpg") , width: 25, height: 25,);
        },
      );}
    return image;
  }

String getErrorStatus() {
    return _errorMsg;
  }
}


