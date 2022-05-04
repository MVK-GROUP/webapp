import 'package:flutter/material.dart';
import 'package:mvk_app/models/goods.dart';
//import 'dart:js' as js show context;
import '../models/lockers.dart';
import '../models/services.dart';
import '../widgets/main_block.dart';
import '../widgets/screen_title.dart';
import '../style.dart';
import '../models/order.dart';
import 'payment_check_screen.dart';
import '../utilities/urils.dart';

class PayScreen extends StatefulWidget {
  static const routeName = '/pay-window';

  const PayScreen({Key? key}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final arg = ModalRoute.of(context)?.settings.arguments;
    final check = Utils.checkRouteArg(navigator, arg);
    if (check != null) return check;

    final existArgs = arg as Map<String, Object>;

    final order = existArgs["order"] as TemporaryOrderData;

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
            subTitle: order.helperText,
          ),
        ),
        MainBlock(
            child: SingleChildScrollView(
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
                    TableRow(children: payInfoTile("Послуга", order.title)),
                    getAdditionalInfo(order)!,
                    TableRow(
                        children: payInfoTile(
                            "До сплати", order.payableWithCurrency)),
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
                        //js.context.callMethod('open', [
                        //  'https://www.liqpay.ua/api/3/checkout?data=eyJ2ZXJzaW9uIjozLCJhY3Rpb24iOiJwYXkiLCJhbW91bnQiOiI1IiwiY3VycmVuY3kiOiJVQUgiLCJkZXNjcmlwdGlvbiI6ItCi0L7QstCw0YAgMSIsInB1YmxpY19rZXkiOiJzYW5kYm94X2k4NjUzNDkxODAyMSIsImxhbmd1YWdlIjoicnUiLCJyZXN1bHRfdXJsIjoiaHR0cHM6Ly9tdmstZ3JvdXAuZ2l0aHViLmlvL3dlYmFwcC8jL3BheS13aW5kb3cifQ==&signature=lLj4McEmzmhrCuKZjuw3G0T/Zyk='
                        //]);
                        Navigator.of(context)
                            .pushReplacementNamed(PaymentCheckScreen.routeName);
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

  TableRow? getAdditionalInfo(TemporaryOrderData order) {
    switch (order.type) {
      case ServiceCategory.acl:
        final tariff =
            (order.item as Map<String, Object>)["chosen_tariff"] as Tariff;
        return TableRow(children: payInfoTile("Тариф", tariff.humanHours));
      case ServiceCategory.vendingMachine:
        return TableRow(
            children: payInfoTile("Товар", (order.item as GoodsItem).title));
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
