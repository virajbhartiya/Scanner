import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scan/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  static String route = 'SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void getTimerWid() {
    Timer(
      Duration(milliseconds: 500),
      () => Navigator.of(context).pushReplacementNamed(HomeScreen.route),
    );
  }

  @override
  void initState() {
    super.initState();
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
                )),
            Spacer(
              flex: 10,
            ),
          ],
        ),
      ),
    );
  }
}
