import 'package:flutter/material.dart';
import 'package:swifty/signin.dart';
import 'package:swifty/oauth.dart';
// import 'package:flutter/services.dart';
import 'api.dart';
import 'utils/widgets.dart' as w;
import 'page.dart';
import 'prefs.dart';
import 'student_list.dart';
import 'student.dart';
import 'signin.dart';
import 'settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:swifty/utils/constants.dart';

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
        // colorScheme: .fromSeed(seedColor: Colors.black),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: turquoise,
            foregroundColor: Colors.black,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(isDense: true,
          border: OutlineInputBorder(),
          constraints: const BoxConstraints(maxHeight: 40),
        ),
      ),

      // home: AppPage(title: 'Sign in', body: Sign in()),
      // initialRoute: '/auth',
      routes: {
        '/auth': (context) => AppPage(title: 'Sign in', body: SignIn(authService: authService)),
        '/settings': (context) => AppPage(title: 'Settings', body: Settings(authService: authService)),
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
