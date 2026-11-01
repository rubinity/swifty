import 'package:flutter/material.dart';
import 'package:swifty/utils/widgets.dart';
import '../services/oauth.dart';
import '../services/prefs.dart';
import '../services/api.dart' as api;
import 'dart:io';

class SignIn extends StatefulWidget {
  SignIn({super.key, required this.authService});
  AuthService authService;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String clientId = "";
  String clientSecret = "";
  bool _hiddenSecret = true;
  String errorMsg = "";
  // IconData show;
  // IconData show = Icons.visibility_outlined;
  IconData hide = Icons.visibility_off_outlined;
  final _formKey = GlobalKey<FormState>();

  Future<void> _authenticate() async {
    int status = await widget.authService.authenticate(clientId, clientSecret);
    print("stat $status");
    if (status == 200) {
      Navigator.pop(
          context, {"clientId": clientId, "clientSecret": clientSecret});
    }
    else
      errorMsg = errorMsgs(status);
    clientId = "";
    clientSecret = "";
    setState(() {});
  }

  void toggleSecret() {
    setState((){
      if (_hiddenSecret) {
        _hiddenSecret = false;
        hide = Icons.visibility_off_outlined;
      }
      else {
        _hiddenSecret = true;
        hide = Icons.visibility_outlined;
      }
    });
  }

  String errorMsgs(int status){
    if (status == 401){
      return "Wrong credentials, please enter the correct ones";
    }
    else if (status == 429){
      return  "Too many requests. Try again later.";
    }
    else if (status == 0){
      return "Network error. Try again later.";
    }
    else {
      return "Something is wrong. Try again later.";
    }
  }
  @override
  Widget build(BuildContext context) {

    // final form = Form.of(context);
    // final formKey = GlobalKey<FormState>();
    // if (authService.authorized)
      // Navigator.pushNamed(context, '/home');
    return Align(
      alignment: Alignment.topCenter,
      child: Form(
        key: _formKey,
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
                validator:  (value){
                  if (value == null || value.trim().isEmpty)
                      return "Enter a value";
                  return null;
                  }
              )),]),
              SizedBox(height: 8),
              Row(children: [Expanded(child: TextFormField(
                obscureText: _hiddenSecret,
                decoration: InputDecoration(labelText: "Client secret", border: OutlineInputBorder()),
                onSaved: (value){clientSecret = value!.trim();},
                validator:  (value){
                  if (value == null || value.trim().isEmpty)
                  return "Enter a value";
                  return null;
                }
              )),]),
              Row(children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(onPressed: ()=>toggleSecret(), icon: Icon(hide)),
                  ),
                ),]),
              if (errorMsg.isNotEmpty)
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween , children: [
                Expanded(child: Text(errorMsg,
                  style: TextStyle(height: 1.0, fontSize: 16, color: Colors.red),

                  // onSaved: (value){
                  //
                  //   params["range_login"] = value!;
                  //   },
                  // onChanged:


                )
                ),
              ]),
              FilledButton(onPressed: () async {
                setState(() {
                  errorMsg = "";
                });
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _authenticate();
                }
                // await widget.authService.authenticate(clientId, clientSecret);

                }, child: Text('Sign in'),
            ),
              // SizedBox(height: 4),
             //  FilledButton(onPressed: () async {
             //    await widget.authService.clearCredentials();
             //    // await widget.authService.input(clientId, clientSecret);
             //  }, child: Text('Clear credentials'),
             // ),

            ],
          ),
        )
        ),

    );
  }
}
