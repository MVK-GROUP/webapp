import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvk_app/models/order.dart';
import 'package:provider/provider.dart';

import '../global_menu.dart';
import '../../style.dart';
import '../../widgets/main_block.dart';
import '../../widgets/screen_title.dart';
import '../../widgets/order_tile.dart';
import '../history/detail_order_dialog.dart';

class ChooseOrderScreen extends StatelessWidget {
  static const routeName = 'choose-order/';

  final List<OrderData> orders;

  const ChooseOrderScreen({required this.orders, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.mainColor, size: 32),
          actions: [
            IconButton(
              iconSize: 36,
              color: AppColors.mainColor,
              onPressed: () {
                //if (Navigator.canPop(context)) {
                //  Navigator.pop(context);
                //} else {
                //  Navigator.pushReplacementNamed(context, MenuScreen.routeName);
                //}
                Navigator.pushNamedAndRemoveUntil(
                    context, MenuScreen.routeName, (route) => false);
                //Navigator.pushReplacementNamed(context, MenuScreen.routeName);
              },
              icon: const Icon(Icons.home),
            ),
            const SizedBox(width: 10)
          ]),
      body: SafeArea(
        child: Column(children: [
          const ScreenTitle(
            'Оберіть замовлення',
            subTitle: "Ви маєте декілька активних замовлень. Оберіть потрібний",
            height: 120,
          ),
          MainBlock(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: OrderTile(
                  title: "Замовлення #${orders[i].id}",
                  place: orders[i].place ?? "Невідомо",
                  //pointColor: pointColor,
                  date: orders[i].humanDate,
                  onPressed: () => showOrderDetail(context, orders[i]),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  void showOrderDetail(BuildContext context, OrderData order) async {
    await showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (ctx) => ChangeNotifierProvider.value(
              value: order,
              child: const DetailOrderNotifierDialog(),
            ));
  }
}
