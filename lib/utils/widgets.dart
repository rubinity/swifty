import 'package:flutter/material.dart';
import 'package:swifty/common/constants.dart';
class MainTitle extends StatefulWidget {
  const MainTitle({super.key});

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

class BorderedContainer extends StatelessWidget {
  const BorderedContainer({super.key, required this.child, required this.bgColor,
  this.sideMargin = 10, this.topMargin = 0});
  final Widget child;
  final Color bgColor;
  final double sideMargin;
  final double topMargin;


  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 200,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: ShapeDecoration(shape:
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: turquoise, width: 5)),
          color: bgColor,),
        margin: EdgeInsets.fromLTRB(sideMargin, topMargin, sideMargin, 0),
        child: child
    );
  }
}
