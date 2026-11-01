import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:swifty/services/oauth.dart';
import 'package:swifty/services/api.dart';
import 'package:swifty/utils/utils.dart';
import 'package:swifty/common/constants.dart';
import '../utils/widgets.dart';
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
  const StudentView({super.key, required this._api, required this._args});

  final Api42 _api;
  final Map<String, dynamic> _args;

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  // Map<String, dynamic> _data = {};
  // var test;
  late Api42 api;
  late int _id;
  late Map<String, dynamic>student = {};
  late Map<String, dynamic>_cursus42 = {};
  late List<dynamic> _skills = [];
  late List<dynamic> _projects = [];
  late String _campus = "";
  late int _primaryCampusId;
  // late int other_campuses = student["campus"].length;
  late var _secret = [];
  late String _poolTime;

  int primaryCampus(List<dynamic> campuses){
    for (var campus in campuses){
      print("pr ${campus["is_primary"]}");
      if (campus["is_primary"] == true)
        // print("id ${campus["campus_id"].toString()}");
        return campus["campus_id"];
    }
    return 0;
  }

  // int printP(List<dynamic> projects){
  //   for (var p in projects){
  //     print("project ${p.toString()}");
  //   }
  //   return 0;
  // }

  List<String> getStudentSecret(List<dynamic> campuses){
    List<String> secret = [];
    for (var campus in campuses){
      print("campus${campus.toString()}");
      print("campus id - ${campus["id"]}, id $_id");
      if (campus["id"] != _primaryCampusId){
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
    super.initState();
    // api = widget._api;
    // data = widget.args["data"];

    student = widget._args["data"];
    print("st data st $student");
    if (student.isEmpty)
      return;
    _id = student["id"];
    _poolTime = getPoolTime();
    if (!mounted)
      return;
    setData(student);
    // getTest();
  }

  // void getTest() async{
  //   try {
  //     await api.getTest(_id);
  //   }
  //   catch(e){
  //     print("error in student: $e");
  //     return;
  //   }
  //   // await api.getStats(id);
  //   if (!mounted)
  //     return;
  //
  //   setState(() {
  //     print("setting state");
  //     test = api.test;
  //     dev.log("test: ");
  //     // debugPrint("test: ${test.toString()}", wrapWidth: 1000);
  //     // print("end");
  //   });
  // }

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

  String levelRound(double level){
      final part1 = level.floor();
      final part2 = ((level - part1) * 100).round();
      return "$part1.$part2";
  }
  int getPercentage(double level){
    double p = (level/20)*100;
    return(p.round());
  }

  void setData(Map<String, dynamic> student) async{
    // await getStudent();
    // print("student ${data.toString()}");
    if (student.isNotEmpty) {
      _primaryCampusId = primaryCampus(student["campus_users"]);
      if (_primaryCampusId != 0){
        _campus = getCampus(student["campus"], _primaryCampusId);
        _cursus42 = getCursus(student["cursus_users"]);
        print("skills ${_cursus42["skills"]}");
        if (_cursus42["skills"] != null) {
          _skills = _cursus42["skills"];
        }
        _projects = student["projects_users"];

        print("projects ${student["projects_users"].toString()}");
        if (student["campus"].length > 1) {
          _secret = getStudentSecret(student["campus"]);
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
    final args = widget._args;

    student = args["data"];
    api = args["api"];
    print("data $student");
        // student = widget._args["data"];

    if (student.isEmpty)
      return const Center(child: CircularProgressIndicator());
    // printP(projects);

    // stats = await api.getStats(data["id"]);
    // print("student $student");

    // debugPrint(student.toString(), wrapWidth: 1000);
    // debugPrint(data.toString(), wrapWidth: 1000);r
    return Align(
      alignment: Alignment.topCenter,
      child: Scrollbar(
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
                  child: api.getImage(student, "small"),
                ),
          
                    Center(child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0.1),
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        // decoration: ShapeDecoration(shape:
                        // RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(5),
                        // ),
                        //     color: turquoise),
                        child:
                        Text("${student["displayname"]}", style:  TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                        // OutlinedText(text: '${student["displayname"]} ', font: 20)
                      )),
                Align(
                  alignment: Alignment(-0.85, 0),
                  // widthFactor: 10,
                  child: Container(
                    // color: turquoise,
                    padding: EdgeInsets.fromLTRB(7, 6, 7, 0),
                    decoration: ShapeDecoration(shape:
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                    ),
                        color: turquoise
                      ),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                      // margin: EdgeInsets.fromLTRB(0, 0, 0, 1),
                      decoration: ShapeDecoration(shape:
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                        // borderRadius: BorderRadius.circular(5),
                        // side: BorderSide(color: turquoise, width: 5, strokeAlign: BorderSide.strokeAlignInside)
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
                      Text("${student["email"]}", style:  TextStyle(color: Colors.white)),
                    ],),
                  Row(
                    children: [
                      Icon(Icons.location_city_sharp, color: Colors.white, size: 20,),
                      SizedBox(width: 4,),
                      Text('campus: $_campus', style:  TextStyle(color: Colors.white)),
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
                        Text('Pool time: $_poolTime', style:  TextStyle(color: Colors.white)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.arrow_circle_up_outlined, color: Colors.white),
                        SizedBox(width: 4,),
                        Text('level: ${_cursus42["level"].toString()}', style:  TextStyle(color: Colors.white)),
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
                   ... _skills.map(
                       (skill)=> Text("${skill["name"]}: ${levelRound(skill["level"])} - ${getPercentage(skill["level"])}%", style: TextStyle(color: Colors.black))
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
                        ... _projects
                        .where((project)=> project["status"] == "finished")
                            .map(
                                (project)
                                {
                                  Color color = Colors.black;
                                  if (project["validated?"] == false)
                                    color = Colors.red;
                                  return Text("${project["project"]["name"]}",
                                      style: TextStyle(color: color));
                                  }
                        )
                      ],
          
                    )
                ),
                if (_secret.isNotEmpty)
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
                              child: Text('Other campuses: ${  listStringTrim(_secret.toString())}',
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
      ),
    );
  }
}
