import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login/authenticate.dart';
import 'mainapp/mainapp.dart';

/*
Wrapper is the top widget of the app and shows either:
  A) LoginScreen (if the user is not signed in)
  B) MainApp (if the user is already signed in)
*/
class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context); // get current user
    // DatabaseService tempDB = new DatabaseService();
    // Future<bool> isFirstRun = tempDB.isFirstTime();
    // bool conversion = isFirstRun as bool;

    if (user != null) {
      return MainApp();
    } else {
      // print("not logged in"); // assume user is not signed in
      return Authenticate();
    }
  }
}
