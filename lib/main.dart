import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/runtimeManager.dart';
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return StreamProvider<User>.value(
        value: AuthService().user,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            theme: ThemeData(
              fontFamily: GoogleFonts.inter().fontFamily,

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
              dividerTheme: DividerThemeData(thickness: .2, indent: 0, endIndent: 0, color: Colors.grey),
              focusColor: Color(0x1aF5E0C3),
              textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.cyan[500]),
              elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  return Colors.white;
                }),
              )),
              // , buttonTheme: ButtonTheme()
            ),
            darkTheme: ThemeData(
                fontFamily: GoogleFonts.inter().fontFamily,
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
                dividerTheme: DividerThemeData(thickness: .2, indent: 0, endIndent: 0, color: Colors.grey),
                primaryColorDark: Colors.black,
                canvasColor: Colors.grey[850],
                scaffoldBackgroundColor: Colors.grey[900],
                bottomAppBarColor: Color(0xff6D42CE),
                cardColor: Colors.grey[900],
                textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.cyan[500]),
                elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ButtonStyle(
                  // MaterialStateProperty.resolveWith<TextStyle>(Set<MaterialState> states) {
                  //   return TextStyle(color: Colors.white);
                  // }

                  backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    return Colors.grey[900];
                  }),
                  elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) {
                    return 5.0;
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    return Colors.white;
                  }),
                )),
                focusColor: Color(0x1a311F06)),
            home: Wrapper()));
  }
}

void main() async {
  print("hot restart main running");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FirebaseDynamicLinks links = FirebaseDynamicLinks.instance;
  Analytics.logAppOpen();
  PendingDynamicLinkData linkData = await links.getInitialLink();

  // HasLaunched, firstSwitch, etc.
  await RuntimeManager.sync();

//   // //Pull latest data from SharedPref/Cloud

  //  await DataEngine.initialize();
  // await DataEngine.forceClear();
  // AuthService authService = new AuthService();
  // await authService.signOut();
  // var prefs = await SharedPreferences.getInstance();

  runApp(MyApp(linkData));

  if (linkData != null) {
    print(linkData.utmParameters);
  }
}
