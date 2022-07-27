import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
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
  var isInit = false;

  Future _obtainOrdersFuture() async {
    var data = Provider.of<OrdersNotifier>(context, listen: true);
    if (data.orders == null) {
      return data.fetchAndSetOrders();
    } else {
      var isExistNewOrders = data.isExistOrdersWithStatus(
          [OrderStatus.created, OrderStatus.inProgress]);
      if (isExistNewOrders != null && isExistNewOrders) {
        return data.fetchAndSetOrders();
      } else {
        return Future.value(data.orders);
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (!isInit) {
      _ordersFuture = _obtainOrdersFuture();
      showOrderDetailFromArgs();
      isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.mainColor, size: 32),
          actions: [
            IconButton(
              iconSize: 36,
              color: AppColors.mainColor,
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, MenuScreen.routeName, (route) => false);
              },
              icon: const Icon(Icons.home),
            ),
            const SizedBox(width: 10)
          ]),
      body: SafeArea(
        child: Column(
          children: [
            ScreenTitle(
              'history.title'.tr(),
              subTitle: "history.active_orders".tr(),
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
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "history.technical_problems".tr(),
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
                                  title: "history.order_number".tr(namedArgs: {
                                    "id": ordersData.orders![i].id.toString()
                                  }),
                                  place: ordersData.orders![i].place ??
                                      "unknown".tr(),
                                  containerColor: containerColor,
                                  pointColor: pointColor,
                                  date: ordersData.orders![i].humanDate,
                                  onPressed: () =>
                                      showOrderDetail(ordersData.orders![i]),
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

  void showOrderDetail(OrderData order) async {
    await showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (ctx) => ChangeNotifierProvider.value(
              value: order,
              child: const DetailOrderNotifierDialog(),
            ));
  }

  void showOrderDetailFromArgs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg != null) {
      showOrderDetail(arg as OrderData);
    }
  }
}
