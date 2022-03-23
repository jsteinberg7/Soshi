import 'package:flutter/material.dart';

abstract class Themes {
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      backgroundColor: Color.fromARGB(255, 195, 235, 245),
      primarySwatch: MaterialColor(
        0xFFDFE8E9,
        <int, Color>{
          50: Color.fromARGB(26, 195, 243, 245),
          100: Color.fromARGB(26, 195, 243, 245),
          200: Color.fromARGB(26, 195, 243, 245),
          300: Color.fromARGB(26, 195, 243, 245),
          400: Color.fromARGB(26, 195, 243, 245),
          500: Color.fromARGB(26, 195, 243, 245),
          600: Color.fromARGB(26, 195, 243, 245),
          700: Color.fromARGB(26, 4, 13, 14),
          800: Color.fromARGB(26, 195, 243, 245),
          900: Color.fromARGB(26, 195, 243, 245),
        },
      ),
      primaryColor: Color.fromARGB(255, 179, 225, 237),
      primaryColorLight: Color.fromARGB(255, 179, 225, 237),
      primaryColorDark: Color(0xff936F3E),
      canvasColor: Color.fromARGB(255, 69, 188, 224),
      scaffoldBackgroundColor: Color.fromARGB(255, 237, 239, 243),
      bottomAppBarColor: Color(0xff6D42CE),
      cardColor: Color.fromARGB(170, 196, 188, 178),
      dividerColor: Color(0x1f6D42CE),
      focusColor: Color(0x1aF5E0C3));

  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Color(0x1f6D42CE),
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
      primaryColor: Color(0xff5D4524),
      primaryColorLight: Color(0x1a311F06),
      primaryColorDark: Color(0xff936F3E),
      canvasColor: Color(0xffE09E45),
      scaffoldBackgroundColor: Color.fromARGB(255, 96, 107, 131),
      bottomAppBarColor: Color(0xff6D42CE),
      cardColor: Color(0xaa311F06),
      dividerColor: Color(0x1f6D42CE),
      focusColor: Color(0x1a311F06));
}
