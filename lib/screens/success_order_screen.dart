import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/providers/order.dart';
import 'package:mvk_app/widgets/confirm_dialog.dart';
import 'package:provider/provider.dart';
import '../api/orders.dart';
import '../models/order.dart';
import '../providers/auth.dart';
import '../widgets/sww_dialog.dart';
import 'history/history_screen.dart';
import 'global_menu.dart';
import '../style.dart';
import '../widgets/button.dart';

class SuccessOrderScreen extends StatefulWidget {
  static const routeName = 'success-order/';

  const SuccessOrderScreen({Key? key}) : super(key: key);

  @override
  State<SuccessOrderScreen> createState() => _SuccessOrderScreenState();
}

class _SuccessOrderScreenState extends State<SuccessOrderScreen> {
  late OrderData order;
  String? token;
  late Locker? locker;
  String? text;
  Timer? timer;
  Timer? _cellOpeningTimer;
  var _isInit = false;
  var _isUseOpenCellButton = false;
  var _isOrderStatusChecking = false;
  var _isCellOpening = false;
  int maxAttempts = 14;

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
      token = Provider.of<Auth>(context).token;
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
        int attempt = 0;
        attempt++;
        timer = Timer.periodic(const Duration(seconds: 1, milliseconds: 500),
            (timer) async {
          try {
            attempt++;
            var checkedOrder =
                await Provider.of<OrdersNotifier>(context, listen: false)
                    .checkOrder(order.id);
            if (![OrderStatus.created, OrderStatus.inProgress]
                .contains(checkedOrder.status)) {
              timer.cancel();
              setState(() {
                _isOrderStatusChecking = false;
              });
              if (checkedOrder.status == OrderStatus.error ||
                  checkedOrder.timeLeftInSeconds < 1) {
                throw Exception("order error");
              }
            }
            if (attempt > maxAttempts) {
              timer.cancel();
              setState(() {
                _isOrderStatusChecking = false;
              });
              throw Exception("order error");
            }
          } catch (e) {
            timer.cancel();
            showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      content: Text(
                          "create_order.cant_check_status__go_to_detail".tr()),
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
                onPressed: _isOrderStatusChecking
                    ? null
                    : () {
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
                            "great".tr(),
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
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: Image.asset("assets/images/hero.png"),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          if (_isUseOpenCellButton)
                            _isOrderStatusChecking || _isCellOpening
                                ? ElevatedWaitingButton(
                                    text: "acl.open_cell_and_put_stuff".tr(),
                                    iconSize: 20,
                                  )
                                : ElevatedIconButton(
                                    icon: const Icon(
                                      Icons.clear_all_outlined,
                                      size: 24,
                                    ),
                                    text: "acl.open_cell_and_put_stuff".tr(),
                                    onPressed: () {
                                      openCell();
                                    },
                                  ),
                          const SizedBox(height: 10),
                          if (!_isUseOpenCellButton || !_isOrderStatusChecking)
                            ElevatedIconButton(
                              icon: const Icon(Icons.history),
                              text: "create_order.go_to_detail".tr(),
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
      numTask = await OrderApi.putThings(order.id, token);
      if (numTask == null) {
        throw Exception();
      }
    } catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => SomethingWentWrongDialog(
                bodyMessage: "create_order.cant_open_cell".tr(),
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
      await order.checkOrder(token);
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
      message = "history.cell_opened_and_dont_forget".tr();
    } else if (status == 2) {
      message = "cell_didnt_open".tr();
    } else if (status == 3) {
      message = "create_order.cant_check_cell_opened__go_to_detail".tr();
    }
    if (message != null) {
      await showDialog(
          context: context,
          builder: (ctx) {
            return InformationDialog(
              title: "information".tr(),
              text: message ?? "unknown",
            );
          });
    }
  }
}
