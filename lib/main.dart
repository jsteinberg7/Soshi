import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/dynamicLinks.dart';
import 'package:soshi/services/localData.dart';
import 'constants/themes.dart';
import 'services/auth.dart';
import 'package:soshi/screens/wrapper.dart';
import 'package:flutter/services.dart';

class MyApp extends StatefulWidget {
  PendingDynamicLinkData linkData;

  @override
  _MyAppState createState() => _MyAppState();

  MyApp(PendingDynamicLinkData linkDataIn) {
    this.linkData = linkDataIn;
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer _timerLink;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(
        const Duration(milliseconds: 1000),
        () {
          DynamicLinkService.retrieveDynamicLink(context);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
        value: AuthService().user,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            theme: ThemeData(
              brightness: Brightness.light,
              backgroundColor: Colors.grey[50],
              primarySwatch: MaterialColor(
                0xFFE7E7E7,
                <int, Color>{
                  50: Color.fromARGB(26, 223, 247, 248),
                  100: Color.fromARGB(26, 199, 230, 231),
                  200: Color.fromARGB(26, 187, 223, 224),
                  300: Color.fromARGB(26, 173, 206, 207),
                  400: Color.fromARGB(26, 153, 186, 187),
                  500: Color.fromARGB(26, 161, 193, 194),
                  600: Color.fromARGB(26, 152, 179, 180),
                  700: Color.fromARGB(26, 124, 152, 153),
                  800: Color.fromARGB(26, 95, 139, 141),
                  900: Color.fromARGB(26, 64, 116, 117),
                },
              ),
              primaryColor: Color.fromARGB(255, 179, 225, 237),
              primaryColorLight: Color.fromARGB(255, 179, 225, 237),
              primaryColorDark: Color(0xff936F3E),
              canvasColor: Color.fromARGB(255, 191, 200, 202),
              scaffoldBackgroundColor: Colors.grey[50],
              bottomAppBarColor: Color.fromARGB(255, 0, 0, 0),
              appBarTheme: AppBarTheme(color: Colors.grey[50]),

              cardColor: Colors.white,
              dividerColor: Color(0x1f6D42CE),
              focusColor: Color(0x1aF5E0C3),
              textSelectionTheme:
                  TextSelectionThemeData(cursorColor: Colors.cyan[500]),
              elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Colors.white;
                }),
              )),
              // , buttonTheme: ButtonTheme()
            ),
            darkTheme: Themes.darkTheme,
            home: Wrapper(firstLaunch)));
  }
}

bool firstLaunch;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize Firebase
  await Firebase.initializeApp();
  // lock device in portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // initialize SharedPreferences if user is logged in
  LocalDataService.preferences = await SharedPreferences.getInstance();

  firstLaunch = (!LocalDataService.hasLaunched() ||
      LocalDataService.hasLaunched() ==
          null); // firstLaunched true if hasLaunched is false (first time running app)

  /*
    1. Check if first time running app
    2. If so, check if LocalData has data to see if user is logged in
    */
  FirebaseDynamicLinks links = FirebaseDynamicLinks.instance;

  if (firstLaunch &&
      (LocalDataService.getLocalUsername() == "null" ||
          LocalDataService.getLocalUsername() == null)) {
    AuthService tempAuth = new AuthService();
    await tempAuth.signOut(); // sign user out

    // if (LocalDataService.hasCreatedDynamicLink() == null &&
    //     !(LocalDataService.getLocalUsername() == "null" ||
    //         LocalDataService.getLocalUsername() == null)) {
    // create Firebase dynamic link if necessary
    // links.buildLink();
    // LocalDataService.preferences
    //     .setBool("Created Dynamic Link", true); // update field
  }

  // else if (DatabaseService())  // check if "Contact" link has been corrupted by focus node bug (fix if necessary)
  Analytics.logAppOpen();

  // get params from deep link
  PendingDynamicLinkData linkData = await links.getInitialLink();
  // print("Deep Link Params: " + linkData.utmParameters.toString())
  runApp(MyApp(linkData));

  await LocalDataService.preferences
      .setBool("hasLaunched", true); // user has launched app

  if (linkData != null) {
    print(linkData.utmParameters);
  }
// }
}



// class RestartWidget extends StatefulWidget {
//   RestartWidget({this.child});

//   final Widget child;

//   static void restartApp(BuildContext context) {
//     context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
//   }

//   @override
//   _RestartWidgetState createState() => _RestartWidgetState();
// }

// class _RestartWidgetState extends State<RestartWidget> {
//   Key key = UniqueKey();

//   void restartApp() {
//     setState(() {
//       key = UniqueKey();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return KeyedSubtree(
//       key: key,
//       child: widget.child,
//     );
//   }
// }

