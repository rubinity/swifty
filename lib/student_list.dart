import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:swifty/utils/utils.dart';
import 'student.dart';
import 'utils/widgets.dart';
import 'api.dart';
import 'prefs.dart';
import 'package:swifty/oauth.dart';
import 'package:swifty/utils/time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swifty/utils/constants.dart';
import "exceptions.dart";
import 'package:easy_debounce/easy_debounce.dart';

const int defaultPerPage = 10;

class StudentList extends StatefulWidget{
  const StudentList({super.key, required this.api});
  final Api42 api;
  @override
  State<StudentList> createState() => _StudentList();

}

class _StudentList extends State<StudentList>{

  List<dynamic> _students = [];
final _formKey = GlobalKey<FormState>();
// String poolYear = "all";
//   String poolMonth = "all";
//   String filterPage = "Page number";
//   String? filterPerPage;
//   String loginSearch = "Login Search";
  // Map<String, String> links = {};
  final GlobalKey _firstTileKey = GlobalKey();
  bool currentTrim = false;
  bool loginNotFound = false;
  bool _isSearch = false;
  double _controllerJump = 0;
  bool _jumpNeeded = false;
  double? _controllerOffset;
  bool _dragTriggered = false;
  Map<String, dynamic> _curStudent = {};
  bool _loading = false;
  int _tail = 0;
  late Api42 _api;
  final ScrollController _controller = ScrollController();
  final TextEditingController _yearController = TextEditingController();
  int _campus = -1;
  List<Map<String, dynamic>> _campusList = [];
  Map<String, String> params = {"page": "1", "per_page": defaultPerPage.toString() };
  // Map<String,String> p = {};
  List<bool> _expandedFilter = [false];
  String _poolYear = "all";
  Map<String, dynamic> p = {"top": 1, "bottom": 1, "top_trimmed":false, "bottom_trimmed": false, "max": 1000, "per_page": defaultPerPage};
  String _validationMsg = "";
  // void saveParams

  Future<void> _getStudent(int id) async {
    _api.getTest(0);
    showSnack(context, "lalalalal", 3);
    try {
      _curStudent = await _api.fetchStudent(id);
    }
    catch(e){
    if (e == NoCredsException)
    {
      print("need to authent");
      dynamic result = await Navigator.pushNamed(context, "/auth");
      print("id ${result["clientId"]}");
      print("secret ${result["clientSecret"]}");
      print("st closed");
      return;
    }
    else
    {
      print("error in student get: $e");
      return;
    }
    }

    if (!mounted)
      return;
  }
  
  void _openStudent(int id) async{
    if (ModalRoute.of(context)?.isCurrent != true) {
      print("double click student");
      return;
    }
    await _getStudent(id);
    if (ModalRoute.of(context)?.isCurrent != true) {
      print("double click after await");
      return;
    }
    Navigator.pushNamed(context, "/student", arguments: {'data': _curStudent , 'api': _api});
  }

  void clearPagination(){
    p["top"] = 1;
    p["bottom"] = 1;
    p["top_trimmed"] = false;
    p["bottom_trimmed"] = false;
    p["per_page"] = defaultPerPage;
  }
//take perPage from params or the default
  int getPerPage(String? perPageParam){
    if (perPageParam == null)
      return defaultPerPage;
    else
      return int.parse(perPageParam);
  }

  void studentsTrim(String type, String? perPage){
    int pP;
    if(perPage == null)
      pP = p["per_page"];
    else
      pP = int.parse(perPage);
    if (type == "next") {
      // _students.removeRange(0, pP);
      p["top"] = p["bottom"];
      print("trying to trim top, current top page: ${p["top"]} ... ${(p["top"] - 1)}");
      _api.updateLink("prev", (p["top"] - 1).toString());
      print("length after trimming ${_students.length}");
      // p["top"] += 1;
      p["top_trimmed"] = true;
      print("trimmed ${p.toString()}");
      // _controllerJump = -pP * 36;
      // _controllerOffset = _controller.offset;
      currentTrim = true;
      // print("compare to trim ${_controller.position.pixels}, ${_controller.offset}");

    }
    else if (type == "prev") {
      int end = _students.length;
      if (_tail > 0) {
        pP = _tail;
        _tail = 0;
      }
      _students.removeRange(end - pP, end);
      print("trying to trim bottom, current bottom page: ${p["bottom"]}");
      _api.updateLink("next", p["bottom"].toString());
      p["bottom"] -= 1;//todo don't forget to fill this field
      p["bottom_trimmed"] = true;
      print("trimmed ${p.toString()}");
    }

  }

