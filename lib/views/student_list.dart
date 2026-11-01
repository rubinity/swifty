import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swifty/utils/utils.dart';
import '../utils/widgets.dart';
import '../services/api.dart';
import '../services/prefs.dart';
import 'package:swifty/common/constants.dart';
import "../common/exceptions.dart";
import 'package:easy_debounce/easy_debounce.dart';

class StudentList extends StatefulWidget{
  const StudentList({super.key, required this.api});
  final Api42 api;
  @override
  State<StudentList> createState() => _StudentList();
}

class _StudentList extends State<StudentList>{

  List<dynamic> _students = [];
  final _formKey = GlobalKey<FormState>();
  bool currentTrim = false;
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
  final Map<String, String> _params = {"page": "1", "per_page": defaultPerPage.toString() };
  final List<bool> _expandedFilter = [false];
  final Map<String, dynamic> _p = {"top": 1, "bottom": 1, "top_trimmed":false, "bottom_trimmed": false, "per_page": defaultPerPage};
  String _validationMsg = "";

  Future<void> _getStudent(int id) async {
    try {
      _curStudent = await _api.fetchStudent(id);
      if (_api.getStatusCode() != 200) {
        popErr("Could not get student data, please check your credentials or restart the app later. ${_api
                .getErrorMsg()}");
        return;
      }
    }
    catch(e){
    if (e == NoCredsException) {
      // print("no creds is caught");
      dynamic result = await Navigator.pushNamed(context, "/auth");
      return;
    }
    else {
      popErr(
      "Could not get the student data, please check your credentials or restart the app later. ${_api
      .getErrorMsg()}");
      return;
    }}
  }
  
