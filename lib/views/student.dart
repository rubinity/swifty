import 'package:flutter/material.dart';
import 'package:swifty/services/api.dart';
import 'package:swifty/utils/utils.dart';
import 'package:swifty/common/constants.dart';
import '../utils/widgets.dart';

class StudentView extends StatefulWidget {
  const StudentView({super.key, required this.api, required this.args});

  final Map<String, dynamic> args;
  final Api42 api;

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  late Map<String, dynamic>student = {};
  late Map<String, dynamic>_cursus42 = {};
  late List<dynamic> _skills = [];
  late List<dynamic> _projects = [];
  late String _campus = "";
  late int _primaryCampusId;
  late var _secret = [];
  late String _poolTime;

  // int printP(List<dynamic> projects){
  //   for (var p in projects){
  //     print("project ${p.toString()}");
  //   }
  //   return 0;
  // }

  int primaryCampus(List<dynamic> campuses){
    for (var campus in campuses){
      if (campus["is_primary"] == true)
        return campus["campus_id"];
    }
    return 0;
  }

  List<String> getStudentSecret(List<dynamic> campuses){
    List<String> secret = [];
    for (var campus in campuses){
      if (campus["id"] != _primaryCampusId){
        secret.add(campus["name"]);
      }
    }
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

    student = widget.args["data"];
    if (student.isEmpty)
      return;
    _poolTime = getPoolTime();
    if (!mounted)
      return;
    setData(student);
  }


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

  void setData(Map<String, dynamic> student) {
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
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    student = args["data"];
    print("data $student");

    if (student.isEmpty)
      return const Center(child: CircularProgressIndicator());
    // printP(projects);

    return Align(
      alignment: Alignment.topCenter,
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Center(
                child: widget.api.getImage(student, "small"),
              ),
                  Center(child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0.1),
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child:
                      Text("${student["displayname"]}",
                          style:  TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                    )),
              Align(
                alignment: Alignment(-0.85, 0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(7, 6, 7, 0),
                  decoration: ShapeDecoration(shape:
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                  ),
                      color: turquoise
                    ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                    decoration: ShapeDecoration(shape:
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                        ),
                        color: Colors.grey.shade800),
                    child: Text("${student["login"]}", style:  TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height:1.0 ))
                  ),

                ),
              ),

              BorderedContainer(bgColor: Colors.grey.shade800, child: Column(children: [
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
    );
  }
}
