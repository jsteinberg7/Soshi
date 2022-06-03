import 'package:flutter/material.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/screens/login/onboarding.dart';
import 'package:soshi/screens/login/register.dart';

import '../../constants/widgets.dart';
import 'loginscreen.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();

  Function refreshWrapper;

  Authenticate({@required refresh}) {
    this.refreshWrapper = refresh;
  }
}

class _AuthenticateState extends State<Authenticate> {
  bool isRegistering = true;

  void toggleIsRegistering(bool state) {
    setState(() {
      isRegistering = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: PreferredSize(
            //Create "Beta" icon on left
            preferredSize: Size(Utilities.getWidth(context), Utilities.getHeight(context) / 16),
            child: SoshiAppBar()),
        body: isRegistering
            ? RegisterScreen(toggleScreen: toggleIsRegistering)
            // ? Onboarding()
            : LoginScreen(toggleScreen: toggleIsRegistering, refresh: widget.refreshWrapper));
  }
}
