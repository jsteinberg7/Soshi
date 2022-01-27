import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/localData.dart';
import 'constants/constants.dart';
import 'services/auth.dart';
import 'package:soshi/screens/wrapper.dart';
import 'package:flutter/services.dart';

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
        value: AuthService().user,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Constants.CustomTheme,
            home: Wrapper()));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize Firebase
  await Firebase.initializeApp();
  // lock device in portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // initialize SharedPreferences if user is logged in
  LocalDataService.preferences = await SharedPreferences.getInstance();
  bool firstLaunch = (!LocalDataService.hasLaunched() ||
      LocalDataService.hasLaunched() ==
          null); // firstLaunched true if hasLaunched is false (first time running app)
  // print(firstLaunch);
  /*
    1. Check if first time running app
    2. If so, check if LocalData has data to see if user is logged in
    */
  if (firstLaunch &&
      (LocalDataService.getLocalUsername() == "null" ||
          LocalDataService.getLocalUsername() == null)) {
    // print("first launch");
    AuthService tempAuth = new AuthService();
    await tempAuth.signOut(); // sign user out
    // print("signed out");
    //RestartWidget.restartApp(context);
  }
  Analytics.logAppOpen();

  runApp(MyApp()); // run app,

  await LocalDataService.preferences
      .setBool("hasLaunched", true); // user has launched app
}