  void _search(String value) {
    if (value.isNotEmpty) {
        _isSearch = true;
      params["range_login"] = value;
      _getList("current", params);
    }
    else {
      _isSearch = false;
      params.remove("range_login");
      setState(() {
        _students = [];
      });
    }
  }


  Future<void> _getList(String type, Map<String,String> params) async{
   if (_loading)
     return;

    try { await getCampuses();
     try {
       await _fetchList(type, params);
     }
     catch (e) {
       if (e is NoScrollException) // TODO: for testing
           {
         if (e.type == "next") {
           p["bottom_trimmed"] = false;
         }
       }
       else if (e == NoCredsException) {
         dynamic result = await Navigator.pushNamed(context, "/auth");
         await _fetchList(type, params);
         print("id ${result["clientId"]}");
         print("secret ${result["clientSecret"]}");
         print("list need to authent");
       }
       else {

       }
     }
   if (!mounted)
     return;
   setState(() {
     // if (fullLogin && _students.isEmpty) {
     //   loginNotFound = true;
     //   fullLogin = false;
     // }
     if (_jumpNeeded) {
       // _callbackNeeded = false
       WidgetsBinding.instance.addPostFrameCallback((_) {
         // print("size: ${_firstTileKey.currentContext?.size?.height}");
         if (_controller.hasClients) {
           print("has clients $_controllerOffset");
           print("preparing to jump ${_controllerOffset}");
           _controller.jumpTo(_controllerOffset! + _controllerJump);
           _controllerJump = 0;
           currentTrim = false;
         }
       });
       _jumpNeeded = false;
     }

   });
  }
       finally {
         _loading = false;
       }
    return;
  }

  void updatePagination(String type, Map<String,String> params){
    if (type == "current"){
      p["top"] = int.parse(params["page"]!);
      p["bottom"] = int.parse(params["page"]!);
      p["per_page"] = getPerPage(params["per_page"]);
      p["top_trimmed"] = false;
      p["bottom_trimmed"] = false;
    }
    else if (type == "next"){
      p["bottom"] += 1;
    }
    else {
      p["top"] -= 1;
    }
    print("pagination after update ${p.toString()}");


  }

  bool isTop(){
    return(p["top_trimmed"]);
  }

  bool isBottom(){
    return(p["top_trimmed"]);
  }

  Future<void> _fetchList(String type, Map<String,String> params) async{
    int length = _students.length;
    print("links from api ${_api.links}");
    bool _nextTrimInProgress = false;
    if (type == "current") {
      _tail = 0;
      _api.clearLinks();//todo add jump
  }

    // var params = {"page": "1", "per_page" : "20", "pool_year": "2022", "pool_month" : "june"};
    _loading = true;
    var new_students = (await _api.fetchStudents(type, _campus, params: params));//later it might be better to use a variable instead of current
    print("test");
    if (new_students.length < p["per_page"] && _api.isLastPage())
      _tail = new_students.length ;

    print("checking new students ${new_students.length}");

    if (type == "current") {
      _students = new_students;
      _controllerJump = 0;
      _controllerOffset = 0;
      _jumpNeeded = true;
      print("jump is planned ${_controllerOffset}");
      print("length ${_students.length}");
    }
    else if(type == "next") {
      // print("links after next ${_api.links}");
      // if (_students.length + new_students.length > )
      if ((length + new_students.length) > p["max"]) {
        _nextTrimInProgress = true;
        _jumpNeeded = true;
        _students = new_students;
        _controllerJump = 0;
        _controllerOffset = 0;
        // studentsTrim(type, params["per_page"]);
        // print("links after next ${_api.links}");
      }
      else
        _students.addAll(new_students);
      // if (_api.linkExists(type))
      p["bottom_trimmed"] = false;
    }
    else {
      _students.insertAll(0, new_students);
      //check if the end
      // if (_api.linkExists(type))
      p["top_trimmed"] = false;
        _jumpNeeded = true;
        _controllerJump = new_students.length * 36;
        _controllerOffset = _controller.position.pixels;
        print("compare ${_controller.position.pixels}, ${_controller.offset}");
        // _callbackNeeded = true;

    }

    updatePagination(type, params);
    length = _students.length;
    print("length  ${length}, p max ${p["max"] }");
    if (length > p["max"] || _nextTrimInProgress == true) {

      studentsTrim(type, params["per_page"]);
      print("length after trimming 1 ${_students.length}");
    }

  }

