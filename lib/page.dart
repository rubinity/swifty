import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer';



class AppPage extends StatelessWidget{
  const AppPage({super.key, required this.title, required this.body});

  final String title;
  final Widget body;
  // final screenWidth = MediaQuery.of(context).size.width;


  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    // final padWidth = screenWidth * 0.01;
    // print(["screen", screenWidth]);
    // TODO: implement build
    return (Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset('assets/42.svg', height: 40,),
            SizedBox(width: 8),
            // Padding(
            //   // padding: EdgeInsets.all(40),
            //   child: SvgPicture.asset('assets/42.svg', height: 40,),
            // ),
            Text(style: TextStyle(color: Colors.white, fontSize: 30 ),
                title),
          ],
        ),
        centerTitle: false,
        // backgroundColor: Color(0xFF8A189C),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        // actions: [
        //   Padding(
        //       padding: EdgeInsets.all(8),
        //       child: SvgPicture.asset('assets/42.svg'),
        //   ),
        //   const SizedBox(width: 22)
        // ],
        // leading: Padding(

        // ),
        // leading: Image.asset('assets/img.png'),
        // SvgPicture.network('https://profile.intra.42.fr/assets/42_logo-7dfc9110a5319a308863b96bda33cea995046d1731cebb735e41b16255106c12.svg'),

        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light, // icon color (time/battery/wifi icons): light = white icons, dark = black icons
        ),

      ),
      body: SafeArea(child: Container(color: Colors.grey,
          child: body))));
      }
    }

