import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvk_app/api/orders.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/providers/order.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../style.dart';
import '../../widgets/button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/dialog.dart';
import '../../widgets/order_element_widget.dart';
import '../../widgets/sww_dialog.dart';

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
      maxHeight: 580,
      title: "Замовлення #${order.id}",
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
        return buildAclSection(context, order);
      default:
        return Container();
    }
  }

  List<Widget> actionsSection(
      {required List<ElevatedDefaultButton> actionButtons, String? message}) {
    return [
      if (message != null)
        Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.bodySmallText,
            )),
      const Text(
        "ДІЇ",
        style: AppStyles.bodyText2,
      ),
      const SizedBox(height: 10),
      ...actionButtons.map((btn) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: btn,
          )),
    ];
  }

  Widget buildAclSection(BuildContext context, OrderData order) {
    var problemBtn = ElevatedDefaultButton(
        buttonColor: AppColors.dangerousColor,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: const Text(
          "Повідомити про проблему",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.pop(context);
        });

    Widget? cellIdWidget = order.data!.containsKey("cell_id")
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: OrderElementWidget(
                iconData: Icons.clear_all,
                text: "Комірка №${order.data!["cell_id"]}",
                iconSize: 26,
                textStyle: AppStyles.bodyText2),
          )
        : null;

    List<Widget> content = [];
    if (cellIdWidget != null) {
      content.add(cellIdWidget);
    }

    if (order.status == OrderStatus.completed) {
      content.addAll(
        actionsSection(
            actionButtons: [problemBtn],
            message:
                "Замовлення виконано. Дякуємо що скористались нашим сервісом!"),
      );
    } else if (order.status == OrderStatus.expired ||
        order.timeLeftInSeconds < 1) {
      // MAY ADD "Extend Order" action
      content.addAll(
        actionsSection(
            actionButtons: [problemBtn],
            message:
                "Час замовлення вийшов, якщо Ваші речі ще залишились в комірці, повідомте про це нам"),
      );
    } else if (order.status == OrderStatus.created ||
        order.status == OrderStatus.inProgress) {
      content.addAll(
        actionsSection(
            actionButtons: [problemBtn],
            message:
                "Замовлення виконується, почекайте декілька секунд. Якщо статус замовлення не зміниться через деякий час - повідомте про це нам"),
      );
    } else if (order.status == OrderStatus.hold) {
      final endDate = order.data!["end_date"] as DateTime;
      content.add(Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          "Оренда до: ${order.datetimeToHumanDate(endDate)}",
          style: const TextStyle(fontSize: 16),
        ),
      ));
      content.add(Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          "Залишилось: ${order.humanTimeLeft}",
          style: const TextStyle(fontSize: 16),
        ),
      ));

      final algorithm = order.data!["algorithm"] as AlgorithmType;
      switch (algorithm) {
        case AlgorithmType.qrReading:
          var pinCode = order.data!["pin"] as String?;
          content.add(Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Column(
              children: [
                const Text("Пінкод для відкриття комірки"),
                Text(
                  pinCode ?? "ПОМИЛКА",
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ));
          content.addAll(actionsSection(actionButtons: [problemBtn]));
          break;
        case AlgorithmType.enterPinOnComplex:
          var pinCode = order.data!["pin"] as String?;
          content.add(Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Column(
              children: [
                const Text("Пінкод для відкриття комірки"),
                Text(
                  pinCode ?? "ПОМИЛКА",
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ));
          content.addAll(actionsSection(actionButtons: [problemBtn]));
          break;
        case AlgorithmType.selfService:
          content.add(const Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 8),
            child: Text(
              "ДІЇ",
              style: AppStyles.bodyText2,
            ),
          ));
          content.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedDefaultButton(
                  buttonColor: AppColors.mainColor,
                  child: const Text(
                    "Відчинити комірку",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () async {
                    var confirmDialog = await showDialog(
                        context: context,
                        builder: (ctx) {
                          return ConfirmDialog(
                              title: "Увага",
                              text:
                                  "Після підтвердження цієї дії відчиниться комірка ${order.data!["cell_id"]}. Ви впевнені що хочете це зробити?");
                        });
                    if (confirmDialog != null) {
                      try {
                        await OrderApi.openCell(order.id);
                      } catch (e) {
                        print("error: $e");
                        await showDialog(
                            context: context,
                            builder: (ctx) => const SomethingWentWrongDialog(
                                  bodyMessage:
                                      "Наразі неможливо відчинити цю комірку",
                                ));
                      }
                    }

                    // TODO: show warning dialog, circle loading
                  }),
            ),
          );

          content.add(problemBtn);
          break;
        default:
          content.add(const Center(
            child: Text("Невідомий алгоритм"),
          ));
          content.addAll(actionsSection(actionButtons: [problemBtn]));
          break;
      }
    } else {
      content.add(const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Щось пішло нет... Спробуйте перезавантажити сторінку",
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }
    return Column(children: content);
  }
}
