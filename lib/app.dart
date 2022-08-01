import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/providers/auth.dart';
import 'package:mvk_app/providers/order.dart';
import 'package:mvk_app/screens/acl/set_datetime.dart';
import 'package:mvk_app/screens/auth/auth_screen.dart';
import 'package:mvk_app/screens/check_payment_screen.dart';
import 'package:mvk_app/screens/confirm_locker_screen.dart';
import 'package:mvk_app/screens/waiting_splash_screen.dart';
import 'package:provider/provider.dart';

import 'style.dart';

import 'screens/qr_scanner_screen.dart';
import 'screens/global_menu.dart';
import 'screens/acl/size_selection_screen.dart';
import 'screens/pay_screen.dart';
import 'screens/success_order_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/goods/goods_screen.dart';
import 'screens/goods/all_goods_screen.dart';
import 'screens/enter_lockerid_screen.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(
      RouteSettings settings, BuildContext context, Auth auth) {
    Map? queryParameters;
    var uriData = Uri.parse(settings.name!);
    queryParameters = uriData.queryParameters;
    if (queryParameters.containsKey("locker_id") &&
        int.tryParse(queryParameters["locker_id"]) != null) {
      return MaterialPageRoute(
        builder: (context) {
          return auth.isAuth
              ? ConfirmLockerScreen(queryParameters!["locker_id"])
              : AuthScreen(prevRouteName: uriData.toString());
        },
        settings: settings,
      );
    }
    if (queryParameters.containsKey("payment-status") &&
        queryParameters.containsKey("order_id") &&
        int.tryParse(queryParameters["order_id"]) != null) {
      int orderId = int.parse(queryParameters["order_id"]);

      var paymentType = PaymentType.unknown;
      var isDebt = false;
      if (queryParameters.containsKey("type") &&
          queryParameters['type'] == 'debt') {
        isDebt = true;
      }

      if (queryParameters["payment-status"] == 'success') {
        paymentType = isDebt
            ? PaymentType.successDebtPayment
            : PaymentType.successPayment;
      }
      if (queryParameters["payment-status"] == 'error') {
        paymentType =
            isDebt ? PaymentType.errorDebtPayment : PaymentType.errorPayment;
      }

      if (paymentType != PaymentType.unknown) {
        return MaterialPageRoute(
          builder: (context) {
            return auth.isAuth
                ? CheckPaymentScreen(
                    type: paymentType,
                    orderId: orderId,
                  )
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? const WaitingSplashScreen()
                            : const AuthScreen(),
                  );
          },
          settings: settings,
        );
      }
    }
    return MaterialPageRoute(
      builder: (context) {
        return auth.isAuth
            ? const MenuScreen()
            : AuthScreen(prevRouteName: uriData.toString());
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
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, LockerNotifier>(
            create: (context) => LockerNotifier(null, null, lang: 'en'),
            update: (context, auth, previousOrders) => LockerNotifier(
                previousOrders?.locker, auth.token,
                lang: context.locale.languageCode),
          ),
          ChangeNotifierProvider.value(value: ServiceNotifier()),
          ChangeNotifierProxyProvider<Auth, OrdersNotifier>(
            create: (context) => OrdersNotifier(null, null),
            update: (context, auth, previousOrders) =>
                OrdersNotifier(auth.token, previousOrders?.orders),
          ),
        ],
        child: Consumer<Auth>(builder: (ctx, auth, _) {
          return MaterialApp(
            title: 'Smart Locker',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: auth.isAuth
                ? const MenuScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? const WaitingSplashScreen()
                            : const AuthScreen()),
            routes: {
              EnterLockerIdScreen.routeName: (ctx) =>
                  const EnterLockerIdScreen(),
              SizeSelectionScreen.routeName: (ctx) =>
                  const SizeSelectionScreen(),
              AuthScreen.routeName: (ctx) => const AuthScreen(),
              QrScannerScreen.routeName: (ctx) => QrScannerScreen(),
              MenuScreen.routeName: (ctx) => const MenuScreen(),
              PayScreen.routeName: (ctx) => const PayScreen(),
              SuccessOrderScreen.routeName: (ctx) => const SuccessOrderScreen(),
              HistoryScreen.routeName: (ctx) => const HistoryScreen(),
              GoodsScreen.routeName: (ctx) => const GoodsScreen(),
              AllGoodsScreen.routeName: (ctx) => const AllGoodsScreen(),
              SetACLDateTimeScreen.routeName: (ctx) =>
                  const SetACLDateTimeScreen(),
            },
            onGenerateRoute: (RouteSettings settings) =>
                RouteGenerator.generateRoute(settings, context, auth),
            theme: _theme(),
          );
        }));
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
