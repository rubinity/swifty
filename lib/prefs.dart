import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

class Prefs{

  static Future<void> savePrefs(bool expandedFilter) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("expanded", expandedFilter);
    print("the value is $expandedFilter");
  }

  static Future<void> saveCampuses(List<Map<String, dynamic>> campuses) async{
    final campString = jsonEncode(campuses);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("campusList", campString);
    print("campuses saved $campuses, string $campString");
  }

  static Future<List<Map<String, dynamic>>> loadCampuses() async{
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> tempList;
    String? campString = await prefs.getString("campusList");
    // campString = '[{"fdf":"eret"}]';
    print("string $campString");
    if (campString != null && campString.isNotEmpty){
      tempList = jsonDecode(campString);
      return tempList.cast<Map<String, dynamic>>();
    }

    return [];
  }

  static Future<void> loadPrefs(List<bool> expandedFilter) async{
    final prefs = await SharedPreferences.getInstance();
    final expanded = await prefs.getBool("expanded");
    print("the loaded value is $expanded");
    if (expanded != null)
      expandedFilter[0] = expanded;
    // return false;
  }

  static Future<void> clearCampuses() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("campusList");
  }

}