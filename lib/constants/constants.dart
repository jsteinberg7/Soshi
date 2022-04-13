import 'package:flutter/material.dart';

abstract class Constants {
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
    "Personal"
  ];
  /* Instructions for injecting/adding new platforms: 
    1. Add to addedPlatforms (above)
    2. Add Logo and Writing Logo to assets
    3. Add handler to URL service
    4. Update createUserFile() in database.dart to include new platform (for accounts created in the future)
    5. Add specific parameters to platform popup in SMCard (profile.dart)
    6. Go to ios -> runner -> info.plist and add the platform name in the "LSApplicationQueriesSchemes" array
    7. Reset vscode
    8. Repeat steps 2 (Logo only) and 3 for web
  */

}
