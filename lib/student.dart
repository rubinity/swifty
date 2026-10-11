import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:swifty/oauth.dart';
import 'package:swifty/api.dart';
import 'widgets.dart';
// import 'utils.dart' as u;

// class Student {
//
//   Student({required this.first_name, required this.last_name, this.image_path = ""});
//
//   String first_name;
//   String last_name;
//   String image_path;
//
//   setImagePath(String path) {
//     this.image_path = path;
// }
//
// }

class StudentView extends StatefulWidget {
  const StudentView({super.key, required this.authService, required this.api, required this.args});

  final AuthService authService;
  final Api42 api;
  final Map<String, dynamic> args;
  // final String location = "";
  // String data;

  int primaryCampus(List<dynamic> campuses){
    for (var campus in campuses){
      // print("pr ${campus["is_primary"]}");
      if (campus["is_primary"] == true)
        // print("id ${campus["campus_id"].toString()}");
        return campus["campus_id"];
    }
    return 0;
  }

  String getCampus(List<dynamic> campuses, int id){
    for (var campus in campuses){
      if (campus["id"] == id)
        return campus["name"];
    }
    return "";
  }

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  // Object? data = {};
  Map<String, dynamic> data = {};
  var test;
  late Api42 api;
  late AuthService authService;
  late int id;
  late Map<String, dynamic>student = {};
  late String location = "";

  @override
  void initState() {
    // TODO: implement initState
    authService = widget.authService;
    api = widget.api;
    data = widget.args["data"];
    id = data["id"];
    setData();
    // getTest();


    super.initState();
  }

  void getTest() async{
    try {
      await api.getTest(id);
    }
    catch(e){
      print("error in student: $e");
      return;
    }
    // await api.getStats(id);
    if (!mounted)
      return;

    setState(() {
      print("setting state");
      test = api.test;
      dev.log("test: ");
      // debugPrint("test: ${test.toString()}", wrapWidth: 1000);
      // print("end");
    });
  }

  Future<void> getStudent() async {
    try {
      student = await api.getStudent(id);
    }
    catch(e){
      print("error in student: $e");
      return;
    }

    if (!mounted)
      return;
  }

  void setData() async{
    await getStudent();
    if (student.isNotEmpty) {
      int id = widget.primaryCampus(student["campus_users"]);
      if (id != 0){
        location = widget.getCampus(student["campus"], id);
        print("loca $location");
      }
    }
    // print("loca $location");
    setState(() {});
    // print("loca $location");
  }
  
  // ModalRoute.of(context)?.settings.name

  @override
  Widget build(BuildContext context) {
    // String location;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
        data = args["data"];
        api = args["api"];
    }
    // stats = await api.getStats(data["id"]);
    // print("student $student");

    // debugPrint(student.toString(), wrapWidth: 1000);
    // debugPrint(data.toString(), wrapWidth: 1000);r
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // spacing: 1,
      // mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 10),
        Center(
          child: getImage(data, "small"),
        ),
        Text(data["displayname"],
        textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20,
            fontFamily:  "futura-pt",
            fontFamilyFallback:['Noto Sans', 'Arial', 'Helvetica', 'Sans serif'],
            color: Color(0xFFB9DCDC),
            // backgroundColor: Colors.black38,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 6)],
          ),
      ),
      Text(data["login"],
          textAlign: TextAlign.center, style: TextStyle(fontSize: 16,
            // color:  Color(0xFFB9DCDC),
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      // backgroundColor: Colors.white
          )),
        Container(child: Column(children: [
          Text(data["email"]),
          Text(location),
          // Text(data["Campus"])

        ]

        ),),

      ],
    );
  }
}
