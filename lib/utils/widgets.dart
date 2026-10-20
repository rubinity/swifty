import 'package:flutter/material.dart';
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

class OutlinedText extends StatelessWidget {
  const OutlinedText({super.key, required this.text, required this.font, this.fontWeight = FontWeight.bold});
  final String text;
  final double font;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: font,
            fontFamily:  "futura-pt",
            fontFamilyFallback:['Noto Sans', 'Arial', 'Helvetica', 'Sans serif'],
            // color: Colors.white,
            // backgroundColor: Colors.black38,
            fontWeight: fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Color(0xFF00babc),
            // shadows: [Shadow(color: Color(0xFF00babc), blurRadius: 10)],
          ),
        ),
          Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: font,
              fontFamily:  "futura-pt",
              fontFamilyFallback:['Noto Sans', 'Arial', 'Helvetica', 'Sans serif'],
              color: Colors.white,
              // backgroundColor: Colors.black38,
              fontWeight: fontWeight,
              // shadows: [Shadow(color: Color(0xFF00babc), blurRadius: 10)],
            ),
          ),]
    );
  }
}

class BorderedContainer extends StatelessWidget {
  const BorderedContainer({super.key, required this.inside, required this.bgColor, this.sideMargin = 10});
  final Widget inside;
  final Color bgColor;
  final double sideMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: ShapeDecoration(shape:
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Color(0xFF00babc), width: 5)),
          color: bgColor,),
        margin: EdgeInsets.fromLTRB(sideMargin, 0, sideMargin, 0),
        child: inside
    );
  }
}




