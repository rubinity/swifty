import 'package:flutter/material.dart';
import 'package:swifty/utils/widgets.dart';
import 'oauth.dart';
import 'prefs.dart';
import 'api.dart' as api;
import 'styles.dart';
import 'dart:io';
import 'package:swifty/utils/time.dart';

class SignIn extends StatefulWidget {
  SignIn({super.key, required this.authService});
  AuthService authService;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String clientId = "";
  String clientSecret = "";
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    // final form = Form.of(context);
    // final formKey = GlobalKey<FormState>();
    // if (authService.authorized)
      // Navigator.pushNamed(context, '/home');
    return Align(
      alignment: Alignment.topCenter,
      child: Form(
        key: formKey,
        child: BorderedContainer(
          topMargin: 10,
          bgColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [Expanded(child: TextFormField(
              initialValue: clientId,
              decoration: InputDecoration(labelText: "Client ID", border: OutlineInputBorder()),
                onSaved: (value){clientId = value!.trim();},
              )),]),
              SizedBox(height: 8),
              Row(children: [Expanded(child: TextFormField(
                decoration: InputDecoration(labelText: "Client secret", border: OutlineInputBorder()),
                onSaved: (value){clientSecret = value!.trim();},
              )),]),
              // Center(child: TextFormField()),
              // TextFormField(),
              SizedBox(height: 4),
              FilledButton(onPressed: () async {
                formKey.currentState!.save();
                await widget.authService.input(clientId, clientSecret);
                Navigator.pop(context, {"clientId": clientId, "clientSecret": clientSecret});
                }, child: Text('Save'),
            ),
              // SizedBox(height: 4),
              FilledButton(onPressed: () async {
                await widget.authService.clearCredentials();
                // await widget.authService.input(clientId, clientSecret);
              }, child: Text('Clear credentials'),
             ),

            ],
          ),
        )
        ),

    );
  }
}
