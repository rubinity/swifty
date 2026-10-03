import 'package:flutter/material.dart';
class MainTitle extends StatefulWidget {
  const MainTitle({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MainTitle> createState() => _TitleState();
}

class _TitleState extends State<MainTitle> {


  @override
  Widget build(BuildContext context){
    return(Text('Students',
      style: TextStyle(fontSize: 24),));
  }
}