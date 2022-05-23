import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvk_app/providers/order.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../style.dart';
import '../../widgets/dialog.dart';
import '../../widgets/order_element_widget.dart';
import 'order_actions_widget.dart';

class DetailOrderDialog extends StatefulWidget {
  final OrderData order;

  const DetailOrderDialog({required this.order, Key? key}) : super(key: key);

  @override
  State<DetailOrderDialog> createState() => _DetailOrderDialogState();
}

class _DetailOrderDialogState extends State<DetailOrderDialog> {
  Timer? timer;
  late OrderData order;
  late bool isOrderLoading;

  @override
  void initState() {
    order = widget.order;

    isOrderLoading = false;
    if ([OrderStatus.created, OrderStatus.inProgress].contains(order.status)) {
      checkOrder();
      isOrderLoading = true;
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        checkOrder();
        print("order status: ${order.status}");
        if (![OrderStatus.created, OrderStatus.inProgress]
            .contains(order.status)) {
          timer.cancel();
          setState(() {
            isOrderLoading = false;
          });
        }
        // GET ORDER STATUS
      });
    } else if (order.status == OrderStatus.error) {
      checkOrder();
    }

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
      OrderStatus.completed
    ].contains(order.status)) {
      return AppColors.successColor;
    } else {
      return AppColors.dangerousColor;
    }
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

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      useProgressBar: isOrderLoading,
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
            OrderActionsWidget(order: order),
          ]),
        ),
      ),
    );
  }

  void checkOrder() async {
    //setState(() {
    //  isOrderLoading = true;
    //});
    var checkedOrder = await Provider.of<OrdersNotifier>(context, listen: false)
        .checkOrder(order.id);
    if (checkedOrder.status != order.status) {
      setState(() {
        order = checkedOrder;
        //isOrderLoading = false;
      });
      return;
    }
    //setState(() {
    //  isOrderLoading = false;
    //});
  }
}
