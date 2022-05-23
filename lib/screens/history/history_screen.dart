import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvk_app/models/order.dart';
import 'package:provider/provider.dart';

import '../../providers/order.dart';
import '../global_menu.dart';
import '../../style.dart';
import '../../widgets/main_block.dart';
import '../../widgets/screen_title.dart';
import '../../widgets/order_tile.dart';
import 'detail_order_dialog.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = 'history/';

  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    var data = Provider.of<OrdersNotifier>(context, listen: false);
    if (data.orders == null) {
      return data.fetchAndSetOrders();
    } else {
      var isExistNewOrders = data.isExistOrdersWithStatus(
          [OrderStatus.created, OrderStatus.inProgress]);
      if (isExistNewOrders != null && isExistNewOrders) {
        print("exist new orders");
        return data.fetchAndSetOrders();
      } else {
        return Future.value(data.orders);
      }
    }
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

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
        child: Column(
          children: [
            const ScreenTitle(
              'Історія',
              subTitle: "Активні та виконані замовлення",
              height: 120,
            ),
            MainBlock(
              child: FutureBuilder(
                future: _ordersFuture,
                builder: (ctx, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (dataSnapshot.error != null) {
                      print("Error: ${dataSnapshot.error.toString()}");
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "На жаль не можемо відобразити Ваші замовлення через технічні проблеми",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else {
                      return Consumer<OrdersNotifier>(
                        builder: (ctx, ordersData, child) => ListView.builder(
                            itemCount: ordersData.orders == null
                                ? 0
                                : ordersData.orders!.length,
                            itemBuilder: (ctx, i) {
                              Color containerColor =
                                  ordersData.orders![i].status ==
                                          OrderStatus.completed
                                      ? const Color.fromARGB(255, 230, 228, 228)
                                      : Colors.white;
                              Color? pointColor;
                              if ([OrderStatus.error, OrderStatus.expired]
                                  .contains(ordersData.orders![i].status)) {
                                pointColor = AppColors.dangerousColor;
                              } else if ([
                                OrderStatus.created,
                                OrderStatus.inProgress,
                              ].contains(ordersData.orders![i].status)) {
                                pointColor = AppColors.successColor;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: OrderTile(
                                  title:
                                      "Замовлення #${ordersData.orders![i].id}",
                                  place:
                                      ordersData.orders![i].place ?? "Невідомо",
                                  containerColor: containerColor,
                                  pointColor: pointColor,
                                  date: ordersData.orders![i].humanDate,
                                  onPressed: () => showOrderDetail(
                                      context, ordersData.orders![i]),
                                ),
                              );
                            }),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showOrderDetail(BuildContext context, OrderData order) {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (ctx) => DetailOrderDialog(
        order: order,
      ),
    );
  }
}
