import 'package:flutter/material.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/screens/login/register.dart';

import 'loginscreen.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool isRegistering = false;

  void toggleIsRegistering(bool state) {
    setState(() {
      isRegistering = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          
          // This is creating the app bar with the Soshi Logo and text
          elevation: 40,
          title: Image.asset(
            "assets/images/SoshiLogos/soshi_logo.png",
            height: Utilities.getHeight(context) / 22,
          ),
          backgroundColor: Constants.appBarColor,
          centerTitle: true,
        ),
        body: isRegistering ? RegisterScreen(toggleScreen: toggleIsRegistering) : LoginScreen(toggleScreen: toggleIsRegistering));
  }
}
