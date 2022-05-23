import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../api/orders.dart';
import '../../models/lockers.dart';
import '../../models/order.dart';
import '../../style.dart';
import '../../widgets/button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/order_element_widget.dart';
import '../../widgets/sww_dialog.dart';

class OrderActionsWidget extends StatefulWidget {
  final OrderData order;
  const OrderActionsWidget({
    required this.order,
    Key? key,
  }) : super(key: key);

  @override
  State<OrderActionsWidget> createState() => _OrderActionsWidgetState();
}

class _OrderActionsWidgetState extends State<OrderActionsWidget> {
  bool isCellOpening = false;
  int pollingCellOpeningAttempts = 0;
  int maxPollingAttempts = 5;
  Timer? cellOpeningTimer;

  @override
  void dispose() {
    cellOpeningTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.order.service) {
      case ServiceCategory.acl:
        return buildAclSection(context, widget.order);
      default:
        return Container();
    }
  }

  ElevatedDefaultButton openCellButton(BuildContext context) {
    return ElevatedDefaultButton(
        buttonColor: AppColors.mainColor,
        child: isCellOpening
            ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Відчинити комірку",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
        onPressed: isCellOpening
            ? null
            : () async {
                var confirmDialog = await showDialog(
                    context: context,
                    builder: (ctx) {
                      return ConfirmDialog(
                          title: "Увага",
                          text:
                              "Після підтвердження цієї дії відчиниться комірка ${widget.order.data!["cell_id"]}. Ви впевнені що хочете це зробити?");
                    });
                if (confirmDialog != null) {
                  openCell();
                }
              });
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

  RichText usePincodeWidget(BuildContext context) {
    var pinCode = widget.order.data!["pin"] as String?;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
        const TextSpan(
            text: "Для відкриття комірки також можна використати PIN код "),
        TextSpan(
          text: pinCode,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  void showDialogByOpenCellTaskStatus(BuildContext context, int status) async {
    String? message;
    if (status == 1) {
      message =
          "Комірка відчинилась. Не забудьте зачинити комірку після її використання, дякуємо!";
    } else if (status == 2) {
      message =
          "На жаль зараз не є можливим відчинити цю комірку. Скористайтесь пін або qr-кодом";
    } else if (status == 3) {
      message =
          "Не можемо перевірити статус відкриття. Почекайте ще декілька секунд. Якщо комірка не відчиниться - скористайтесь пін-кодом, або повідомте нам про проблему";
    }
    if (message != null) {
      await showDialog(
          context: context,
          builder: (ctx) {
            return SomethingWentWrongDialog(
              title: "Інформація",
              bodyMessage: message ?? "unknown",
            );
          });
    }
  }

  void openCell() async {
    String? numTask;
    try {
      setState(() {
        isCellOpening = true;
      });
      numTask = await OrderApi.openCell(widget.order.id);
      if (numTask == null) {
        throw Exception();
      }
    } catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => const SomethingWentWrongDialog(
                bodyMessage: "Наразі неможливо відчинити цю комірку",
              ));
      setState(() {
        isCellOpening = false;
      });
      return;
    }

    await Future.delayed(const Duration(seconds: 2));
    int status = 0;
    try {
      status = await OrderApi.checkOpenCellTask(widget.order.id, numTask);
    } catch (e) {
      showDialogByOpenCellTaskStatus(context, 2);
      return;
    }

    pollingCellOpeningAttempts++;
    if (status == 0) {
      cellOpeningTimer =
          Timer.periodic(const Duration(seconds: 2), (timer) async {
        try {
          if (numTask == null) {
            showDialogByOpenCellTaskStatus(context, 2);
            return;
          } else {
            status = await OrderApi.checkOpenCellTask(widget.order.id, numTask);
            print("status: $status");
            pollingCellOpeningAttempts++;
            if (status == 0 &&
                pollingCellOpeningAttempts < maxPollingAttempts) {
              return;
            }

            if (status != 0) {
              showDialogByOpenCellTaskStatus(context, status);
            } else if (pollingCellOpeningAttempts >= maxPollingAttempts) {
              showDialogByOpenCellTaskStatus(context, 3);
            }
          }
        } catch (e) {
          showDialogByOpenCellTaskStatus(context, 2);
        }

        timer.cancel();
        setState(() {
          isCellOpening = false;
        });
      });
    } else {
      showDialogByOpenCellTaskStatus(context, status);
      setState(() {
        isCellOpening = false;
      });
    }
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
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              children: [
                QrImage(
                  data: pinCode ?? "000000",
                  size: 200.0,
                ),
                const Text(
                  "Для відкриття комірки наведіть цей QR-код на зчитувач QR-кодів",
                  textAlign: TextAlign.center,
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
                child: openCellButton(context)),
          );
          content.add(problemBtn);
          break;
        case AlgorithmType.selfPlusPin:
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
                child: openCellButton(context)),
          );
          content.add(problemBtn);
          content.add(
            Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: usePincodeWidget(context)),
          );
          break;
        case AlgorithmType.selfPlusQr:
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
                child: openCellButton(context)),
          );
          content.add(Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedDefaultButton(
                buttonColor: AppColors.mainColor,
                child: const Text(
                  "Зчитати QR-код",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  var pinCode = order.data!["pin"] as String?;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      alignment: Alignment.center,
                      title: const Text(
                        "Для відкриття комірки наведіть цей QR-код на зчитувач QR-кодів",
                        textAlign: TextAlign.center,
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: QrImage(
                              data: pinCode ?? "000000",
                            ),
                          ),
                          const SizedBox(height: 10),
                          usePincodeWidget(context),
                        ],
                      ),
                    ),
                  );
                },
              )));
          content.add(problemBtn);
          content.add(const SizedBox(height: 20));
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
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "Щось пішло нет... Через технічні проблеми операцію було скасовано.",
            textAlign: TextAlign.center,
          ),
        ),
      ));
      content.addAll(actionsSection(actionButtons: [problemBtn]));
    }
    return Column(children: content);
  }
}
