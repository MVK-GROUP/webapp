import 'package:flutter/material.dart';

import 'style.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/qr_scanner_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVK APP',
      home: const WelcomeScreen(),
      routes: {
        AuthScreen.routeName: (ctx) => const AuthScreen(),
        OtpScreen.routeName: (ctx) => const OtpScreen(),
        QrScannerScreen.routeName: (ctx) => QrScannerScreen(),
      },
      theme: _theme(),
    );
  }

  ThemeData _theme() {
    return ThemeData(
      textTheme: const TextTheme(headline4: titleTextStyle),
    );
  }
}
