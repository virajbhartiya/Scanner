import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  static const Color lightPrimary = Colors.white;
  static const Color darkPrimary = Color(0xff1f1f1f);
  static const Color lightBG = Colors.white;
  static const Color darkBG = Color(0xff121212);

  // static const Color accent = Color.fromRGBO(71, 92, 122, 1); //* origonal
  // static const Color accent = Color.fromRGBO(154, 42, 42, 1); //* garnet
  // static const Color accent = Color.fromRGBO(161, 99, 247, 1); //** purple
  // static const Color accent = Color.fromRGBO(165, 230, 90, 1); // * neon green
  // static const Color accent = Color.fromRGBO(204, 245, 100, 1); //* light green
  static Color accent = Colors.blue; //* cyan

  static ThemeData lightTheme = ThemeData(
      backgroundColor: lightBG,
      primaryColor: lightPrimary,
      accentColor: accent,
      // ignore: deprecated_member_use
      cursorColor: accent,
      scaffoldBackgroundColor: lightBG,
      appBarTheme: AppBarTheme(elevation: 0.0),
      textTheme: TextTheme(
        headline1: GoogleFonts.quicksand(),
        headline2: GoogleFonts.quicksand(),
        headline3: GoogleFonts.quicksand(),
        headline4: GoogleFonts.quicksand(),
        headline5: GoogleFonts.quicksand(),
        headline6: GoogleFonts.quicksand(),
        bodyText1: GoogleFonts.quicksand(),
        bodyText2: GoogleFonts.quicksand(),
        button: GoogleFonts.quicksand(),
        caption: GoogleFonts.quicksand(),
        overline: GoogleFonts.quicksand(),
      ));

  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      backgroundColor: darkBG,
      primaryColor: darkPrimary,
      accentColor: accent,
      scaffoldBackgroundColor: darkBG,
      // ignore: deprecated_member_use
      cursorColor: accent,
      appBarTheme: AppBarTheme(elevation: 0.0),
      textTheme: TextTheme(
        headline1: GoogleFonts.quicksand(),
        headline2: GoogleFonts.quicksand(),
        headline3: GoogleFonts.quicksand(),
        headline4: GoogleFonts.quicksand(),
        headline5: GoogleFonts.quicksand(),
        headline6: GoogleFonts.quicksand(),
        bodyText1: GoogleFonts.quicksand(),
        bodyText2: GoogleFonts.quicksand(),
        button: GoogleFonts.quicksand(),
        caption: GoogleFonts.quicksand(),
        overline: GoogleFonts.quicksand(),
      ));
}
