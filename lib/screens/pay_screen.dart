import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:js' as js show context;
import '../api/orders.dart';
import '../models/lockers.dart';
import '../models/services.dart';
import '../providers/auth.dart';
import '../widgets/main_block.dart';
import '../widgets/screen_title.dart';
import '../style.dart';
import '../models/order.dart';
import 'global_menu.dart';

class PayScreen extends StatefulWidget {
  static const routeName = '/pay-window';

  const PayScreen({Key? key}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  late OrderData order;
  String? token;
  late Locker? locker;
  String? helperText;
  Map<String, Object>? item;
  Timer? timer;
  var _isInit = false;
  var _isCheckingOrderStatus = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      token = Provider.of<Auth>(context).token;
      locker = Provider.of<LockerNotifier>(context).locker;
      if (arg == null || locker == null) {
        Navigator.pushReplacementNamed(context, MenuScreen.routeName);
        return;
      }

      final existArgs = arg as Map<String, Object>;
      order = existArgs["order"] as OrderData;
      helperText = existArgs["title"] as String;
      item = existArgs["item"] as Map<String, Object>;

      setState(() {
        _isCheckingOrderStatus = true;
      });

      timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        try {
          var checkedOrder = await OrderApi.fetchOrderById(order.id, token);

          if (checkedOrder.status == OrderStatus.created) {
            timer.cancel();
            setState(() {
              _isCheckingOrderStatus = false;
            });
          } else if (checkedOrder.status == OrderStatus.error) {
            throw Exception(
                "Сталась технічна проблема при створенні замовлення");
          }
        } catch (e) {
          timer.cancel();
          showDialog(
              context: context,
              builder: (ctx) => const AlertDialog(
                    content: Text(
                        "Не вдалось перевірити статус замовлення. Спробуйте створити нове замовлення"),
                  ));
          setState(() {
            _isCheckingOrderStatus = false;
          });
        }
      });

      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.mainColor, size: 32),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ScreenTitle(
            "Оплата замовлення",
            subTitle: helperText,
          ),
        ),
        MainBlock(
            child: _isCheckingOrderStatus
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Почекайте, створюється замовлення...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ]),
                  )
                : SingleChildScrollView(
                    child: Column(
                    children: [
                      Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Column(children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Image.asset("assets/logo/liqpay_logo.png"),
                          ),
                          const SizedBox(height: 20),
                          Table(
                            children: [
                              TableRow(
                                  children:
                                      payInfoTile("Послуга", order.title)),
                              getAdditionalInfo(order)!,
                              TableRow(
                                  children: payInfoTile(
                                      "До сплати", order.humanPrice)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                onPressed: () {
                                  print("payData: ${order.payData}");
                                  print("paySignature: ${order.paySignature}");
                                  js.context.callMethod('openLiqpay',
                                      [order.payData, order.paySignature]);

                                  //Navigator.of(context).pushNamedAndRemoveUntil(
                                  //    PaymentCheckScreen.routeName,
                                  //    (route) => false,
                                  //    arguments: {
                                  //      "order": order,
                                  //      "title": helperText ?? ""
                                  //    });
                                },
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: const [
                                          Text(
                                            "Перейти до оплати",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Icon(Icons.keyboard_arrow_right),
                                        ]))),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(context,
                                MenuScreen.routeName, (route) => false);
                          },
                          child: const Text(
                              "Відмінити оплату та перейти до головного меню",
                              textAlign: TextAlign.center))
                    ],
                  )))
      ]),
    );
  }

  TableRow? getAdditionalInfo(OrderData order) {
    switch (order.service) {
      case ServiceCategory.acl:
        final tariff = item!["chosen_tariff"] as Tariff;
        return TableRow(children: payInfoTile("Тариф", tariff.humanHours));
      case ServiceCategory.vendingMachine:
        return TableRow(
            children: payInfoTile("Товар", item!["title"] as String));
      case ServiceCategory.laundry:
        return TableRow(children: payInfoTile("Категорія", "10kg"));
      default:
        return null;
    }
  }

  List<Widget> payInfoTile(String left, String right) {
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text(
          left,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text(
          right,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ];
  }
}
