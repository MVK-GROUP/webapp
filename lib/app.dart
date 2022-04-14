import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'style.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/global_menu.dart';
import 'screens/size_selection_screen.dart';
import 'screens/pay_screen.dart';
import 'screens/payment_check_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MVK APP',
      home: const MenuScreen(),
      routes: {
        SizeSelectionScreen.routeName: (ctx) => const SizeSelectionScreen(),
        WelcomeScreen.routeName: (ctx) => const WelcomeScreen(),
        AuthScreen.routeName: (ctx) => const AuthScreen(),
        OtpScreen.routeName: (ctx) => const OtpScreen(),
        QrScannerScreen.routeName: (ctx) => QrScannerScreen(),
        MenuScreen.routeName: (ctx) => const MenuScreen(),
        PayScreen.routeName: (ctx) => const PayScreen(),
        PaymentCheckScreen.routeName: (ctx) => const PaymentCheckScreen(),
      },
      theme: _theme(),
    );
  }

  ThemeData _theme() {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.openSansTextTheme(
        const TextTheme(
          headline4: titleSecondaryTextStyle,
          headline2: titleTextStyle,
          bodyText1: bodyText1,
        ),
      ),
      colorScheme: ThemeData()
          .colorScheme
          .copyWith(primary: mainColor, secondary: secondaryColor),
    );
  }
}
