import 'package:flutter/material.dart';
import 'package:mvk_app/models/order.dart';
import 'package:provider/provider.dart';

import '../../providers/order.dart';
import '../global_menu.dart';
import '../../style.dart';
import '../../widgets/main_block.dart';
import '../../widgets/screen_title.dart';
import '../../widgets/order_tile.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = 'history/';

  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future _ordersFuture;
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
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
          iconTheme: const IconThemeData(color: mainColor, size: 32),
          actions: [
            IconButton(
              iconSize: 36,
              color: mainColor,
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, MenuScreen.routeName);
                }
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
            ),
            MainBlock(
              child: FutureBuilder(
                future: _ordersFuture,
                builder: (ctx, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (dataSnapshot.error != null) {
                      return Center(
                        child: Text("Error: ${dataSnapshot.error.toString()}"),
                      );
                    } else {
                      return Consumer<Orders>(
                        builder: (ctx, ordersData, child) => ListView.builder(
                          itemCount: ordersData.orders.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: OrderTile(
                              title: "Замовлення #${ordersData.orders[i].id}",
                              place: ordersData.orders[i].place ?? "Невідомо",
                              date: ordersData.orders[i].date,
                              onPressed: () => showOrderDetail(
                                  context, ordersData.orders[i]),
                            ),
                          ),
                        ),
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
    print("show order ${order.id}");
    showDialog(
        context: context,
        builder: (ctx) => const AlertDialog(
              title: Text("Title"),
            ));
  }
}
