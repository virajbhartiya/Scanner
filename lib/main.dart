import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scan/screens/home_screen.dart';
import 'package:scan/screens/view_document.dart';

import 'screens/splash_screen.dart';
import 'themeConfig.dart';

void main() async {
  runApp(Scan());
}

class Scan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
    ));
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    return MaterialApp(
      title: "Scan",
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      initialRoute: SplashScreen.route,
      routes: {
        SplashScreen.route: (context) => SplashScreen(),
        HomeScreen.route: (context) => HomeScreen(),
        ViewDocument.route: (context) => ViewDocument(),
      },
    );
  }
}
