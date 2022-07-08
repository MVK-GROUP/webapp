import 'package:flutter/material.dart';
import 'package:mvk_app/api/orders.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/screens/information_screen.dart';
import 'package:mvk_app/screens/success_order_screen.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/auth.dart';
import '../providers/order.dart';

enum SplashScreenType {
  justSplashScreen,
  checkPayment,
}

class SplashScreen extends StatefulWidget {
  final SplashScreenType type;
  final Object? data;

  const SplashScreen(
      {this.type = SplashScreenType.justSplashScreen, this.data, Key? key})
      : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isInit = false;
  String? token;
  Future? _initFuture;
  late OrderData orderData;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!isInit) {
      _initFuture = _obtainInitFuture();
      isInit = true;
    }
    super.didChangeDependencies();
  }

  Future<int> _obtainInitFuture() async {
    if (widget.type == SplashScreenType.checkPayment) {
      token = Provider.of<Auth>(context).token;
      final orderId = widget.data as int;

      try {
        await Provider.of<OrdersNotifier>(context, listen: false)
            .fetchAndSetOrders();
        await Provider.of<LockerNotifier>(context, listen: false)
            .setLockerByOrderId(orderId);
      } catch (e) {}
      try {
        orderData = await OrderApi.checkPaymentByOrderId(orderId, token);
        String? title;
        if (orderData.status == OrderStatus.hold) {
          title =
              "Нарешті тепер Ви можете відчинити комірку та покласти свої. Відчинити можете тут, або в історії замовлень";
        } else {
          title =
              "Зачекайте декілька секунд для можливості одразу відчинити комірку або зробіть це в історії замовлень”";
        }

        Navigator.pushNamedAndRemoveUntil(
            context, SuccessOrderScreen.routeName, (route) => false,
            arguments: {"order": orderData, "title": title});
        return 1;
      } catch (e) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ErrorPaymentScreen(title: e.toString())),
            (route) => false);
        return -1;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: _initFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                        child: Text(
                          "Зачекайте, іде перевірка замовленя...",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center();
              }
            }));
  }
}
