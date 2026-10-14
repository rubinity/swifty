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


void goToPage(context, route){
  if (ModalRoute.of(context)?.settings.name != route)
    Navigator.pushNamed(context, route);
  else
    Navigator.pop(context);
}

// Image getImage(data, type, {double width = 0, double height = 0}){
//   print("fxing image");
//   print(data["image"]["versions"]);
//   var url = data["image"]["versions"][type];
//   print(url);
//   if (url != null){
//     try {
//       if (width == 0)
//       return Image.network(url);
//     else
//       return Image.network(url, width: width, height: height);
//   }
//     catch (e){
//       print(e.toString());
//
//   }}
//     return Image(image: AssetImage("assets/42.jpg") , width: 24, height: 24,);

// }
