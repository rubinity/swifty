// import 'package:flutter/material.dart';

class Student {

  Student({required this.first_name, required this.last_name, this.image_path = ""});

  String first_name;
  String last_name;
  String image_path;

  setImagePath(String path) {
    this.image_path = path;
}

}