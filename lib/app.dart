import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/providers/order.dart';
import 'package:mvk_app/screens/acl/set_datetime.dart';
import 'package:mvk_app/screens/confirm_locker_screen.dart';
import 'package:provider/provider.dart';

import 'style.dart';

import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/global_menu.dart';
import 'screens/size_selection_screen.dart';
import 'screens/pay_screen.dart';
import 'screens/payment_check_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/goods/goods_screen.dart';
import 'screens/goods/all_goods_screen.dart';
import 'screens/enter_lockerid_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(
      RouteSettings settings, BuildContext context) {
    if (settings.name == null || settings.name == null) {
      return MaterialPageRoute(
        builder: (context) {
          return const EnterLockerIdScreen();
        },
        settings: settings,
      );
    }

    Map? queryParameters;
    var uriData = Uri.parse(settings.name!);
    queryParameters = uriData.queryParameters;
    if (queryParameters.containsKey("locker_id") &&
        int.tryParse(queryParameters["locker_id"]) != null) {
      return MaterialPageRoute(
        builder: (context) {
          return ConfirmLockerScreen(queryParameters!["locker_id"]);
        },
        settings: settings,
      );
    }
    return MaterialPageRoute(
      builder: (context) {
        return const EnterLockerIdScreen();
      },
      settings: settings,
    );
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => LockerNotifier()),
        ChangeNotifierProvider(create: (ctx) => ServiceNotifier()),
        ChangeNotifierProvider(create: (ctx) => OrdersNotifier()),
      ],
      child: MaterialApp(
        title: 'MVK APP',
        home: const EnterLockerIdScreen(), // SetACLDateTimeScreen(),
        routes: {
          EnterLockerIdScreen.routeName: (ctx) => const EnterLockerIdScreen(),
          SizeSelectionScreen.routeName: (ctx) => const SizeSelectionScreen(),
          WelcomeScreen.routeName: (ctx) => const WelcomeScreen(),
          AuthScreen.routeName: (ctx) => const AuthScreen(),
          OtpScreen.routeName: (ctx) => const OtpScreen(),
          QrScannerScreen.routeName: (ctx) => QrScannerScreen(),
          MenuScreen.routeName: (ctx) => const MenuScreen(),
          PayScreen.routeName: (ctx) => const PayScreen(),
          PaymentCheckScreen.routeName: (ctx) => const PaymentCheckScreen(),
          HistoryScreen.routeName: (ctx) => const HistoryScreen(),
          GoodsScreen.routeName: (ctx) => const GoodsScreen(),
          AllGoodsScreen.routeName: (ctx) => const AllGoodsScreen(),
          SetACLDateTimeScreen.routeName: (ctx) => const SetACLDateTimeScreen(),
        },
        onGenerateRoute: (RouteSettings settings) =>
            RouteGenerator.generateRoute(settings, context),
        theme: _theme(),
      ),
    );
  }

  ThemeData _theme() {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.openSansTextTheme(
        const TextTheme(
          headline4: AppStyles.titleSecondaryTextStyle,
          headline2: AppStyles.titleTextStyle,
          bodyText1: AppStyles.bodyText1,
        ),
      ),
      colorScheme: ThemeData().colorScheme.copyWith(
          primary: AppColors.mainColor, secondary: AppColors.secondaryColor),
    );
  }
}
