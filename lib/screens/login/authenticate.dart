import 'package:flutter/material.dart';
import 'package:soshi/screens/login/newIntroFlowSri.dart';

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
        // appBar: PreferredSize(
        //     preferredSize: Size(Utilities.getWidth(context), Utilities.getHeight(context) / 16),
        //     child: SoshiAppBar()),
        body: NewIntroFlow()

        // isRegistering
        //     ? NewIntroFlow()
        //     : LoginScreen(toggleScreen: toggleIsRegistering, refresh: widget.refreshWrapper)

        );
  }
}
