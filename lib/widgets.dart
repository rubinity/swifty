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



