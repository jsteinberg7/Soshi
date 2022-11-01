import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soshi/screens/login/newIntroFlowSri.dart';
import 'package:soshi/screens/mainapp/mainapp.dart';
import 'package:soshi/services/dataEngine.dart';
import 'login/authenticate.dart';

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
  bool firstLaunch;
  Widget toReturn;

  void refreshApp() {
    setState(() {
      firstLaunch = false;
    });
    print("app refreshed!");
  }

  wrapperSafeguard() async {
    final user = Provider.of<User>(context);

    if (user == null) { // show login
      toReturn = NewIntroFlow();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("Username") || prefs.getString("Username") == "") { // show login
      // This means that user data was lost in upgrade or bug, need to force user to sign up again :(
      toReturn = NewIntroFlow(); 
    } else { // show main app
      // We have a local stored version of the Username. We will use this to restore all Userdata!
      await DataEngine.initialize();
      toReturn = MainApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: wrapperSafeguard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(
                child: Center(child: CircularProgressIndicator.adaptive()));
          } else {
            return toReturn;
          }
        });
  }
}
