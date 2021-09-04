import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scan/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  static String route = 'SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool visitingFlag = false;
  bool databaseFlag = false;

  void getFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getBool("alreadyVisited") != null) {
      visitingFlag = true;
    }
    await preferences.setBool('alreadyVisited', true);
    if (preferences.getBool("database") != null) {
      databaseFlag = true;
    }
    await preferences.setBool('database', true);
  }

  void getTimerWid() {
    Timer(
      Duration(milliseconds: 500),
      () => Navigator.of(context).pushReplacementNamed(HomeScreen.route),
    );
  }

  @override
  void initState() {
    super.initState();
    getFlag();
    getTimerWid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: primaryColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 7,
            ),
            Text("Scan",
                style: GoogleFonts.quicksand(
                    color: Theme.of(context).accentColor,
                    fontSize: 50,
                    fontWeight: FontWeight.bold)),
            Spacer(
              flex: 10,
            ),
          ],
        ),
      ),
    );
  }
}
