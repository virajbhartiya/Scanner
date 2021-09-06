import 'package:flutter/material.dart';

class ThemeConfig {
  static const Color lightPrimary = Colors.white;
  static const Color darkPrimary = Color(0xff1f1f1f);
  static const Color lightBG = Colors.white;
  static const Color darkBG = Color(0xff121212);

  static Color accent = Colors.green;

  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    accentColor: accent,
    // ignore: deprecated_member_use
    cursorColor: accent,
    scaffoldBackgroundColor: lightBG,
    appBarTheme: AppBarTheme(elevation: 0.0),
  );
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: accent,
    scaffoldBackgroundColor: darkBG,
    // ignore: deprecated_member_use
    cursorColor: accent,
    appBarTheme: AppBarTheme(elevation: 0.0),
  );
}
