import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soshi/screens/login/newIntroFlowSri.dart';
import 'package:soshi/screens/mainapp/mainapp.dart';
import 'login/authenticate.dart';

/*
Wrapper is the top widget of the app and shows either:
  A) LoginScreen (if the user is not signed in)
  B) MainApp (if the user is already signed in)
*/
class Wrapper extends StatefulWidget {
  bool firstLaunch;

  @override
  _WrapperState createState() => _WrapperState();

  Wrapper(this.firstLaunch);
}

class _WrapperState extends State<Wrapper> {
  void refreshApp() {
    setState(() {
      widget.firstLaunch = false;
    });
    print("app refreshed!");
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context); // get current user

    if (user != null) {
      return MainApp();
    } else {
      return NewIntroFlow();
      // if (!widget.firstLaunch) {
      //   return Authenticate(refresh: refreshApp);
      // } else {
      //   return NewIntroFlow();
      // }
    }
  }
}
