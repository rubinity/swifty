import 'package:flutter/material.dart';

void goToPage(context, route){
  if (ModalRoute.of(context)?.settings.name != route)
    Navigator.pushNamed(context, route);
  else
    Navigator.pop(context);
}


// List<DropdownMenuItem<dynamic>> campusMenu(List<dynamic> camp){
//   var list = [DropdownMenuItem<dynamic>(child: Text("all"), value: -1)];
//   var campuses = camp.map((option)=>
//     DropdownMenuItem<dynamic>(child: Text(option["name"]), value: option["id"],)
//   ).toList();
//   list.addAll(campuses);
//   return list;
// }

List<DropdownMenuEntry<int>> campusMenu(List<dynamic> camp){

  var list = [DropdownMenuEntry<int>(label: "all", value: -1, style:
  ButtonStyle(visualDensity: VisualDensity.compact,
    textStyle: WidgetStatePropertyAll(TextStyle()),))];
  var entry;
  for (var option in camp)
 {
   entry = DropdownMenuEntry<int>(
     label: option["name"], value: option["id"], style:
   ButtonStyle(visualDensity: VisualDensity.compact,
     textStyle: WidgetStatePropertyAll(TextStyle()),),);
   if (option["name"] != "Heilbronn") {
      list.add(entry);
    }
    else {
      list.insert(1, entry);
    }
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
