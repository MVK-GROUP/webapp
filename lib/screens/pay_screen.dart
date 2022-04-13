import 'package:flutter/material.dart';
import '../models/services.dart';
import '../widgets/main_block.dart';
import '../widgets/screen_title.dart';
import '../style.dart';
import 'global_menu.dart';

class PayScreen extends StatefulWidget {
  static const routeName = '/pay-window';

  const PayScreen({Key? key}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class OrderData {
  final String title;
  final String service;
  final String amount;
  final String currency;
  final String tariff;

  OrderData({
    required this.title,
    required this.service,
    required this.amount,
    required this.currency,
    required this.tariff,
  });
}

class _PayScreenState extends State<PayScreen> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null) {
      Navigator.pushReplacementNamed(context, MenuScreen.routeName);
      return const Scaffold(
        body: Text("Не вистачає даних"),
      );
    }
    Tariff tariff = (arguments as Map<String, dynamic>)["chosen_tariff"];
    ACLCellType cellType = arguments["cell_type"];

    final orderData = OrderData(
        title: "Оренда комірки",
        service: "Оренда комірки (${cellType.onelineTitle})",
        amount: tariff.price,
        currency: cellType.currency,
        tariff: tariff.humanHours);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: mainColor, size: 32),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ScreenTitle(
            "Оплата замовлення",
            subTitle: orderData.title,
          ),
        ),
        MainBlock(
            child: SingleChildScrollView(
                child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Оплатіть замовлення. Після сплати вам відчиниться комірка і ви зможете покласти свої речі",
                style: TextStyle(color: mainColor, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
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
                        children: payInfoTile("Послуга", orderData.service)),
                    TableRow(children: payInfoTile("Тариф", orderData.tariff)),
                    TableRow(
                        children: payInfoTile("До сплати",
                            "${orderData.amount} ${orderData.currency}")),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(MenuScreen.routeName);
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          ],
        )))
      ]),
    );
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
