import 'package:flutter/material.dart';
import 'package:swifty/utils/widgets.dart';
import '../services/oauth.dart';
import '../services/prefs.dart';
import '../services/api.dart' as api;
import 'package:swifty/common/constants.dart';

class Settings extends StatefulWidget {
  Settings({super.key, required this.authService});
  AuthService authService;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // String clientId = "";
  // String clientSecret = "";
  final _settingsKey = GlobalKey<FormState>();
  bool _clearCampuses = false;
  bool _clearCreds = false;
  bool _clearToken = false;
  bool _checkAll = false;

  Future<void> clear() async {
    if (_clearCampuses == true)
      await Prefs.clearCampuses();
    if (_clearToken == true)
      await widget.authService.clearToken();
    if (_clearCreds == true)
      await widget.authService.clearCredentials();
  }

  void checkUncheck(bool checkAll){

  setState(() {
    if (checkAll == true) {
      _clearCampuses = true;
      _clearCreds = true;
      _clearToken = true;
    }
    else if (_checkAll == false){
      _clearCampuses = false;
      _clearCreds = false;
      _clearToken = false;
    }

  });

  }
  @override
  Widget build(BuildContext context) {

    // final form = Form.of(context);
    // final formKey = GlobalKey<FormState>();
    // if (authService.authorized)
      // Navigator.pushNamed(context, '/home');
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        shape:
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: turquoise, width: 5)),
        child: Form(
          key: _settingsKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //TODO delete this button
              SizedBox(height: 8,),
              Text("Clear", style: TextStyle(fontSize: 18),),
              CheckboxListTile(value: _checkAll, checkColor: Colors.black, activeColor: Colors.white ,
                  title: Text("Check/uncheck all"),
                  fillColor: WidgetStatePropertyAll(Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                  onChanged: (value){setState(() {
                    if (value != null)
                      _checkAll = value;
                    else
                      _checkAll = false;
                    checkUncheck(_checkAll);
                  });}),
              
             CheckboxListTile(value: _clearCampuses, checkColor: Colors.black, activeColor: Colors.white ,
                    title: Text("Clear campus list"),
                    fillColor: WidgetStatePropertyAll(Colors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                    onChanged: (value){setState(() {
                      if (value != null)
                        _clearCampuses = value;
                      else
                        _clearCampuses = false;
                    });}),

         CheckboxListTile(value: _clearCreds, checkColor: Colors.black, activeColor: Colors.white ,
             title: Text("Clear credentials"),
                  fillColor: WidgetStatePropertyAll(Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                  onChanged: (value){setState(() {
                    if (value != null)
                      _clearCreds = value;
                    else
                      _clearCreds = false;

                  });print(_clearCreds);}),

         CheckboxListTile(value: _clearToken, checkColor: Colors.black, activeColor: Colors.white ,
             title: Text("Clear token"),
                    fillColor: WidgetStatePropertyAll(Colors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                    onChanged: (value){setState(() {
                      if (value != null)
                        _clearToken = value;
                      else
                        _clearToken = false;
                    });}),

              FilledButton(onPressed: () async {
                print("camp $_clearCampuses");
                print("creds $_clearCreds");
                print("tok $_clearToken");
                await clear();
              }, child: Text('Clear'),
               ),
              SizedBox(height: 8),
              // CheckboxListTile(value: _clearToken, checkColor: Colors.black, activeColor: Colors.white ,
              //     title: Text("Clear token"),
              //     fillColor: WidgetStatePropertyAll(Colors.white),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
              //     onChanged: (value){setState(() {
              //       if (value != null)
              //         _clearToken = value;
              //       else
              //         _clearToken = false;
              //     });}),
              // SizedBox(height: 8),

              //todo delete later
              // FilledButton(onPressed: () async {
              //   var c = await Prefs.loadCampuses();
              //   print("loaded campuses $c");
              //   }, child: Text('Print campuses'),
              // ),
              // SizedBox(height: 8),
              // TextButton(onPressed: () async {
              //   await widget.authService.clearCredentials();
              // }, child: Text('Clear credentials'),
              //   style: Styles42.buttonStyle,),
              //
              // FilledButton(onPressed: () async {
              //   await widget.authService.clearToken();
              // }, child: Text('Clear token'),
              //   style: Styles42.buttonStyle,),
              // FilledButton(onPressed: () async {
              //   await Prefs.clearCampuses();
              //   // await widget.authService.input(clientId, clientSecret);
              // }, child: Text('Clear campuses'),
              //   style: Styles42.buttonStyle,),
              // SizedBox(height: 10),

            ],
          ),

        ),
      ),

    );
  }
}
