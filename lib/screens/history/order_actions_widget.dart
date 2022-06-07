import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../api/orders.dart';
import '../../models/lockers.dart';
import '../../models/order.dart';
import '../../style.dart';
import '../../widgets/button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/order_element_widget.dart';
import '../../widgets/sww_dialog.dart';

enum OpenCellType {
  firstOpenCell,
  openCell,
  lastOpenCell,
}

class OrderActionsWidget extends StatefulWidget {
  const OrderActionsWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<OrderActionsWidget> createState() => _OrderActionsWidgetState();
}

class _OrderActionsWidgetState extends State<OrderActionsWidget> {
  bool isCellOpening = false;
  var _isInit = false;
  int pollingCellOpeningAttempts = 0;
  int maxPollingAttempts = 5;
  Timer? cellOpeningTimer;
  late OrderData order;

  @override
  void dispose() {
    cellOpeningTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      order = Provider.of<OrderData>(context, listen: true);
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    switch (order.service) {
      case ServiceCategory.acl:
        return buildAclSection(context, order);
      default:
        return Container();
    }
  }

  ElevatedDefaultButton openCellButton(BuildContext context, OrderData order,
      {justOpen = false}) {
    String buttonText = "Відчинити комірку";
    String confirmText =
        "Після підтвердження цієї дії відчиниться комірка ${order.data!["cell_id"]}. Ви впевнені що хочете це зробити?";
    var openCellType = OpenCellType.openCell;
    final algorithm = order.data!["algorithm"] as AlgorithmType;
    print("${order.status} ${order.firstActionTimestamp}");
    if (justOpen) {
      buttonText = "Відчинити комірку та докласти речі";
      confirmText =
          "Після підтвердження цієї дії відчиниться комірка ${order.data!["cell_id"]}. Не забудьте зачинити комірку!";
      openCellType = OpenCellType.openCell;
    } else if (order.status == OrderStatus.hold &&
        order.firstActionTimestamp == 0 &&
        algorithm == AlgorithmType.selfService) {
      openCellType = OpenCellType.firstOpenCell;
      buttonText = "Відчинити комірку та покласти речі";
      confirmText =
          "Після підтвердження цієї дії відчиниться комірка ${order.data!["cell_id"]}. Не забудьте зачинити комірку!";
    } else if (order.status == OrderStatus.active &&
        algorithm == AlgorithmType.selfService) {
      openCellType = OpenCellType.lastOpenCell;
      buttonText = "Забрати речі та завершити замовлення";
      confirmText = order.timeLeftInSeconds < 300
          ? "Після підтвердження цієї дії відчиниться комірка ${order.data!["cell_id"]}. Ви впевнені що хочете це зробити?"
          : "У вас ще залишилось ${order.humanTimeLeft} оренди. Забрати свої речі?";
    }
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
          : Text(
              buttonText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
      onPressed: isCellOpening
          ? null
          : () async {
              var confirmDialog = await showDialog(
                  context: context,
                  builder: (ctx) {
                    return ConfirmDialog(title: "Увага", text: confirmText);
                  });
              if (confirmDialog != null) {
                openCell(openCellType: openCellType);
              }
            },
    );
  }

