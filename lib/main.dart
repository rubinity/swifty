import 'package:flutter/material.dart';
import 'package:swifty/views/sign_in.dart';
import 'package:swifty/services/oauth.dart';
import 'services/api.dart';
import 'views/page.dart';
import 'views/student_list.dart';
import 'views/student.dart';
import 'views/settings.dart';
import 'package:swifty/common/constants.dart';

void main()
    {
      AuthService authService = AuthService();
      Api42 api = Api42(authService: authService);

      runApp(
          MaterialApp(
      title: 'Swiftanion',
      theme: ThemeData(
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
      routes: {
        '/auth': (context) => AppPage(title: 'Sign in', child: SignIn(authService: authService)),
        '/settings': (context) => AppPage(title: 'Settings', child: Settings(authService: authService)),
        '/': (context) => AppPage(title: 'Students', child: StudentList(api: api)),
        '/student': (context) => AppPage(title: 'Student', child: StudentView(api: api, args: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)),
      },
    ));
    }