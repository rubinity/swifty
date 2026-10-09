import 'package:flutter/material.dart';
import 'oauth.dart';
import 'api.dart' as api;
import 'dart:io';
import 'package:swifty/time.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key, required this.authService});
  AuthService authService;
  @override
  Widget build(BuildContext context) {
    // if (authService.authorized)
      // Navigator.pushNamed(context, '/home');
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text(style: TextStyle(fontSize: 20), expireTime.toString()),
          // Text(style: TextStyle(fontSize: 20), createdTime.toString()),
          ElevatedButton(onPressed: () async {await authService.authorize();}, child: Text('Authorize')),
          // ElevatedButton(onPressed: () => {api.Api42().getData()}, child: Text('get response')),
          // ElevatedButton(onPressed: () => {authService.getToken()}, child: Text('get response')),
          // Text(style: TextStyle(fontSize: 20), api.Api42.g),  Navigator.pushNamed(context, '/home');
        ],
      ),
    );
  }
}
