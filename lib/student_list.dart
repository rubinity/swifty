import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:swifty/utils/utils.dart';
import 'student.dart';
import 'utils/widgets.dart';
import 'api.dart';
import 'package:swifty/oauth.dart';
import 'package:swifty/utils/time.dart';


// class MyList extends ListView{
//   MyList({super.key});
//
//
//   @override
//   State<MyList> createState() => _MyList();
//
// }




class StudentList extends StatefulWidget{
  const StudentList({super.key, required this.api});
  final Api42 api;
  @override
  State<StudentList> createState() => _StudentList();

}

class _StudentList extends State<StudentList>{

  List<dynamic> _students = [];
  // Map<String, String> links = {};
  Map<String, dynamic> _curStudent = {};
  late Api42 _api;
  final ScrollController _controller = ScrollController();
  int _campus = -1;
  List<dynamic> _campusList = [];

  Future<void> _getStudent(int id) async {
    try {
      _curStudent = await _api.getStudent(id);
    }
    catch(e){
      print("error in student get: $e");
      return;
    }

    if (!mounted)
      return;
  }
  
  void _openStudent(int id) async{
    await _getStudent(id);
    Navigator.pushNamed(context, "/student", arguments: {'data': _curStudent , 'api': _api});
  }

  void _getList(String type) async{
    print("getting list $type");
    try {
      // var params = {"page": "1", "per_page" : "20", "pool_year": "2022", "pool_month" : "june"};
      var new_students = (await _api.getStudents(type, _campus));//later it might be better to use a variable instead of current
      if (type == "current") {
        _students = new_students;
        // print(new_students);
        // print(_students);
      }
      else
        _students.addAll(new_students);
      print("current length ${_students.length}");
    }
    catch(e){
      if (e == "no_scroll") // TODO: for testing
        return
      print("error: $e");
      return;
    }
    if (!mounted)
      return;
    
    setState(() {
      print("setting state");
      // students = api.students;
      // print("students: ${students.toString()}");
    });
  }

  void getCampuses() async{
    _campusList = await _api.getCampuses();
    print("campuses ${_campusList.length}");
  }

  void _onScroll() {
    final position = _controller.position;
    // print("scroll");
    if (position.pixels >= position.maxScrollExtent) {
      print("scroll detected");
      _getList("next");// overscrolled at the bottom (stretched past the end)
      print(_students.length);
    }

    // else if (position.pixels < position.minScrollExtent) {
    //   // overscrolled at the top
    //   _getList("next");
    // }
    // Load the next page when within 200px of the bottom
  }


  @override
  void initState() {
    // TODO: implement initState
    print("initiating state");
    super.initState();
    _controller.addListener(_onScroll);
    _api = widget.api;
    print("starting getting the list");
    _students = [];
    getCampuses();
    _getList("current");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    // final screenWidth = MediaQuery.of(context).size.width;
    // final padWidth = screenWidth * 0.01;
    // print(["screen1", screenWidth]);
    return Column(
      children: [
    Row(
    children: [
    TextButton(onPressed: () => _getList("current"), child: Icon(Icons.refresh_outlined)),
      TextButton(onPressed: () => _api.authService.storeTest("I am data"), child: Text("save data")),
      TextButton(onPressed: () => _api.authService.extractTest(), child: Text("print data")),
    ],),

      Form(child:
      BorderedContainer(
        sideMargin: 0,
        bgColor: Colors.white,
        inside: Column(
            children: [Row(children: [
          Expanded(
            child: DropdownButtonFormField(items: campusMenu(_campusList),
                initialValue: _campus,
                onChanged: (value){ _campus = value!; print(_campus);}),
          ),
              Text("gfdgdfg"),

        ])]

        ),
      )),
        Expanded(
          child: (
           ListView.builder(
             controller: _controller,
             itemCount: _students.length,
               itemBuilder: (context, index) {
                 final textTheme = Theme.of(context).textTheme;
                 return (Card(margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                     child: ListTile(
                       // dense: true,
                       leading: _api.getImage(_students[index], "micro"),
                       title: Text(_students[index]["login"]),
                       // subtitle: Text(students[index]["login"]),
                       titleTextStyle: textTheme.titleMedium?.copyWith(
                           fontSize: 16, height: 1.0, fontWeight: FontWeight.bold),
                       // subtitleTextStyle: textTheme.bodyMedium?.copyWith(height: 1.1),
                       onTap: () => {_openStudent(_students[index]["id"]),},
                       minTileHeight: 28,
                       minVerticalPadding: 2,
                       tileColor: Color(0xFF00babc),

                       // contentPadding: EdgeInsets.all(1),

                     )

                 ));
               })),
        ),
      ],
    );
    // padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
    //  children: [
    //
    //     ... students.map((student)
    //      => GestureDetector(
    //        onTap: ()=>{openStudent(student["id"]),},
    //        child: Container(
    //            color: Color(0xFF00babc),
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