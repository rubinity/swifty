import 'package:flutter/material.dart';
import 'package:swifty/authgate.dart';
import 'package:swifty/oauth.dart';
// import 'package:flutter/services.dart';
import 'api.dart';
import 'widgets.dart' as w;
import 'page.dart';
import 'student_list.dart';
import 'authgate.dart';
import 'package:path_provider/path_provider.dart';

late final String appPath;

Future<void> main()
    async {
      WidgetsFlutterBinding.ensureInitialized();
      AuthService authService = AuthService();
      appPath = (await getApplicationDocumentsDirectory()).path;
      // Api42 api = Api42();
      runApp(
          MaterialApp(
      title: 'Swiftanion',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.black),
      ),
      // home: AppPage(title: 'AuthGate', body: AuthGate()),
      // initialRoute: '/home',
      routes: {
        '/auth': (context) => AppPage(title: 'AuthGate', body: AuthGate(authService: authService)),
        '/': (context) => AppPage(title: 'Students', body: StudentList(authService: authService)),
      },
      // home: AppPage(title: 'Students', body: StudentList()),
    ));
    }



// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Swiftanion',
//       theme: ThemeData(
//         colorScheme: .fromSeed(seedColor: Colors.black),
//       ),
//       home: const AppPage(title: 'User list', body: StudentList()),
//     );
//   }
// }
