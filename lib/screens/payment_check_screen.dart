import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:provider/provider.dart';
import '../api/orders.dart';
import '../models/order.dart';
import '../providers/order.dart';
import '../widgets/sww_dialog.dart';
import 'history/history_screen.dart';
import 'global_menu.dart';
import '../style.dart';
import '../widgets/button.dart';

class PaymentCheckScreen extends StatefulWidget {
  static const routeName = 'payment-check/';

  const PaymentCheckScreen({Key? key}) : super(key: key);

  @override
  State<PaymentCheckScreen> createState() => _PaymentCheckScreenState();
}

class _PaymentCheckScreenState extends State<PaymentCheckScreen> {
  late OrderData order;
  late Locker? locker;
  String? text;
  Timer? timer;
  Timer? _cellOpeningTimer;
  var _isInit = false;
  var _isUseOpenCellButton = false;
  var _isOrderStatusChecking = false;
  var _isCellOpening = false;

  @override
  void dispose() {
    timer?.cancel();
    _cellOpeningTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      locker = Provider.of<LockerNotifier>(context).locker;
      if (arg == null || locker == null) {
        Navigator.pushReplacementNamed(context, MenuScreen.routeName);
        return;
      }

      final existArgs = arg as Map<String, Object>;
      order = existArgs["order"] as OrderData;
      text = existArgs["title"] as String;

      if (order.data!.containsKey("algorithm") &&
          [AlgorithmType.qrReading, AlgorithmType.enterPinOnComplex]
              .contains(order.data!["algorithm"])) {
        setState(() {
          _isUseOpenCellButton = false;
        });
      } else {
        setState(() {
          _isUseOpenCellButton = true;
          _isOrderStatusChecking = true;
        });
        timer = Timer.periodic(const Duration(seconds: 1, milliseconds: 500),
            (timer) async {
          try {
            var checkedOrder =
                await Provider.of<OrdersNotifier>(context, listen: false)
                    .checkOrderWithoutNotify(order.id);
            if (![OrderStatus.created, OrderStatus.inProgress]
                .contains(checkedOrder.status)) {
              timer.cancel();
              setState(() {
                _isOrderStatusChecking = false;
              });
              if (checkedOrder.status == OrderStatus.error) {
                throw Exception("order error");
              }
            }
          } catch (e) {
            timer.cancel();
            showDialog(
                context: context,
                builder: (ctx) => const AlertDialog(
                      content: Text(
                          "Не вдалось перевірити статус замовлення. Перейдіть до замовлення, щоб дізнатись подробиці"),
                    ));
            setState(() {
              _isUseOpenCellButton = false;
              _isOrderStatusChecking = false;
            });
          }
        });
      }
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            iconTheme:
                const IconThemeData(color: AppColors.mainColor, size: 32),
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
          child: LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(left: 35, right: 35),
                constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                    minWidth: viewportConstraints.maxWidth),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Чудово!",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(color: AppColors.secondaryColor),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            text ?? "",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 200,
                        child: Image.asset("assets/images/hero.png"),
                      ),
                      const SizedBox(height: 15),
                      Column(
                        children: [
                          if (_isUseOpenCellButton)
                            _isOrderStatusChecking || _isCellOpening
                                ? const ElevatedWaitingButton(
                                    text: "Відчинити комірку та покласти речі",
                                  )
                                : ElevatedIconButton(
                                    icon: const Icon(
                                      Icons.clear_all_outlined,
                                      size: 24,
                                    ),
                                    text: "Відчинити комірку та покласти речі",
                                    onPressed: () {
                                      openCell();
                                    },
                                  ),
                          const SizedBox(height: 15),
                          ElevatedIconButton(
                            icon: const Icon(Icons.history),
                            text: "Перейти до замовлення",
                            onPressed: _isCellOpening
                                ? null
                                : () {
                                    Navigator.pushReplacementNamed(
                                        context, HistoryScreen.routeName,
                                        arguments: order);
                                  },
                          ),
                          const SizedBox(height: 15)
                        ],
                      ),
                      const SizedBox(height: 15),
                    ]),
              ),
            );
          }),
        ));
  }

  void openCell() async {
    String? numTask;
    try {
      setState(() {
        _isCellOpening = true;
      });
      //numTask = await OrderApi.openCell(order.id);
      numTask = await OrderApi.putThings(order.id);
      if (numTask == null) {
        throw Exception();
      }
    } catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => const SomethingWentWrongDialog(
                bodyMessage:
                    "Наразі неможливо відчинити цю комірку. Перейдіть до замовлення та спробуйте ще раз",
              ));
      setState(() {
        _isCellOpening = false;
        _isUseOpenCellButton = false;
      });
      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    await checkChangingOrder();
    showDialogByOpenCellTaskStatus(
        context, order.status == OrderStatus.active ? 1 : 2);
    setState(() {
      _isCellOpening = false;
      _isUseOpenCellButton = false;
    });
  }

  Future<void> checkChangingOrder({attempts = 0, maxAttempts = 10}) async {
    try {
      await order.checkOrder();
      if (order.status != OrderStatus.active && maxAttempts > attempts) {
        attempts += 1;
        await Future.delayed(const Duration(seconds: 2));
        await checkChangingOrder(attempts: attempts);
      }
    } catch (e) {
      return;
    }
  }

  void showDialogByOpenCellTaskStatus(BuildContext context, int status) async {
    String? message;
    if (status == 1) {
      message =
          "Комірка відчинилась. Не забудьте зачинити комірку після її використання, дякуємо!";
    } else if (status == 2) {
      message = "На жаль зараз не є можливим відчинити цю комірку.";
    } else if (status == 3) {
      message =
          "Не можемо перевірити статус відкриття. Почекайте ще декілька секунд. Якщо комірка не відчиниться - перейдіть до замовлення та спробуйте ще раз";
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
}