  Future<List<Map<String, dynamic>>> fetchCampuses() async{
    List<dynamic> dList;
    List<Map<String, dynamic>> tempList;
    dList = await _api.fetchCampuses();
    tempList = dList.cast<Map<String, dynamic>>();
    return convertCampusList(tempList);
  }

  Future<void> getCampuses() async{
    try {
      if (_campusList.isEmpty) {
        _campusList = await Prefs.loadCampuses();
      }
      if (_campusList.isEmpty ) {
        _campusList = await fetchCampuses();
        await Prefs.saveCampuses(_campusList);
      }
    }
    catch(e){
      if (e == NoCredsException) {
        dynamic result = await Navigator.pushNamed(context, "/auth");
        _campusList = await fetchCampuses();
        await Prefs.saveCampuses(_campusList);
      }
    }
  }


  // void _onScroll() {
    // final position = _controller.position;
    // print("scroll");
    // if (position.pixels >= position.maxScrollExtent)
    // print("max ${position.maxScrollExtent}");
    // print("off ${_controller.offset}");
    // if (position.maxScrollExtent == _controller.offset)
    // {
      // position.
      // print("scroll detected");
      // _getList("next", params);
      // p["bottom"] += 1;
      // // overscrolled at the bottom (stretched past the end)
      // print(_students.length);
    // }
    // if (position.pixels <= position.minScrollExtent && p["top_trimmed"] == true)
    // if (position.minScrollExtent == _controller.offset)
    // {
      // print("scroll detected");
      // _getList("prev", params);
      // p["top"] -= 1;
  // overscrolled at the bottom (stretched past the end)
  //     print(_students.length);
  //   }
  // }


  List<Map<String, dynamic>> convertCampusList(List<Map<String, dynamic>> list){
    List<Map<String, dynamic>> newList = [{"id": -1, "name": "all"}];
    Map<String, dynamic> newEntry;
    for (var campus in list){
     newEntry = {"id": campus["id"], "name": campus["name"]};
      if (campus["name"] != "Heilbronn") {
        newList.add(newEntry);
      }
      else {
        newList.insert(1, newEntry);
      }
    }
    return newList;
  }

  @override
  void initState() {
    // TODO: implement initState
    print("initiating state");
    print("expanded before $_expandedFilter");
    super.initState();
    // _controller.addListener(_onScroll);
    _api = widget.api;
    print("starting getting the list");
    _students = [];
    Prefs.loadPrefs(_expandedFilter);
    print("expanded after $_expandedFilter");
    // expandedFilter = _api.authService
    print("init params");

    print(params.toString());
    _getList("current", params);



  }

  @override
  void dispose() {
    Prefs.savePrefs(_expandedFilter[0]);
    _controller.dispose();
    print("expanded before close $_expandedFilter");
    super.dispose();
  }

  void clearFilters(){
    // _campus = -1;

    params.remove("pool_year");
    params.remove("pool_month");
    params["page"] = "1";
    params["per_page"] = defaultPerPage.toString();
    // _poolYear = "all";
    _yearController.clear();
    _yearController.text = "all";
    print("controlle after clear ${_yearController.text}");
    print("params ${params}");
    // filterPage = "Page number";
    // filterPerPage = "Filter per page";
    // loginSearch = "Login search";
    print("campus $_campus");
    print("campus ${_yearController.text}");
  }
// @overr

  Future<void> refresh() async {
    print("refreshing $params");
    _getList("current", params);
  }
  void _valMsgUpdate(String msg)
  {
    // if (_validationMsg.isEmpty)
      _validationMsg += " $msg";
  }

