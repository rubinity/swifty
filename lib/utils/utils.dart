import 'package:flutter/material.dart';

void goToPage(context, route){
  if (ModalRoute.of(context)?.settings.name != route)
    Navigator.pushNamed(context, route);
  else
    Navigator.pop(context);
}


List<DropdownMenuItem<dynamic>> campusMenu(List<dynamic> camp){
  var list = [DropdownMenuItem<dynamic>(child: Text("all"), value: -1)];
  var campuses = camp.map((option)=>
    DropdownMenuItem<dynamic>(child: Text(option["name"]), value: option["id"],)
  ).toList();
  list.addAll(campuses);
  return list;
}