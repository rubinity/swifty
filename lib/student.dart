import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:swifty/oauth.dart';
import 'package:swifty/api.dart';
import 'package:swifty/utils/utils.dart';
import 'utils/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
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
  const StudentView({super.key, required this.api, required this.args});

  final Api42 api;
  final Map<String, dynamic> args;
  // final String location = "";
  // String data;

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  // Object? data = {};
  Map<String, dynamic> data = {};
  var test;
  late Api42 api;
  late int id;
  late Map<String, dynamic>student = {};
  late Map<String, dynamic>cursus42 = {};
  late List<dynamic> skills = [];
  late List<dynamic> projects = [];
  late String campus = "";
  late int primaryCampusId;
  // late int other_campuses = student["campus"].length;
  late var secret = [];
  late String poolTime;

  int primaryCampus(List<dynamic> campuses){
    for (var campus in campuses){
      print("pr ${campus["is_primary"]}");
      if (campus["is_primary"] == true)
        // print("id ${campus["campus_id"].toString()}");
        return campus["campus_id"];
    }
    return 0;
  }

  List<String> getStudentSecret(List<dynamic> campuses){
    List<String> secret = [];
    for (var campus in campuses){
      print("campus${campus.toString()}");
      print("campus id - ${campus["id"]}, id $id");
      if (campus["id"] != primaryCampusId){
        secret.add(campus["name"]);
      }
    }
    print("s ${secret.toString()}");
    return secret;
  }

  String getCampus(List<dynamic> campuses, int id){
    for (var campus in campuses){
      if (campus["id"] == id)
        return campus["name"];
    }
    return "";
  }



  @override
  void initState() {
    // TODO: implement initState

    api = widget.api;
    data = widget.args["data"];
    id = data["id"];
    student = widget.args["data"];
    poolTime = getPoolTime();
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

  // Future<void> getStudent() async {
  //   try {
  //     student = await api.getStudent(id);
  //   }
  //   catch(e){
  //     print("error in student: $e");
  //     return;
  //   }
  //
  //   if (!mounted)
  //     return;
  // }

  Map<String, dynamic> getCursus(List<dynamic> cursuses) {
    for (var cursus in cursuses){
      if (cursus["cursus_id"] == 21)//TODO add error handling
        return cursus;
    }
    return {};
  }

  String getPoolTime(){
    return "${student["pool_month"]}.${student["pool_year"]}";
  }

  void setData() async{
    // await getStudent();
    // print("student ${data.toString()}");
    if (student.isNotEmpty) {
      primaryCampusId = primaryCampus(student["campus_users"]);
      if (primaryCampusId != 0){
        campus = getCampus(student["campus"], primaryCampusId);
        cursus42 = getCursus(student["cursus_users"]);
        print("skills ${cursus42["skills"]}");
        if (cursus42["skills"] != null) {
          skills = cursus42["skills"];
        }
        projects = student["projects_users"];
        // print("projects ${student["projects_users"].toString()}");
        if (student["campus"].length > 1) {
          secret = getStudentSecret(student["campus"]);
        }
        // print("cursus ${cursus42["skills"].toString()}");
      }
    }
   // student["projects_users"][0].forEach((key, value) => {print('$key: $value')});
   //  projects.forEach((entry) => {print('project: ${entry["project"].toString()}')});
    setState(() {});
    // print("loca ${student["cursus_users"]}");
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
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            // spacing: 1,
            // mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 10),
              Center(
                child: api.getImage(data, "small"),
              ),
        
                  Center(child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0.1),
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      // decoration: ShapeDecoration(shape:
                      // RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(5),
                      // ),
                      //     color: Color(0xFF00babc)),
                      child:
                      Text("${student["displayname"]}", style:  TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                      // OutlinedText(text: '${student["displayname"]} ', font: 20)
                    )),
              Align(
                alignment: Alignment(-0.85, 0),
                // widthFactor: 10,
                child: Container(
                  // color: Color(0xFF00babc),
                  padding: EdgeInsets.fromLTRB(7, 6, 7, 0),
                  decoration: ShapeDecoration(shape:
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                  ),
                      color: Color(0xFF00babc)
                    ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                    // margin: EdgeInsets.fromLTRB(0, 0, 0, 1),
                    decoration: ShapeDecoration(shape:
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                      // borderRadius: BorderRadius.circular(5),
                      // side: BorderSide(color: Color(0xFF00babc), width: 5, strokeAlign: BorderSide.strokeAlignInside)
                        ),
                        color: Colors.grey.shade800),
                    // color: Colors.black54,
                    child: Text("${student["login"]}", style:  TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height:1.0 ))
                    // OutlinedText(text: student["login"], font: 16, fontWeight: FontWeight.normal,),
                  ),
        
                ),
              ),
        
              // Card(child: Text("${data["login"]}", style:  TextStyle(color: Colors.white)),),
              BorderedContainer(bgColor: Colors.grey.shade800, child: Column(children: [
                  // Text(data["login"],
                  //     textAlign: TextAlign.center, style: TextStyle(fontSize: 16,
                  //       // color:  Color(0xFFB9DCDC),
                  //       color: Colors.white,
                  //       shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  //       // backgroundColor: Colors.white
                  //     )),
        
                  Row(children: [
                    Icon(Icons.email_outlined, color: Colors.white),
                    SizedBox(width: 4,),
                    Text("${data["email"]}", style:  TextStyle(color: Colors.white)),
                  ],),
                Row(
                  children: [
                    Icon(Icons.location_city_sharp, color: Colors.white, size: 20,),
                    SizedBox(width: 4,),
                    Text('campus: $campus', style:  TextStyle(color: Colors.white)),
                  ]
                ),
                Row(
                  children: [
                    Icon(Icons.wallet_outlined, color: Colors.white),
                    SizedBox(width: 4,),
                    Text('wallet: ${student["wallet"].toString()}', style:  TextStyle(color: Colors.white)),
                  ],
                ),
                  Row(
                    children: [
                      Icon(Icons.start, color: Colors.white),
                      SizedBox(width: 4,),
                      Text('Pool time: $poolTime', style:  TextStyle(color: Colors.white)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.arrow_circle_up_outlined, color: Colors.white),
                      SizedBox(width: 4,),
                      Text('level: ${cursus42["level"].toString()}', style:  TextStyle(color: Colors.white)),
                    ],
                  ),
                // Text(data["Campus"])
        
              ]
        
              ),),
              SizedBox(height: 4,),
              BorderedContainer(bgColor: Colors.white, child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Center(child: Text("Skills", style: TextStyle(color: Colors.black))),
                 ... skills.map(
                     (skill)=> Text("${skill["name"]}: ${skill["level"]}", style: TextStyle(color: Colors.black))
                 )
                  ],
        
                )
              ),
              SizedBox(height: 4,),
              BorderedContainer(bgColor: Colors.white, child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Center(child: Text("Projects", style: TextStyle(color: Colors.black))),
                      ... projects.map(
                              (project)=> Text("${project["project"]["name"]}", style: TextStyle(color: Colors.black))
                      )
                    ],
        
                  )
              ),
              if (secret.isNotEmpty)
              ...[SizedBox(height: 4,),
              BorderedContainer(bgColor: Colors.black,
                  child: Column(
                    children: [
                      Center(child: Text('Secret', style:  TextStyle(color: Colors.white))),
                      Row(
                        children: [
                          // Icon(Icons.shape_line_outlined, color: Colors.white),
                          // SizedBox(width: 4,),
                          Expanded(
                            child: Text('Other campuses: ${  listStringTrim(secret.toString())}',
                                // overflow: TextOverflow.fade,
                                style:  TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
              ),]
            ],
          ),
        ),
      ),
    );
  }
}
