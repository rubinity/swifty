import 'package:flutter/material.dart';
import 'package:swifty/utils/widgets.dart';
import '../services/oauth.dart';
import '../common/constants.dart';

class SignIn extends StatefulWidget {
  SignIn({super.key, required this.authService});
  AuthService authService;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String _clientId = "";
  String _clientSecret = "";
  bool _hiddenSecret = true;
  String _errorMsg = "";
  IconData _hide = Icons.visibility_off_outlined;
  final _formKey = GlobalKey<FormState>();

  Future<void> _authenticate() async {
    int status = await widget.authService.authenticate(_clientId, _clientSecret);
    if (status == 200) {
      Navigator.pop(
          context, {"clientId": _clientId, "clientSecret": _clientSecret});
    }
    else
      _errorMsg = errorMsgs(status);
    _clientId = "";
    _clientSecret = "";
    setState(() {});
  }

  void toggleSecret() {
    setState((){
      if (_hiddenSecret) {
        _hiddenSecret = false;
        _hide = Icons.visibility_off_outlined;
      }
      else {
        _hiddenSecret = true;
        _hide = Icons.visibility_outlined;
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
              initialValue: _clientId,
              decoration: InputDecoration(labelText: "Client ID", border: OutlineInputBorder()),
                onSaved: (value){_clientId = value!.trim();},
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
                onSaved: (value){_clientSecret = value!.trim();},
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
                    child: IconButton(onPressed: ()=>toggleSecret(), icon: Icon(_hide)),
                  ),
                ),]),
              if (_errorMsg.isNotEmpty)
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween , children: [
                Expanded(child: Text(_errorMsg,
                  style: TextStyle(height: 1.0, fontSize: 16, color: red),
                )),]),
              FilledButton(onPressed: () async {
                setState(() {
                  _errorMsg = "";
                });
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await _authenticate();
                }}, child: Text('Sign in'),
            ),
            ],
          ),
        )
        ),

    );
  }
}
