import 'package:flutter/material.dart';
import 'package:swifty/utils/constants.dart';
class Styles42{
   static ButtonStyle buttonStyle = FilledButton.styleFrom(backgroundColor: turquoise,
      visualDensity: VisualDensity.compact,
      textStyle: TextStyle(color: Colors.black),
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)));
}