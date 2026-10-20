import 'package:flutter/material.dart';
import 'package:swifty/authgate.dart';
import 'package:swifty/oauth.dart';
// import 'package:flutter/services.dart';
import 'api.dart';
import 'utils/widgets.dart' as w;
import 'page.dart';
import 'student_list.dart';
import 'student.dart';
import 'authgate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

late final String appPath;
enum customColors{ blue, black}

Future<void> main()
    async {
      WidgetsFlutterBinding.ensureInitialized();
      AuthService authService = AuthService();
      appPath = (await getApplicationDocumentsDirectory()).path;
      Api42 api = Api42(authService: authService);
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
        '/': (context) => AppPage(title: 'Students', body: StudentList(api: api)),
        '/student': (context) => AppPage(title: 'Student', body: StudentView(api: api, args: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)),
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