  @override
  Widget build(BuildContext context) {
    if (_campusList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // final screenWidth = MediaQuery.of(context).size.width;
    // final padWidth = screenWidth * 0.01;
    // print(["screen1", screenWidth]);
    return RefreshIndicator(
      onRefresh: refresh,
      child: Column(
        children: [
        Form(
          key: _formKey,
          // onChanged: _saveParams(),
            child:
        BorderedContainer(
          sideMargin: 0,
          bgColor: Colors.white,
          child: Column(
              children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween ,children: [
            DropdownMenuFormField(dropdownMenuEntries: campusMenu(_campusList),
                label: Text("Campuses"),
              menuHeight: 450,
                initialSelection: -1,
                inputDecorationTheme: InputDecorationTheme(isDense: true,
                  border: OutlineInputBorder(),
                  constraints: const BoxConstraints(maxHeight: 40), // the key line
                  // suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                ),
                textStyle: TextStyle(fontSize: 18, height: 1.0),
                // itemHeight: 48,
                // style: TextStyle(fontSize: 16, height: 1.0, color: Colors.black ),
                onSelected: (value){ _campus = value!; print(_campus);},
            ),

                FilledButton(
                    onPressed: (){
                      setState(() {
                        _validationMsg = "";
                      });
                     if (_formKey.currentState!.validate()) {
                       _formKey.currentState!.save();
                       print("params ${params.toString()}");
                       _getList("current", params);
                     }
                      },
                    child: Text("Go", style: TextStyle(color: Colors.black, fontSize: 18),),
                ),
                Checkbox(value: _expandedFilter[0], checkColor: Colors.black, activeColor: Colors.white ,
                    fillColor: WidgetStatePropertyAll(Colors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                    onChanged: (value){setState(() {
                  if (value != null)
                    _expandedFilter[0] = value;
                  else
                    _expandedFilter[0] = false;
                  Prefs.savePrefs(_expandedFilter[0]);
                });})
                // Forms

          ]),
                const SizedBox(height: 4,),
                Visibility(
                  maintainState: true,
                  visible: _expandedFilter[0],
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween ,children: [
                    Expanded(child: DropdownMenuFormField<String>(dropdownMenuEntries: yearMenu(),
                      requestFocusOnTap: true, enableFilter: true, initialSelection: "all",
                      menuHeight: 400, label: Text("Pool year"),
                      controller: _yearController,
                      textStyle: TextStyle(height: 1.0, fontSize: 18),
                      validator: (_){
                      var value = _yearController.text.trim();
                      if (value == "all")
                        return null;
                      if (value.isEmpty) {
                        _validationMsg = "Select or enter the value of the pool year.";
                        // showSnack(context, "You must select or enter the value")
                        return "";
                      }
                      else {
                        var val = int.tryParse(value);
                        if (value.length != 4 || val == null || val < 1900 || val > 3000) {
                          _validationMsg = "Pool year should be a 4-digit number.";
                          return "";
                        }
                        return null;
                      }},
                      // onSelected: (value){
                      //   // _yearController. = value!;
                      //   print("selecting pool_year");
                      //   // print("params ${params.toString()}");
                      // if (value == "all")
                      //   params.remove("pool_year");
                      // else
                      //   params["pool_year"] = _yearController.text;
                      // print("params ${params.toString()}");
                      //   print("p year ${_yearController.text}");
                      // },
                      onSaved: (value){
                      if (_yearController.text == "all")
                        params.remove("pool_year");
                      else
                        params["pool_year"] = _yearController.text;
                      // else
                      //   params.remove("pool_year");
                      print("controlle ${_yearController.text}");
                      },
                    )),
                    const SizedBox(width: 4,),
                    Expanded(child: DropdownMenuFormField<String>(dropdownMenuEntries: monthMenu(),
                      label: Text("Pool month"),
                      textStyle: TextStyle(height: 1.0, fontSize: 18),
                      initialSelection: "all",
                      onSelected: (value){
                        if (value == "all")
                          params.remove("pool_month");
                        else
                          params["pool_month"] = value!;},
                      // onSaved: (value){params["pool_month"] = value!;},
                    )),
                  ]),
                ),

                Visibility(
                  visible: _expandedFilter[0],
                  maintainState: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Row(children: [
                      Expanded(child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: "1",
                        style: TextStyle(height: 1.0, fontSize: 18),
                        decoration: InputDecoration(
                          constraints: const BoxConstraints(maxHeight: 40, ) ,
                          labelText: "Page number", border: OutlineInputBorder(),
                          labelStyle: TextStyle(height: 1.0, fontSize: 16),
                        ),
                        validator:(value){
                          if (value == null || value.trim().isEmpty) {
                            _valMsgUpdate("Page number shouldn't be empty.");
                            return "";
                          }
                          else {
                              var val = int.tryParse(value.trim());
                              if (val == null || val < 1 ) {
                                _valMsgUpdate("Page number is an integer starting from 1.");
                                return "";
                              }
                          }
                          return null;
                        },
                        onSaved: (value){
                          // print("vvv ${value!.isEmpty}");
                          // if (value != null && value.isNotEmpty)
                            params["page"] = value!;
                          // else
                          //   params["page"] = "1";
                          },

                        // onChanged: (value){
                        //   // print("page number: ${value}");
                        // },
                        // initialValue: 1,
                      )),
                      const SizedBox(width: 20,),
                      Expanded(child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(height: 1.0, fontSize: 18),
                        decoration: InputDecoration(
                          constraints: const BoxConstraints(maxHeight: 40, ) ,
                          labelText: "Items per page", border: OutlineInputBorder(),
                          labelStyle: TextStyle(height: 1.0, fontSize: 16),
                        ),
                        onSaved: (value){
                            params["per_page"] = value!;},
                        initialValue: defaultPerPage.toString(),
                        validator: (value){
                      if (value == null || value.trim().isEmpty) {
                      _valMsgUpdate("Items per page shouldn't be empty.");
                      return "";
                      }
                      else {
                      var val = int.tryParse(value.trim());
                      if (val == null || val < 1 || val > 100) {
                      _valMsgUpdate("Items per page must be 1 through 100.");
                      return "";
                      }
                      }
                      return null;
                      },
                      )),
                      // Expanded(child: TextField(keyboardType: TextInputType.datetime,)),
                    ]),
                  ),
                ),
                Visibility(
                  maintainState: true,
                  visible: _expandedFilter[0],
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween , children: [
                      Expanded(child: TextFormField(
                        initialValue: null,
                        keyboardType: TextInputType.text,
                        style: TextStyle(height: 1.0, fontSize: 18),
                        decoration: InputDecoration(
                          constraints: const BoxConstraints(maxHeight: 40, maxWidth: 100) ,
                          labelText: "Login search", border: OutlineInputBorder(),
                          labelStyle: TextStyle(height: 1.0, fontSize: 18),
                        ),
                        // onSaved: (value){
                        //
                        //   params["range_login"] = value!;
                        //   },
                        onChanged: (value){EasyDebounce.debounce("search", Duration(milliseconds: 500), ()=>_search(value));

                        }
                      //       (value){
                      //     // if (value.isNotEmpty) {
                      //     //   params["range_login"] = value!;
                      //     //   _getList("current", params);
                      //     // }
                      //     // else {
                      //     //   params.remove("range_login");
                      //     //   setState(() {
                      //     //     _students = [];
                      //     //   });
                      //     // }
                      //     print(value);
                      //
                      //     },
                      //   // initialValue: 1,
                      )
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(onPressed: (){
                            clearFilters();
                            _formKey.currentState!.reset();
                            print("params after reset $params");
                            print("campus $_campus");

                        }, child: Text("Clear filters"),
                        ),
                      )
                      // Expanded(child: TextField(keyboardType: TextInputType.datetime,)),
                    ]),
                  ),
                ),
                Visibility(
                  maintainState: true,
                  visible: _expandedFilter[0],
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween , children: [
                      Expanded(child: Text(_validationMsg,
                          style: TextStyle(height: 1.0, fontSize: 12, color: Colors.red),

                          // onSaved: (value){
                          //
                          //   params["range_login"] = value!;
                          //   },
                          // onChanged:


                      )
                      ),
                    ]),
                  ),
                ),

              ]

          ),
        )),
          Expanded(
            child: NotificationListener<ScrollNotification>(

              onNotification: (n) {
                // print("check jump${_controllerJump!}");
                var delta;
                bool? scrollingUp;
                if (n is ScrollStartNotification)
                  _dragTriggered = true;//drag started so true
                // print("notif ${_dragTriggered}");
                final atBottom = n.metrics.extentAfter < 1; // 0 when content is short
                final atTop = n.metrics.extentBefore < 1;
                final isScrollish = n is ScrollUpdateNotification || n is OverscrollNotification;
                // print("scr ${isScrollish}");
                // if (isScrollish && atBottom && _dragTriggered) {
                //   _dragTriggered = false;
                //   _getList("next", params);
                // }

                if (_dragTriggered) {
                  // print("isscr $isScrollish, atbottom $atBottom");
                  // print("flag $_dragTriggered");

                  if ((n is OverscrollNotification && atBottom && n.overscroll > 0 )||(n is ScrollUpdateNotification && atBottom && n.scrollDelta! > 0)) {
                    if (!_jumpNeeded) {
                        // _controllerJump = getPerPage(params["per_page"]) * -36;
                        // _controllerOffset = n.metrics.pixels;
                        // currentTrim = true;
                        print("cur pos ${n.metrics.pixels}");


                      print("next is triggered");
                      print(params);
                      // print("check jump${_controllerJump!}");
                      if (n is ScrollUpdateNotification)
                        print("delta ${n.scrollDelta!}");
                      _dragTriggered = false;
                      _getList("next", params);
                    }
                  }
                  else if ((n is OverscrollNotification && atTop && n.overscroll < 0 )||(n is ScrollUpdateNotification && atTop && n.scrollDelta! < 0)){
                    // if (currentTrim)
                    _dragTriggered = false;
                  print("prev is triggered");

                    _getList("prev", params);

                  }
                }
                // if (n is OverscrollNotification)
                //   print("notif ${n is OverscrollNotification}");
                return false;
              },

              child: Scrollbar(
                controller: _controller,
                thumbVisibility: true,
                child: (
                 ListView.builder(
                   // itemExtent: 36,
                   physics: AlwaysScrollableScrollPhysics(),
                   controller: _controller,
                   itemCount: (_isSearch && _students.length == 0) ? _students.length + 1 : _students.length,
                     itemBuilder: (context, index) {
                       final textTheme = Theme.of(context).textTheme;
                       print("is full $_isSearch");
                     if (_isSearch && _students.length == 0 && index == _students.length){
                       _isSearch = false;
                      return Container(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Login not found", style: TextStyle(fontSize: 18),),);
                     }
                     else


                       // print("cur index $index");
                          return (Card(margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                           child: ListTile(

                             // dense: true,
                             leading: SizedBox(width: 25, child: _api.getImage(_students[index], "micro")),
                             title: Text(_students[index]["login"]),
                             // subtitle: Text(students[index]["login"]),
                             titleTextStyle: textTheme.titleMedium?.copyWith(
                                 fontSize: 16, height: 1.0, fontWeight: FontWeight.bold),
                             // subtitleTextStyle: textTheme.bodyMedium?.copyWith(height: 1.1),
                             onTap: () => {_openStudent(_students[index]["id"]),},
                             minTileHeight: 28,
                             minVerticalPadding: 2,
                             tileColor: turquoise,

                             // contentPadding: EdgeInsets.all(1),

                           )

                       ));
                     })),
              ),
            ),
          ),
        ],
      ),
    );
    // padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
    //  children: [
    //
    //     ... students.map((student)
    //      => GestureDetector(
    //        onTap: ()=>{openStudent(student["id"]),},
    //        child: Container(
    //            color: turquoise,
    //            margin: EdgeInsets.all(4),
    //            padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
    //        //     // constraints: BoxConstraints.loose(Size.fromHeight(100)) ,
    //            child: Row(
    //              children: [
    //                Column(
    //                  children: [
    //                    api.getImage(student, "micro")
    //                  ],
    //                ),
    //                Column(
    //                  children: [
    //                Row(
    //                  children: [
    //                    SizedBox(width: 10),
    //                    Text(overflow: null, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.start, student["login"]
    //                    ),
    //                  ],
    //                ),
                   // Row(
                   //   mainAxisAlignment: MainAxisAlignment.start,
                   //   children: [
                   //     SizedBox(width: 10),
                   //     Text(style: TextStyle(fontSize: 10, color: Colors.white), textAlign: TextAlign.start, student["displayname"]
                   //     ),
                   //   ],
                   // ),
     //                 ]
     //               )
     //             ],
     //           )
     //       ),
     //     )
     //     ),
     //   ],
     // )


    // );
  }

}