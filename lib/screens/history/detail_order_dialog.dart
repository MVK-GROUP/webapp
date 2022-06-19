import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvk_app/providers/auth.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../style.dart';
import '../../widgets/dialog.dart';
import '../../widgets/order_element_widget.dart';
import 'order_actions_widget.dart';

class DetailOrderNotifierDialog extends StatefulWidget {
  const DetailOrderNotifierDialog({Key? key}) : super(key: key);

  @override
  State<DetailOrderNotifierDialog> createState() =>
      _DetailOrderNotifierDialogState();
}

class _DetailOrderNotifierDialogState extends State<DetailOrderNotifierDialog> {
  late OrderData order;
  var _isInit = false;
  Timer? timer;
  var _isOrderLoading = false;
  String? token;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      token = Provider.of<Auth>(context, listen: false).token;
      order = Provider.of<OrderData>(context, listen: true);
      _isOrderLoading = false;
      if ([OrderStatus.created, OrderStatus.inProgress]
          .contains(order.status)) {
        setState(() {
          _isOrderLoading = true;
        });
        checkOrder();

        timer = Timer.periodic(const Duration(seconds: 2, milliseconds: 500),
            (timer) {
          checkOrder();
          print("order status: ${order.status}");
          if (![OrderStatus.created, OrderStatus.inProgress]
              .contains(order.status)) {
            timer.cancel();
            setState(() {
              _isOrderLoading = false;
            });
          }
          // GET ORDER STATUS
        });
      } else if (order.status == OrderStatus.error) {
        checkOrder();
        setState(() {
          _isOrderLoading = false;
        });
      }
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  String get orderStatusText {
    var text = "Статус замовлення: ";
    switch (order.status) {
      case OrderStatus.canceled:
        text += "скасовано";
        break;
      case OrderStatus.error:
        text += "помилка";
        break;
      case OrderStatus.expired:
        text += "вийшов час";
        break;
      case OrderStatus.hold:
        text += "активний";
        break;
      case OrderStatus.active:
        text += "виконується";
        break;
      case OrderStatus.inProgress:
        text += "в процесі";
        break;
      case OrderStatus.created:
        text += "в процесі";
        break;
      case OrderStatus.completed:
        text += "виконано";
        break;
      default:
    }
    if ([OrderStatus.created, OrderStatus.inProgress, OrderStatus.hold]
            .contains(order.status) &&
        order.isExpired) {
      text = "Статус замовлення: час вийшов";
    }
    return text;
  }

  Color get orderStatusColor {
    if ([OrderStatus.created, OrderStatus.inProgress, OrderStatus.hold]
            .contains(order.status) &&
        order.isExpired) {
      return AppColors.dangerousColor;
    }
    if ([
      OrderStatus.hold,
      OrderStatus.inProgress,
      OrderStatus.created,
      OrderStatus.active,
      OrderStatus.completed
    ].contains(order.status)) {
      return AppColors.successColor;
    } else {
      return AppColors.dangerousColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      useProgressBar: _isOrderLoading,
      maxHeight: 600,
      title: "Замовлення #${order.id}",
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: OrderElementWidget(
                iconData: Icons.location_on,
                text: order.place ?? "Невідомо",
                iconSize: 26,
                textStyle: AppStyles.bodyText2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: OrderElementWidget(
                iconData: Icons.shopping_bag_outlined,
                text: order.title,
                iconSize: 26,
                textStyle: AppStyles.bodyText2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: OrderElementWidget(
                iconData: Icons.calendar_month,
                text: order.humanDate,
                iconSize: 26,
                textStyle: AppStyles.bodyText2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: OrderElementWidget(
                iconData: Icons.attach_money,
                text: order.humanPrice,
                iconSize: 26,
                textStyle: AppStyles.bodyText2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: OrderElementWidget(
                iconData: Icons.playlist_add_check_circle_outlined,
                text: orderStatusText,
                iconSize: 26,
                textStyle:
                    AppStyles.bodyText2.copyWith(color: orderStatusColor),
              ),
            ),
            const OrderActionsWidget(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextButton(
                  child: const Text(
                    "Повідомити про проблему",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dangerousColor),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            )
          ]),
        ),
      ),
    );
  }

  Future<bool> checkOrder() async {
    //setState(() {
    //  isOrderLoading = true;
    //});
    try {
      var updated = await order.checkOrder(token);
      if (updated) {
        print("updated");
      } else {
        print("not updated");
      }
      return updated;
      //await Provider.of<OrdersNotifier>(context, listen: false)
      //    .checkOrder(order.id);
      //if (checkedOrder.status != order.status) {
      //  setState(() {
      //    order = checkedOrder;
      //    //isOrderLoading = false;
      //  });
      //  return;
      //}
    } catch (e) {
      print("error: $e");
      return false;
    }

    //setState(() {
    //  isOrderLoading = false;
    //});
  }
}
