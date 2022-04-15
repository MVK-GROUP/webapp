import 'package:flutter/material.dart';
import 'package:mvk_app/models/order.dart';
import 'package:mvk_app/widgets/button.dart';
import 'package:mvk_app/widgets/main_button.dart';
import 'package:provider/provider.dart';

import '../../providers/order.dart';
import '../global_menu.dart';
import '../../style.dart';
import '../../widgets/main_block.dart';
import '../../widgets/screen_title.dart';
import '../../widgets/order_tile.dart';
import '../../widgets/dialog.dart';
import '../../widgets/order_element_widget.dart';

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
                //if (Navigator.canPop(context)) {
                //  Navigator.pop(context);
                //} else {
                //  Navigator.pushReplacementNamed(context, MenuScreen.routeName);
                //}
                Navigator.pushReplacementNamed(context, MenuScreen.routeName);
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
    showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (ctx) => DefaultDialog(
            maxHeight: 560,
            title: "Замовлення ${order.id}",
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: OrderElementWidget(
                      iconData: Icons.location_on,
                      text: order.place ?? "Невідомо",
                      iconSize: 26,
                      textStyle: bodyText2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: OrderElementWidget(
                      iconData: Icons.shopping_bag_outlined,
                      text: order.title,
                      iconSize: 26,
                      textStyle: bodyText2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: OrderElementWidget(
                      iconData: Icons.calendar_month,
                      text: order.date,
                      iconSize: 26,
                      textStyle: bodyText2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: OrderElementWidget(
                      iconData: Icons.attach_money,
                      text: order.humanPrice,
                      iconSize: 26,
                      textStyle: bodyText2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Оренда до: 19.05.2021 21:43",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Залишилось: 20 хвилин",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    "Після закінченя терміну аренди вам необхідно буде сплатити суму заборгованості",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    child: Column(children: [
                      const Text(
                        "ДІЇ",
                        style: bodyText2,
                      ),
                      const SizedBox(height: 10),
                      ElevatedDefaultButton(
                          buttonColor: dangerousColor,
                          child: const Text(
                            "Завершити оренду",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      const SizedBox(height: 10),
                      ElevatedDefaultButton(
                          child: const Text(
                            "Відчинити комірку",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ]),
                  )
                ]),
              ),
            )));
  }
}
