import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'student.dart';
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
  const StudentList({super.key, required this.authService});
  final AuthService authService;

  @override
  State<StudentList> createState() => _StudentList();

}

class _StudentList extends State<StudentList>{

  // Api42 api;
  // while no access
  var stuList;
  var students = [];
  late AuthService authService;
  late Api42 api;


  List<Student> dummy = [
    Student(first_name: 'John', last_name: 'Doe'),
    Student(first_name: 'Alice', last_name: 'Smith'),
    Student(first_name: 'Michael', last_name: 'Brown'),
    Student(first_name: 'Nick', last_name: 'Jones'),
    Student(first_name: 'Jake', last_name: 'Anderson'),
    Student(first_name: 'Anna', last_name: 'Johnson'),
  ];

  void getList() async{
    // Api42 api = Api42();
    try {
      await api.getData();
    }
    catch(e){
      print("error:");
      print(e);
      return;
    }
    // stuList = api.students;

    // students = jsonEncode(stuList);
    // print("list: ${stuList[0]}");
    if (!mounted)
      return;

    setState(() {
      print("setting state");
      students = api.students;
      print(api.students[0]);
    });
    // print(students.toString());
  }


  @override
  void initState() {
    // TODO: implement initState
    print("initiating state");
    super.initState();
    authService = widget.authService;
    api = Api42(authService: authService);
    print("starting getting the list");
    getList();

    // print("list ${stuList[0]}");

    // api.
  }
  
  Image getImage(data){
    var url = data["image"]["versions"]["micro"];
    if (url != null)
      return Image.network(url, width: 24, height: 24);
    return Image(image: AssetImage("assets/42.jpg") , width: 24, height: 24,);
  }

  @override
  Widget build(BuildContext context) {

    // final screenWidth = MediaQuery.of(context).size.width;
    // final padWidth = screenWidth * 0.01;
    // print(["screen1", screenWidth]);
    return (
     ListView(
    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
     children: [

        ... students.map((student)
         => GestureDetector(
           onTap: ()=>{print(student["last_name"]),},
           child: Container(
               color: Color(0xFF00babc),
               margin: EdgeInsets.all(4),
               padding: EdgeInsets.fromLTRB(12, 2, 12, 2),
           //     // constraints: BoxConstraints.loose(Size.fromHeight(100)) ,
               child: Row(
                 children: [
                   Column(
                     children: [
                       getImage(student)
                     ],
                   ),
                   Column(
                     children: [
                   Row(
                     children: [
                       SizedBox(width: 10),
                       Text(overflow: null, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.start, student["login"]
                       ),
                     ],
                   ),
                   // Row(
                   //   mainAxisAlignment: MainAxisAlignment.start,
                   //   children: [
                   //     SizedBox(width: 10),
                   //     Text(style: TextStyle(fontSize: 10, color: Colors.white), textAlign: TextAlign.start, student["displayname"]
                   //     ),
                   //   ],
                   // ),
                     ]
                   )
                 ],
               )
           ),
         )
         ),
       ],
     )


    );
  }

}