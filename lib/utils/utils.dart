import 'package:flutter/material.dart';

void goToPage(context, route){
  if (ModalRoute.of(context)?.isCurrent != true) {
    return;
  }
  bool routeFound = false;
  String? curRoute = ModalRoute.of(context)?.settings.name;
  var nav = Navigator.of(context);
  nav.pop();//pop menu
  if (curRoute == route)
    return;
  if (route == "/") {
    nav.popUntil(ModalRoute.withName("/"));
    return;
  }
  if (curRoute == "/settings") {
    nav.popUntil((rt){
      if (rt.settings.name == "/" || rt.settings.name == "/student")
        return true;
      if (rt.settings.name == route) {
        routeFound = true;
        return true;
      }
      return false;
    });
  }
  if (!routeFound)
    nav.pushNamed(route);
}

List<DropdownMenuEntry<int>> campusMenu(List<dynamic> camp){
  List<DropdownMenuEntry<int>> list = [];
  DropdownMenuEntry<int> entry;
  for (var option in camp)
  {
    entry = DropdownMenuEntry<int>(
      label: option["name"], value: option["id"], style:
    ButtonStyle(visualDensity: VisualDensity.compact,
      textStyle: WidgetStatePropertyAll(TextStyle()),),);
    list.add(entry);
  }
  return list;
}

List<DropdownMenuEntry<String>> yearMenu(){
  var thisYear = DateTime.now().year;
  List<int> yearsInt = [];
  for (int i = 0; i < 10; i++){
    yearsInt.add((thisYear - i));
  }
  var years = [DropdownMenuEntry<String>(label: "all", value: "all")];
 List<DropdownMenuEntry<String>> y = yearsInt.map((year)=>
      DropdownMenuEntry<String>(label: year.toString(), value: year.toString(), style: ButtonStyle(visualDensity: VisualDensity.compact))
  ).toList();
  years.addAll(y);
  return years;
}

List<DropdownMenuEntry<String>> monthMenu(){
  List<String> months = ["all", "january", "february", "march", "april", "may", "june"
    , "july", "august",  "september",  "october", "november", "december"];
  var monthMenu = months.map((month)=>DropdownMenuEntry<String>(label: month, value: month, style: ButtonStyle(visualDensity: VisualDensity.compact),)).toList();
  return monthMenu;
}

String listStringTrim(String listString){
  int last = listString.length - 1;
  return listString.substring(1, last);
}
