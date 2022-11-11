import 'package:flutter/material.dart';

abstract class Constants {
  static Widget makeBlueShadowButton(
      String title, IconData iconData, Function clickFunction) {
    return InkWell(
      onTap: clickFunction,
      child: Center(
        child: Container(
          width: 300,
          decoration: cyanShadowDecoration,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              iconData != null
                  ? Icon(
                      iconData,
                      color: Colors.cyan[300],
                      size: 30,
                    )
                  : Container(),
              SizedBox(width: 10),
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold))
            ]),
          ),
        ),
      ),
    );
  }

  static Widget makeRedShadowButton(
      String title, IconData iconData, Function clickFunction) {
    return InkWell(
      onTap: clickFunction,
      child: Center(
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.red,
                spreadRadius: 0.1,
                blurRadius: 10,
                blurStyle: BlurStyle.outer,
                // offset: Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              iconData != null
                  ? Icon(
                      iconData,
                      color: Colors.red,
                      size: 30,
                    )
                  : Container(),
              SizedBox(width: 10),
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red))
            ]),
          ),
        ),
      ),
    );
  }

  static Widget makeBlueShadowButtonSmall(
      String title, IconData iconData, Function clickFunction) {
    return InkWell(
      onTap: clickFunction,
      child: Center(
        child: Container(
          // width: 300,
          decoration: cyanShadowDecoration,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                iconData,
                color: Colors.cyan[300],
                size: 20,
              ),
              SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ]),
          ),
        ),
      ),
    );
  }

  static BoxDecoration cyanShadowDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    boxShadow: [
      BoxShadow(
        color: Colors.cyan,
        spreadRadius: 0.1,
        blurRadius: 10,
        blurStyle: BlurStyle.outer,
        // offset: Offset(0, 0), // changes position of shadow
      ),
    ],
  );

  static TextStyle CustomCyan = new TextStyle(
      color: Colors.cyan[300],
      fontSize: 15,
      letterSpacing: 2,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold);

  static Color appBarColor = Colors.grey[850];

  static Color backgroundColor = Colors.grey[800];

  static Color buttonColorLight = Colors.grey[700];

  static Color buttonColorDark = Colors.grey[850];

  static ButtonStyle ButtonStyleDark = ElevatedButton.styleFrom(
      primary: Constants.buttonColorDark,
      shadowColor: Constants.buttonColorDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))));

  static ButtonStyle ButtonStyleClear = ElevatedButton.styleFrom(
      primary: Colors.transparent,
      shadowColor: Constants.buttonColorDark,
      side: BorderSide(color: Colors.cyanAccent),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))));

  static LinearGradient greyCyanGradient = new LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [Colors.grey[800], Colors.cyan[300]]);

  // static Gradient gradientForPlatform(String platform) {
  //   List<Color> colors = [];
  //   if (platform == "Snapchat") {
  //     colors = [Colors.yellow[400], Colors.yellow[200]];
  //   } else if (platform == "Instagram") {
  //     colors = [
  //       Color.fromARGB(255, 245, 133, 41),
  //       Color.fromARGB(255, 254, 218, 119),
  //       Color.fromARGB(255, 221, 42, 123),
  //       Color.fromARGB(255, 129, 52, 175),
  //       Color.fromARGB(255, 81, 91, 212)
  //     ];
  //   } else if (platform == "Facebook") {
  //     colors = [Colors.blue[900], Colors.blue[900]];
  //   } else if (platform == "Twitter") {
  //     colors = [Colors.cyan[600], Colors.lightBlue];
  //   } else {
  //     colors = [Colors.grey[800], Colors.grey[900]];
  //   }
  //   return new LinearGradient(
  //       colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight);
  // }

  // all platforms in original app
  static List<String> originalPlatforms = [
    "Phone",
    "Instagram",
    "Snapchat",
    "Linkedin",
    "Twitter",
    "Facebook",
    "Reddit",
    "Tiktok",
    "Discord",
  ];

  // list of all platforms added since initial launch (update when adding new platforms)
  static List<String> addedPlatforms = [
    "Email",
    "Venmo",
    "Spotify",
    "Contact",
    "Personal",
    "Youtube",
    "Vsco",
    "AppleMusic",
    "CashApp",
    // "Soundcloud"
    "BeReal",
    "OnlyFans",
    //"Cryptowallet"
  ];
  /* Instructions for injecting/adding new platforms (OLD): 
    1. Add to addedPlatforms (above)
    2. Add Logo and Writing Logo to assets
    3. Add handler to URL service
    4. Add hinttext and indicator params to editHandles.dart --> SMCard
    5. Update createUserFile() in database.dart to include new platform (for new accounts)
    6. (OLD) Add specific parameters to platform popup in SMCard (profile.dart)
    7. Reset vscode
    8. Repeat steps 2 (Logo only) and 3 for web
  */

}
