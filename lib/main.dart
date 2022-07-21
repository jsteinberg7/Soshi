import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/localData.dart';
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

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return StreamProvider<User>.value(
        value: AuthService().user,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              textTheme: GoogleFonts.interTextTheme(),

              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              }),
              brightness: Theme.of(context).brightness,
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
              //primaryColor: Color.fromARGB(255, 179, 225, 237),
              primaryColorLight: Color.fromARGB(255, 179, 225, 237),
              // primaryColorDark: Colors.grey[850],
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
            darkTheme: ThemeData(
                textTheme: GoogleFonts.interTextTheme(),
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                }),
                brightness: Brightness.dark,
                backgroundColor: Colors.grey[850],
                primarySwatch: MaterialColor(
                  0xFFF5E0C3,
                  <int, Color>{
                    50: Color(0x1a5D4524),
                    100: Color(0xa15D4524),
                    200: Color(0xaa5D4524),
                    300: Color(0xaf5D4524),
                    400: Color(0x1a483112),
                    500: Color(0xa1483112),
                    600: Color(0xaa483112),
                    700: Color(0xff483112),
                    800: Color(0xaf2F1E06),
                    900: Color(0xff2F1E06)
                  },
                ),
                primaryColor: Colors.grey[850],
                primaryColorLight: Color(0x1a311F06),
                primaryColorDark: Colors.black,
                canvasColor: Colors.grey[850],
                scaffoldBackgroundColor: Colors.grey[900],
                bottomAppBarColor: Color(0xff6D42CE),
                cardColor: Colors.grey[900],
                dividerColor: Color(0x1f6D42CE),
                elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ButtonStyle(
                  // MaterialStateProperty.resolveWith<TextStyle>(Set<MaterialState> states) {
                  //   return TextStyle(color: Colors.white);
                  // }

                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    return Colors.grey[900];
                  }),
                  elevation: MaterialStateProperty.resolveWith<double>(
                      (Set<MaterialState> states) {
                    return 5.0;
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    return Colors.white;
                  }),
                )),
                focusColor: Color(0x1a311F06)),
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

  if ((LocalDataService.getLocalUsername() == "null" ||
      LocalDataService.getLocalUsername() == null)) {
    // check if user is signed in
    if (firstLaunch) {
      AuthService tempAuth = new AuthService();
      await tempAuth.signOut(); // sign user out

      // if (LocalDataService.hasCreatedDynamicLink() == null &&
      //     !(LocalDataService.getLocalUsername() == "null" ||
      //         LocalDataService.getLocalUsername() == null)) {
      // create Firebase dynamic link if necessary
      // links.buildLink();
      // LocalDataService.preferences
      //     .setBool("Created Dynamic Link", true); // update field
    } else {
      // if signed in and not first launch
      if (LocalDataService.friendsListReformatted() == null &&
          !LocalDataService.getLocalFriendsList().isEmpty) {
        // check if friendsList has been reformatted
        // if null, reformated friends list
        await LocalDataService
            .reformatFriendsList(); // should only ever run once per user
      }
    }
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

  // pull friendslist data to ensure up to date (name, bio, verified) ** USER MUST BE LOGGED IN
}
