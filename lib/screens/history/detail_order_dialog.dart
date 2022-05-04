import 'package:flutter/material.dart';
import 'package:mvk_app/models/lockers.dart';

import '../../models/order.dart';
import '../../style.dart';
import '../../widgets/button.dart';
import '../../widgets/dialog.dart';
import '../../widgets/order_element_widget.dart';

class DetailOrderDialog extends StatelessWidget {
  final OrderData order;

  const DetailOrderDialog({required this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final endDate = order.data!["end_date"] as DateTime;

    return DefaultDialog(
      maxHeight: 600,
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
            const SizedBox(height: 10),
            Text(
              "Оренда до: ${order.datetimeToHumanDate(endDate)}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Залишилось: ${order.humanTimeLeft}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            OrderActionsWidget(order: order),
            const SizedBox(height: 20),
            const Text(
              "Після закінченя терміну аренди вам необхідно буде сплатити суму заборгованості",
              style: TextStyle(color: Colors.grey),
            ),
          ]),
        ),
      ),
    );
  }
}

class OrderActionsWidget extends StatelessWidget {
  final OrderData order;
  const OrderActionsWidget({
    required this.order,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (order.service) {
      case ServiceCategory.acl:
        return buildAclActions(context, order);
      default:
        return Container();
    }
  }

  Widget buildAclActions(BuildContext context, OrderData order) {
    if (order.timeLeftInSeconds < 1) {
      return const Center(child: Text("Час оренди минув"));
    }

    final algorithm = order.data!["algorithm"] as AlgorithmType;
    switch (algorithm) {
      case AlgorithmType.qrReading:
        var pinCode = order.data!["pin"] as String?;
        return Column(
          children: [
            Center(
                child: Text(pinCode == null ? "NO PIN" : "PIN CODE: $pinCode")),
          ],
        );
      default:
        return Column(children: [
          const Text(
            "ДІЇ",
            style: AppStyles.bodyText2,
          ),
          const SizedBox(height: 10),
          ElevatedDefaultButton(
              buttonColor: AppColors.dangerousColor,
              child: const Text(
                "Завершити оренду",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(height: 10),
          ElevatedDefaultButton(
              child: const Text(
                "Відчинити комірку",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ]);
    }
  }
}
