import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'student.dart';
import 'widgets.dart';
import 'api.dart';
import 'package:swifty/oauth.dart';
import 'package:swifty/time.dart';


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

  List<dynamic> students = [];
  Map<String, String> links = {};
  Map<String, dynamic> curStudent = {};
  late Api42 api;

  Future<void> getStudent(int id) async {
    try {
      curStudent = await api.getStudent(id);
    }
    catch(e){
      print("error in student: $e");
      return;
    }

    if (!mounted)
      return;
  }
  
  void openStudent(int id) async{
    await getStudent(id);
    Navigator.pushNamed(context, "/student", arguments: {'data': curStudent , 'api': api});
  }

  void getList() async{
    try {
      var params = {"page": "3", "per_page" : "20", "pool_year": "2022", "pool_month" : "june"};
      students = (await api.getStudents("current", params: params));//later it might be better to use a variable instead of current
    }
    catch(e){
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


  @override
  void initState() {
    // TODO: implement initState
    print("initiating state");
    super.initState();
    api = widget.api;
    print("starting getting the list");
    getList();

    // print("list ${stuList[0]}");

    // api.
  }
  


  @override
  Widget build(BuildContext context) {

    // final screenWidth = MediaQuery.of(context).size.width;
    // final padWidth = screenWidth * 0.01;
    // print(["screen1", screenWidth]);
    return (

     ListView.builder(
       controller: ScrollController(),
       itemCount: students.length + 1,
         itemBuilder: (context, index) {
           final textTheme = Theme.of(context).textTheme;
         if (index == 0)
           {
             return ListTile(
               leading: Icon(Icons.refresh_outlined),
               // title: Text("Home"),
               onTap: () {
                   getList();
               },
               minTileHeight: 10,
             );
           }
         else {
           return (Card(margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
               child: ListTile(
                 // dense: true,
                 leading: api.getImage(students[index - 1], "micro"),
                 title: Text(students[index - 1]["login"]),
                 // subtitle: Text(students[index]["login"]),
                 titleTextStyle: textTheme.titleMedium?.copyWith(
                     fontSize: 16, height: 1.0, fontWeight: FontWeight.bold),
                 // subtitleTextStyle: textTheme.bodyMedium?.copyWith(height: 1.1),
                 onTap: () => {openStudent(students[index - 1]["id"]),},
                 minTileHeight: 28,
                 minVerticalPadding: 2,
                 tileColor: Color(0xFF00babc),

                 // contentPadding: EdgeInsets.all(1),

               )

           ));}
         }));
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