  void _openStudent(int id) async{
    if (ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    await _getStudent(id);
    if (ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    Navigator.pushNamed(context, "/student", arguments: {'data': _curStudent , 'api': _api});
  }

  void clearPagination(){
    _p["top"] = 1;
    _p["bottom"] = 1;
    _p["top_trimmed"] = false;
    _p["bottom_trimmed"] = false;
    _p["per_page"] = defaultPerPage;
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
      pP = _p["per_page"];
    else
      pP = int.parse(perPage);
    if (type == "next") {
      _p["top"] = _p["bottom"];
      _api.updateLink("prev", (_p["top"] - 1).toString());
      _p["top_trimmed"] = true;
      currentTrim = true;
    }
    else if (type == "prev") {
      int end = _students.length;
      if (_tail > 0) {
        pP = _tail;
        _tail = 0;
      }
      _students.removeRange(end - pP, end);
      _api.updateLink("next", _p["bottom"].toString());
      _p["bottom"] -= 1;//todo don't forget to fill this field
      _p["bottom_trimmed"] = true;
    }

  }

  void _search(String value) {
    if (value.isNotEmpty) {
        _isSearch = true;
      _params["range_login"] = value;
      _getList("current", _params);
    }
    else {
      _isSearch = false;
      _params.remove("range_login");
      setState(() {
        _students = [];
      });
    }
  }

  void popErr(String text, [int duration = 60]){
    bool showIcon = false;
    if (duration > 3)
      showIcon = true;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      showCloseIcon: showIcon, duration: Duration(seconds: duration),content: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(text, style: TextStyle(color: Colors.black, height: 1.0))),
      padding: EdgeInsets.all(0), backgroundColor: turquoise, ));
  }


  Future<void> _getList(String type, Map<String,String> params) async{
   if (_loading)
     return;

    try { await getCampuses();
     try {
       await _fetchList(type, params);
       if (_api.getStatusCode() != 200) {
         popErr(
             "Could not get student list, please check your credentials or restart the app later. ${_api
                 .getErrorMsg()}");
         return;
       }

     }
     catch (e) {
       if (e is NoScrollException) // TODO: for testing
           {
         if (e.type == "next") {
           _p["bottom_trimmed"] = false;
         }
       }
       else if (e == NoCredsException) {
         await Navigator.pushNamed(context, "/auth");
         await _fetchList(type, params);
       }
       else {

       }
     }
   if (!mounted)
     return;
   setState(() {
     if (_jumpNeeded) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (_controller.hasClients) {
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
      _p["top"] = int.parse(params["page"]!);
      _p["bottom"] = int.parse(params["page"]!);
      _p["per_page"] = getPerPage(params["per_page"]);
      _p["top_trimmed"] = false;
      _p["bottom_trimmed"] = false;
    }
    else if (type == "next"){
      _p["bottom"] += 1;
    }
    else {
      _p["top"] -= 1;
    }
  }

  bool isTop(){
    return(_p["top_trimmed"]);
  }

  bool isBottom(){
    return(_p["top_trimmed"]);
  }

  Future<void> _fetchList(String type, Map<String,String> params) async{
    int length = _students.length;
    bool _nextTrimInProgress = false;
    if (type == "current") {
      _tail = 0;
      _api.clearLinks();//todo add jump
  }
    _loading = true;
    var new_students = (await _api.fetchStudents(type, _campus, params: params));//later it might be better to use a variable instead of current
    if (new_students.length < _p["per_page"] && _api.isLastPage())
      _tail = new_students.length ;
    if (type == "current") {
      _students = new_students;
      _controllerJump = 0;
      _controllerOffset = 0;
      _jumpNeeded = true;
    }
    else if(type == "next") {
      if ((length + new_students.length) > maxItems) {
        _nextTrimInProgress = true;
        _jumpNeeded = true;
        _students = new_students;
        _controllerJump = 0;
        _controllerOffset = 0;
      }
      else
        _students.addAll(new_students);
      _p["bottom_trimmed"] = false;
    }
    else {
      _students.insertAll(0, new_students);
      _p["top_trimmed"] = false;
        _jumpNeeded = true;
        _controllerJump = new_students.length * 36;
        _controllerOffset = _controller.position.pixels;
    }
    updatePagination(type, params);
    length = _students.length;
    if (length > maxItems || _nextTrimInProgress == true) {
      studentsTrim(type, params["per_page"]);
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
    if (_campusList.isNotEmpty && _campusList.length > 1)
      return;
    try {
        _campusList = await Prefs.loadCampuses();
      if (_campusList.isEmpty || _campusList.length == 1 ) {
        _campusList = await fetchCampuses();
      }
      if (_campusList.isEmpty || _campusList.length == 1) {
          popErr("Could not get campus list, please check your credentials or restart the app later. ${_api.getErrorMsg()}");
          return;
      }
      await Prefs.saveCampuses(_campusList);
    }
    catch(e){
      if (e == NoCredsException) {
        // print("caught no creds");
        dynamic result = await Navigator.pushNamed(context, "/auth");
        _campusList = await fetchCampuses();
        await Prefs.saveCampuses(_campusList);
      }
    }
  }

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
    super.initState();
    _api = widget.api;
    _students = [];
    Prefs.loadPrefs(_expandedFilter);
    _getList("current", _params);
  }

  @override
  void dispose() {
    Prefs.savePrefs(_expandedFilter[0]);
    _controller.dispose();
    super.dispose();
  }

  void clearFilters(){
    _params.remove("pool_year");
    _params.remove("pool_month");
    _params["page"] = "1";
    _params["per_page"] = defaultPerPage.toString();
    _yearController.clear();
    _yearController.text = "all";
  }

  Future<void> refresh() async {
    _getList("current", _params);
  }

  void _valMsgUpdate(String msg) {
      _validationMsg += " $msg";
  }

  @override
  Widget build(BuildContext context) {
    if (_campusList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: Column(
        children: [
        Form(
          key: _formKey,
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
                ),
                textStyle: TextStyle(fontSize: 18, height: 1.0),
                onSelected: (value){ _campus = value!; print(_campus);},
            ),

                FilledButton(
                    onPressed: (){
                      setState(() {
                        _validationMsg = "";
                      });
                     if (_formKey.currentState!.validate()) {
                       _formKey.currentState!.save();
                       _getList("current", _params);
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
                      onSaved: (value){
                      if (_yearController.text == "all")
                        _params.remove("pool_year");
                      else
                        _params["pool_year"] = _yearController.text;
                      },
                    )),
                    const SizedBox(width: 4,),
                    Expanded(child: DropdownMenuFormField<String>(dropdownMenuEntries: monthMenu(),
                      label: Text("Pool month"),
                      textStyle: TextStyle(height: 1.0, fontSize: 18),
                      initialSelection: "all",
                      onSelected: (value){
                        if (value == "all")
                          _params.remove("pool_month");
                        else
                          _params["pool_month"] = value!;},
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
                          errorStyle: TextStyle(height: 0, fontSize: 0),
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
                            _params["page"] = value!;
                          },
                      )),
                      const SizedBox(width: 20,),
                      Expanded(child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(height: 1.0, fontSize: 18),
                        decoration: InputDecoration(
                          constraints: const BoxConstraints(maxHeight: 40, ) ,
                          labelText: "Items per page", border: OutlineInputBorder(),
                          labelStyle: TextStyle(height: 1.0, fontSize: 16),
                          errorStyle: TextStyle(height: 0, fontSize: 0),
                        ),
                        onSaved: (value){
                            _params["per_page"] = value!;},
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
                      }}
                        return null;
                      },
                      )),
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
                          errorStyle: TextStyle(height: 0, fontSize: 0),
                        ),
                        onChanged: (value){EasyDebounce.debounce("search", Duration(milliseconds: 500), ()=>_search(value));
                        }

                      )
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(onPressed: (){
                            clearFilters();
                            _formKey.currentState!.reset();
                        }, child: Text("Clear filters"),
                        ),
                      )
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
                if (n is ScrollStartNotification)
                  _dragTriggered = true;//drag started so true
                final atBottom = n.metrics.extentAfter < 1; // 0 when content is short
                final atTop = n.metrics.extentBefore < 1;
                if (_dragTriggered) {
                  if ((n is OverscrollNotification && atBottom && n.overscroll > 0 )||(n is ScrollUpdateNotification && atBottom && n.scrollDelta! > 0)) {
                    if (!_jumpNeeded) {
                      // print("next is triggered");
                      if (n is ScrollUpdateNotification)
                      _dragTriggered = false;
                      _getList("next", _params);
                    }
                  }
                  else if ((n is OverscrollNotification && atTop && n.overscroll < 0 )||(n is ScrollUpdateNotification && atTop && n.scrollDelta! < 0)){
                    _dragTriggered = false;
                  // print("prev is triggered");
                    _getList("prev", _params);
                  }
                }
                return false;
              },

              child: Scrollbar(
                controller: _controller,
                thumbVisibility: true,
                child: (
                 ListView.builder(
                   physics: AlwaysScrollableScrollPhysics(),
                   controller: _controller,
                   itemCount: (_isSearch && _students.isEmpty) ? _students.length + 1 : _students.length,
                     itemBuilder: (context, index) {
                       final textTheme = Theme.of(context).textTheme;
                     if (_isSearch && _students.isEmpty && index == _students.length){
                       _isSearch = false;
                      return Container(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Login not found", style: TextStyle(fontSize: 18),),);
                     }
                     else {
                       return (Card(margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                           child: ListTile(
                             leading: SizedBox(width: 25,
                                 child: _api.getImage(
                                     _students[index], "micro")),
                             title: Text(_students[index]["login"]),
                             titleTextStyle: textTheme.titleMedium?.copyWith(
                                 fontSize: 16,
                                 height: 1.0,
                                 fontWeight: FontWeight.bold),
                             onTap: () => {
                               _openStudent(_students[index]["id"]),
                             },
                             minTileHeight: 28,
                             minVerticalPadding: 2,
                             tileColor: turquoise,
                           )));
                     }
                     })),
              ),
            ),
          ),
        ],
      ),
    );
  }

}