  ElevatedDefaultButton putThingsButton(BuildContext context) {
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
              "Відчинити комірку та покласти речі",
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
                            "Після підтвердження цієї дії відчиниться комірка ${order.data!["cell_id"]} та ви зможете покласти свої речі. Не забудьте зачин комірку!");
                  });
              if (confirmDialog != null) {
                openCell();
              }
            },
    );
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
          ),
        ),
      const SizedBox(height: 10),
      ...actionButtons.map((btn) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: btn,
          )),
    ];
  }

  RichText usePincodeWidget(BuildContext context) {
    var pinCode = order.data!["pin"] as String?;
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

  void openCell({OpenCellType openCellType = OpenCellType.openCell}) async {
    String? numTask;
    try {
      setState(() {
        isCellOpening = true;
      });
      if (openCellType == OpenCellType.openCell) {
        numTask = await OrderApi.openCell(order.id);
      } else if (openCellType == OpenCellType.firstOpenCell) {
        numTask = await OrderApi.putThings(order.id);
      } else if (openCellType == OpenCellType.lastOpenCell) {
        numTask = await OrderApi.getThings(order.id);
      }

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

    if (openCellType == OpenCellType.openCell) {
      int status = 0;
      try {
        status = await OrderApi.checkOpenCellTask(order.id, numTask);
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
              status = await OrderApi.checkOpenCellTask(order.id, numTask);
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
        if (status == 1 && openCellType != OpenCellType.openCell) {
          await checkChangingOrder(openCellType: openCellType);
        }
        setState(() {
          isCellOpening = false;
        });
      }
    } else {
      await checkChangingOrder(openCellType: openCellType);
      if (openCellType == OpenCellType.firstOpenCell) {
        showDialogByOpenCellTaskStatus(
            context, order.status == OrderStatus.active ? 1 : 2);
      } else {
        showDialogByOpenCellTaskStatus(
            context, order.status == OrderStatus.completed ? 1 : 2);
      }
      setState(() {
        isCellOpening = false;
      });
    }
  }

  Future<void> checkChangingOrder(
      {attempts = 0,
      maxAttempts = 20,
      openCellType = OpenCellType.firstOpenCell}) async {
    try {
      await order.checkOrder();
      if (openCellType == OpenCellType.firstOpenCell) {
        if ((order.status != OrderStatus.active) && maxAttempts > attempts) {
          attempts += 1;
          await Future.delayed(const Duration(seconds: 2));
          await checkChangingOrder(
              attempts: attempts, openCellType: openCellType);
        }
      } else if (openCellType == OpenCellType.lastOpenCell) {
        if ((order.status != OrderStatus.completed) && maxAttempts > attempts) {
          attempts += 1;
          await Future.delayed(const Duration(seconds: 2));
          await checkChangingOrder(
              attempts: attempts, openCellType: openCellType);
        }
      }
    } catch (e) {
      return;
    }
  }

  Widget buildAclSection(BuildContext context, OrderData order) {
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
            actionButtons: [],
            message:
                "Замовлення виконано. Дякуємо що скористались нашим сервісом!"),
      );
    } else if (order.status == OrderStatus.expired ||
        order.timeLeftInSeconds < 1) {
      // MAY ADD "Extend Order" action
      content.addAll(
        actionsSection(
            actionButtons: [],
            message:
                "Час замовлення вийшов, якщо Ваші речі ще залишились в комірці, повідомте про це нам"),
      );
    } else if (order.status == OrderStatus.created ||
        order.status == OrderStatus.inProgress) {
      content.addAll(
        actionsSection(
            actionButtons: [],
            message:
                "Замовлення виконується, почекайте декілька секунд. Якщо статус замовлення не зміниться через деякий час - повідомте про це нам"),
      );
    } else if (order.status == OrderStatus.hold ||
        order.status == OrderStatus.active) {
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
          content.addAll(actionsSection(actionButtons: []));
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
          content.addAll(actionsSection(actionButtons: []));
          break;
        case AlgorithmType.selfService:
          content.add(
            Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: openCellButton(context, order, justOpen: true)),
          );
          content.add(
            Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: openCellButton(context, order)),
          );
          break;
        case AlgorithmType.selfPlusPin:
          content.add(
            Padding(
                padding: const EdgeInsets.only(bottom: 6.0, top: 10.0),
                child: openCellButton(context, order)),
          );
          content.add(
            Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: usePincodeWidget(context)),
          );
          break;
        case AlgorithmType.selfPlusQr:
          content.add(
            Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 10),
                child: openCellButton(context, order)),
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
          content.add(const SizedBox(height: 20));
          break;
        default:
          content.add(const Center(
            child: Text("Невідомий алгоритм"),
          ));
          break;
      }
    } else if (order.status == OrderStatus.completed) {
      content.addAll(
        actionsSection(
            actionButtons: [],
            message:
                "Замовлення виконано. Дякуємо що скористались нашими послугами, чекаємо ще ;)"),
      );
    } else {
      content.add(const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "Щось пішло не так... Через технічні проблеми операцію було скасовано.",
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }
    return Column(children: content);
  }
}
