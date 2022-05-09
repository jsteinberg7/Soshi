import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soshi/screens/login/onboarding.dart';
import 'package:soshi/services/localData.dart';
import 'login/authenticate.dart';
import 'login/loginscreen.dart';
import 'mainapp/mainapp.dart';

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
    setState(() {});
    print("app refreshed!");
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context); // get current user

    if (user != null) {
      // precacheImage(NetworkImage(LocalDataService.getLocalProfilePictureURL()),
      //     context); // precache profile picture
      return MainApp();
    } else {
      if (!widget.firstLaunch) {
        return Authenticate(refresh: refreshApp);
      } else {
        return Onboarding();
      }
    }
  }
}
