import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soshi/services/localData.dart';
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

    if (user != null) {
      // precacheImage(NetworkImage(LocalDataService.getLocalProfilePictureURL()),
      //     context); // precache profile picture
      return MainApp();
    } else {
      return Authenticate();
    }
  }
}
