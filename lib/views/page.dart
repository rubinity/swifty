import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/utils.dart';


class AppPage extends StatelessWidget{
  const AppPage({super.key, required this.title, required this.child});

  final String title;
  final Widget child;


  @override
  Widget build(BuildContext context) {

    return (Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/42.svg', height: 40,),
            SizedBox(width: 8),
            Text(style: TextStyle(color: Colors.white, fontSize: 30 ),
                title),
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light, // icon color (time/battery/wifi icons): light = white icons, dark = black icons
        ),

      ),
      endDrawer: Drawer(width: 200, backgroundColor: Colors.blueGrey[100],
        child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () => {goToPage(context, "/settings")},
          ),
          ListTile(
            leading: Icon(Icons.login_outlined),
            title: Text("Sign in"),
            onTap: () => {goToPage(context, "/auth")},
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () => {goToPage(context, "/")},
            shape: Border(top: BorderSide(color: Colors.grey, width: 3))
          ),
        ],
      ),) ,
      body: SafeArea(child: Container(color: Colors.grey,
          child: child))));
      }
    }

