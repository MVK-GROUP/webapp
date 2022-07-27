import 'dart:async';
import 'dart:js' as js show context;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvk_app/providers/auth.dart';
import 'package:mvk_app/providers/order.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../api/orders.dart';
import '../../models/lockers.dart';
import '../../models/order.dart';
import '../../style.dart';
import '../../widgets/button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/order_element_widget.dart';

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
  bool isJustCellOpening = false;
  var _isInit = false;
  int pollingCellOpeningAttempts = 0;
  int maxPollingAttempts = 5;
  Timer? cellOpeningTimer;
  late OrderData order;
  String? token;

  @override
  void dispose() {
    cellOpeningTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      token = Provider.of<Auth>(context, listen: false).token;
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
    String buttonText = "open_cell".tr();
    String confirmText = "acl.after_confirm_open_cell"
            .tr(namedArgs: {"cell": order.data!["cell_id"].toString()}) +
        "confirm_text".tr();
    var openCellType = OpenCellType.openCell;
    final algorithm = order.data!["algorithm"] as AlgorithmType;
    if (justOpen) {
      buttonText = "acl.open_cell_and_add_stuff".tr();
      confirmText = "acl.after_confirm_open_cell"
              .tr(namedArgs: {"cell": order.data!["cell_id"].toString()}) +
          "dont_forget_to_close".tr();
      openCellType = OpenCellType.openCell;
    } else if (order.status == OrderStatus.hold &&
        order.firstActionTimestamp == 0 &&
        algorithm == AlgorithmType.selfService) {
      openCellType = OpenCellType.firstOpenCell;
      buttonText = "acl.open_cell_and_put_stuff".tr();
      confirmText = "acl.after_confirm_open_cell"
              .tr(namedArgs: {"cell": order.data!["cell_id"].toString()}) +
          "dont_forget_to_close".tr();
    } else if (order.status == OrderStatus.active &&
        algorithm == AlgorithmType.selfService) {
      openCellType = OpenCellType.lastOpenCell;
      buttonText = "acl.pick_up_stuff_and_complete".tr();
      confirmText = order.timeLeftInSeconds < 300
          ? "acl.after_confirm_open_cell"
                  .tr(namedArgs: {"cell": order.data!["cell_id"].toString()}) +
              "confirm_text".tr()
          : "history.you_still_have"
                  .tr(namedArgs: {'time': order.humanTimeLeft}) +
              "acl.pick_up_stuff_q".tr();
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
      onPressed: isJustCellOpening || isCellOpening
          ? null
          : () async {
              var confirmDialog = await showDialog(
                  context: context,
                  builder: (ctx) {
                    return ConfirmDialog(
                        title: "attention_title".tr(), text: confirmText);
                  });
              if (confirmDialog != null) {
                openCell(openCellType: openCellType);
              }
            },
    );
  }

  ElevatedDefaultButton justOpenCellButton(
      BuildContext context, OrderData order) {
    String buttonText = "open_cell_and_add_stuff".tr();
    String confirmText = "acl.after_confirm_open_cell_and_dont_forget_to_close"
        .tr(namedArgs: {'cell': order.data!["cell_id"].toString()});
    var openCellType = OpenCellType.openCell;

    return ElevatedDefaultButton(
      buttonColor: AppColors.mainColor,
      child: isJustCellOpening
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
      onPressed: isJustCellOpening || isCellOpening
          ? null
          : () async {
              var confirmDialog = await showDialog(
                  context: context,
                  builder: (ctx) {
                    return ConfirmDialog(
                        title: "attention_title".tr(), text: confirmText);
                  });
              if (confirmDialog != null) {
                openCell(openCellType: openCellType, isJustOpen: true);
              }
            },
    );
  }

  ElevatedDefaultButton payDebtButton() {
    return ElevatedDefaultButton(
      buttonColor: AppColors.dangerousColor,
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
              "acl.pay_debt_and_pick_up_stuff".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
      onPressed: () async {
        try {
          final res = await OrderApi.payDebt(order.id, token);
          js.context.callMethod(
              'openLiqpay', [res['data'], res['signature'], kDebugMode]);
        } catch (e) {
          print("order_actions_widget error: ${e}");
          return;
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
          : Text(
              "acl.open_cell_and_put_stuff".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
      onPressed: isJustCellOpening || isCellOpening
          ? null
          : () async {
              var confirmDialog = await showDialog(
                  context: context,
                  builder: (ctx) {
                    return ConfirmDialog(
                        title: "attention_title".tr(),
                        text:
                            "acl.after_confirm_open_cell_and_dont_forget_to_close"
                                .tr(namedArgs: {
                          'cell': order.data!["cell_id"].toString()
                        }));
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
        TextSpan(text: "history.you_can_use_pin".tr()),
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
      message = "history.cell_opened_and_dont_forget".tr();
    } else if (status == 2) {
      message = "history.cell_didnt_open_and__use_pin".tr();
    } else if (status == 3) {
      message = "history.cant_check_cell_opened__use_pin".tr();
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

  void openCell(
      {OpenCellType openCellType = OpenCellType.openCell,
      bool isJustOpen = false}) async {
    String? numTask;
    try {
      setState(() {
        if (isJustOpen) {
          isJustCellOpening = true;
        } else {
          isCellOpening = true;
        }
      });
      if (openCellType == OpenCellType.openCell) {
        numTask = await OrderApi.openCell(order.id, token);
      } else if (openCellType == OpenCellType.firstOpenCell) {
        numTask = await OrderApi.putThings(order.id, token);
      } else if (openCellType == OpenCellType.lastOpenCell) {
        numTask = await OrderApi.getThings(order.id, token);
      }

      if (numTask == null) {
        await showDialog(
            context: context,
            builder: (ctx) => InformationDialog(
                title: "something_went_wrong".tr(),
                text: "cell_didnt_open".tr()));
        setState(() {
          isJustCellOpening = false;
          isCellOpening = false;
        });
        return;
      }
    } catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => InformationDialog(
              title: "something_went_wrong".tr(),
              text: "cell_didnt_open".tr()));
      setState(() {
        isJustCellOpening = false;
        isCellOpening = false;
      });

      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    if (openCellType == OpenCellType.openCell) {
      int status = 0;
      try {
        status = await OrderApi.checkOpenCellTask(order.id, numTask, token);
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
              status =
                  await OrderApi.checkOpenCellTask(order.id, numTask, token);
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
            isJustCellOpening = false;
          });
        });
      } else {
        showDialogByOpenCellTaskStatus(context, status);
        if (status == 1 && openCellType != OpenCellType.openCell) {
          await checkChangingOrder(openCellType: openCellType);
        }
        setState(() {
          isCellOpening = false;
          isJustCellOpening = false;
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
      await Provider.of<OrdersNotifier>(context, listen: false)
          .checkOrder(order.id);
      setState(() {
        isCellOpening = false;
        isJustCellOpening = false;
      });
    }
  }

  Future<void> checkChangingOrder(
      {attempts = 0,
      maxAttempts = 20,
      openCellType = OpenCellType.firstOpenCell}) async {
    try {
      await order.checkOrder(token);
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
                text: "cell_number"
                    .tr(namedArgs: {"cell": order.data!["cell_id"].toString()}),
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
            actionButtons: [], message: "history.order_complete_message".tr()),
      );
    } else if (order.status == OrderStatus.expired ||
        order.timeLeftInSeconds < 1) {
      content.add(
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "history.order_timed_out_N_ago"
                    .tr(namedArgs: {"time": order.humanTimePassed}) +
                "history.you_need_to_pay_extra_N"
                    .tr(namedArgs: {"amount": order.needToPayExtra}),
            textAlign: TextAlign.center,
            style: AppStyles.bodySmallText,
          ),
        ),
      );
      content.add(payDebtButton());
    } else if (order.status == OrderStatus.created ||
        order.status == OrderStatus.inProgress) {
      content.addAll(
        actionsSection(
            actionButtons: [], message: "history.wait_few_seconds".tr()),
      );
    } else if (order.status == OrderStatus.hold ||
        order.status == OrderStatus.active) {
      final endDate = order.data!["end_date"] as DateTime;
      content.add(Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 10),
        child: Text(
          "history.rent_to"
              .tr(namedArgs: {"time": order.datetimeToHumanDate(endDate)}),
          style: const TextStyle(fontSize: 16),
        ),
      ));
      //content.add(Padding(
      //  padding: const EdgeInsets.only(bottom: 8.0),
      //  child: Text(
      //    "Залишилось: ${order.humanTimeLeft}",
      //    style: const TextStyle(fontSize: 16),
      //  ),
      //));

      final algorithm = order.data!["algorithm"] as AlgorithmType;
      switch (algorithm) {
        case AlgorithmType.qrReading:
          var pinCode = order.data!["pin"] as String?;
          content.add(Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              children: [
                QrImage(data: pinCode ?? "000000", size: 200.0),
                Text(
                  "history.bring_code_to_reader".tr(),
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
                Text("history.pincode_to_open".tr()),
                Text(
                  pinCode ?? "ERROR",
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ));
          content.addAll(actionsSection(actionButtons: []));
          break;
        case AlgorithmType.selfService:
          if (order.status == OrderStatus.active) {
            content.add(
              Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: justOpenCellButton(context, order)),
            );
          }
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
                child: Text(
                  "history.read_qr".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  var pinCode = order.data!["pin"] as String?;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      alignment: Alignment.center,
                      title: Text(
                        "bring_code_to_reader".tr(),
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
            child: Text("Unknown algorithm"),
          ));
          break;
      }
    } else if (order.status == OrderStatus.completed) {
      content.addAll(
        actionsSection(
            actionButtons: [], message: "order_complete_message".tr()),
      );
    } else {
      content.add(Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "technical_problems__operation_was_canceled".tr(),
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }
    return Column(children: content);
  }
}
