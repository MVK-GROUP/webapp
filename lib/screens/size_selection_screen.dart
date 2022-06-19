import 'package:flutter/material.dart';
import 'package:mvk_app/api/http_exceptions.dart';
import 'package:mvk_app/screens/global_menu.dart';
import 'package:mvk_app/screens/payment_check_screen.dart';
import 'package:mvk_app/widgets/confirm_dialog.dart';
import 'package:mvk_app/widgets/sww_dialog.dart';
import 'package:provider/provider.dart';
import '../api/lockers.dart';
import '../providers/auth.dart';
import '../providers/order.dart';
import '../style.dart';
import '../models/lockers.dart';
import '../widgets/main_block.dart';
import '../widgets/screen_title.dart';
import '../widgets/tariff_dialog.dart';
import '../models/services.dart';

class SizeSelectionScreen extends StatefulWidget {
  static const routeName = '/size-selection';

  const SizeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<SizeSelectionScreen> createState() => _SizeSelectionScreenState();
}

class _SizeSelectionScreenState extends State<SizeSelectionScreen> {
  late bool _orderCreating;
  late Service? currentService;
  String? token;
  late Locker? locker;
  late List<ACLCellType> cellTypes;
  bool _isOnlyOneCellType = false;
  late Future _getFreeCellsFuture;
  var isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<List<CellStatus>?> _obtainGetFreeCellsFuture() async {
    token = Provider.of<Auth>(context, listen: false).token;
    currentService =
        Provider.of<ServiceNotifier>(context, listen: false).service;
    if (currentService == null) {
      Navigator.pushReplacementNamed(context, MenuScreen.routeName);
      return null;
    }
    cellTypes = currentService?.data["cell_types"] as List<ACLCellType>;
    locker = Provider.of<LockerNotifier>(context, listen: false).locker;

    try {
      final freeCells = await LockerApi.getFreeCells(locker?.lockerId ?? 0,
          service: ServiceCategoryExt.typeToString(currentService!.category),
          token: token);
      if (freeCells.isEmpty) {
        await showDialog(
            context: context,
            builder: (ctx) => const SomethingWentWrongDialog(
                  title: "Немає вільних комірок",
                  bodyMessage:
                      "Нажаль немає вільних комірок. Спробуйте орендувати комірку пізніше",
                ));
        Navigator.pushReplacementNamed(context, MenuScreen.routeName);
        return null;
      }
      return freeCells;
    } catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => const SomethingWentWrongDialog(
                title: "Немає вільних комірок",
                bodyMessage:
                    "Сталась технічна помилка. Спробуйте орендувати комірку пізніше",
              ));
      Navigator.pushReplacementNamed(context, MenuScreen.routeName);
      return null;
    }
  }

  @override
  void initState() {
    _orderCreating = false;
    _getFreeCellsFuture = _obtainGetFreeCellsFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.mainColor, size: 32),
        ),
        body: FutureBuilder(
          future: _getFreeCellsFuture,
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "На жаль не можемо відобразити Ваші замовлення через технічні проблеми",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                final cellStatuses = dataSnapshot.data as List<CellStatus>?;
                if (cellStatuses == null || cellStatuses.isEmpty) {
                  return const Center();
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ScreenTitle(
                          'Оберіть розмір комірки',
                          subTitle: 'Послуга "${currentService!.title}"',
                        ),
                      ),
                      MainBlock(
                          child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: GridView(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 250,
                                    childAspectRatio:
                                        mediaQuery.size.width <= 310 ? 2 : 1),
                            shrinkWrap: true,
                            children: cellTypes.map((size) {
                              final index = cellStatuses.indexWhere((element) =>
                                  element.isThisTypeId(size.id.toString()));
                              return cellSizeTile(
                                  context: context,
                                  mediaQuery: mediaQuery,
                                  serviceCategoryType:
                                      ServiceCategoryExt.typeToString(
                                          currentService!.category),
                                  algorithmType: currentService!
                                      .data["algorithm"] as AlgorithmType,
                                  tariffSelectionType: currentService!
                                          .data["tariff_selection_type"]
                                      as TariffSelectionType,
                                  locker: locker,
                                  cellType: size,
                                  color: currentService!.color,
                                  isExistFree: index > -1);
                            }).toList(),
                          ),
                        ),
                      )),
                    ],
                  );
                }
              }
            }
          },
        ));
  }

  void tariffSelection(
      ACLCellType cellType, Color tileColor, BuildContext context) async {
    var chosenTariff = await showDialog<Tariff>(
        context: context,
        builder: (ctx) => TariffDialog(
              cellType,
              tileColor: tileColor,
            ));
    if (chosenTariff != null) {
      //final newOrder = TemporaryOrderData(
      //    amountInCoins: chosenTariff.priceInCoins,
      //    helperText:
      //        "Після сплати комплекс відчинить комірку і ви зможете покласти свої речі",
      //    type: ServiceCategory.acl,
      //    item: {"cell_type": cellType, "chosen_tariff": chosenTariff});
      //Navigator.pushNamed(context, PayScreen.routeName,
      //    arguments: {"order": newOrder});
      showDialog(
          context: context,
          builder: (ctx) => const AlertDialog(
                content:
                    Text("Змінити створення тимчасового замовлення на повне"),
              ));
    }
  }

  void createFreeOrder(
      BuildContext context,
      int? lockerId,
      String serviceCategoryType,
      AlgorithmType algorithmType,
      ACLCellType cellType) async {
    var confirmDialog = await showDialog(
        context: context,
        builder: (ctx) {
          String message = "";
          if (cellType.tariff.isNotEmpty) {
            message +=
                "Максимальний час безкоштовного використання комірки становить ${cellType.tariff[0].humanHours}. ";
          }
          message +=
              "Після підтвердження замовлення Вам відкриється комірка. Підтвердіть або скасуйте замовлення";
          return ConfirmDialog(title: "Увага", text: message);
        });

    if (confirmDialog != null) {
      String? orderedCell;
      try {
        final res = await LockerApi.getFreeCells(lockerId ?? 0,
            service: serviceCategoryType, typeId: cellType.id, token: token);
        if (res.isEmpty) {
          await showDialog(
              context: context,
              builder: (ctx) => const SomethingWentWrongDialog(
                    title: "Немає вільних комірок",
                    bodyMessage:
                        "Нажаль немає вільних комірок. Спробуйте орендувати комірку іншого розмірку або типу",
                  ));
          return;
        } else {
          orderedCell = res.first.cellId;
        }
      } catch (e) {
        if (e is HttpException) {
          if (e.statusCode == 400) {
            await showDialog(
                context: context,
                builder: (ctx) => const SomethingWentWrongDialog(
                      bodyMessage: "Не можемо зв'язатись з комплексом",
                    ));
            return;
          }
        }
        await showDialog(
            context: context,
            builder: (ctx) => const SomethingWentWrongDialog());
        return;
      }

      var helperText =
          "Замовлення створено. Вам видана комірка #$orderedCell. ";
      if (algorithmType == AlgorithmType.qrReading) {
        helperText +=
            "В замовленні буде міститись QR-код, який ви можете використати для відкриття комірки.";
      } else if (algorithmType == AlgorithmType.enterPinOnComplex) {
        helperText +=
            "В замовленні буде міститись ПІН-код, який ви можете використати для відкриття комірки.";
      } else {
        helperText +=
            "В замовленні буде міститись вся потрібна інформація для користування цією коміркою.\nПочекайте декілька секунд поки ми зв’язуємось з комплексом та відчиніть комірку або зробіть це в \"Керування замовленням\"";
      }

      Map<String, Object> extraData = {};
      extraData["type"] = "free";
      extraData["time"] = cellType.tariff.first.minutes;
      extraData["paid"] = 0;
      extraData["hourly_pay"] = cellType.tariff.first.priceInCoins;
      extraData["service"] =
          ServiceCategoryExt.typeToString(ServiceCategory.acl);
      extraData["algorithm"] = AlgorithmTypeExt.toStr(algorithmType);
      extraData["cell_id"] = orderedCell;

      try {
        final orderData =
            await Provider.of<OrdersNotifier>(context, listen: false)
                .addOrder(lockerId ?? 0, "Оренда комірки", data: extraData);
        Navigator.pushReplacementNamed(context, PaymentCheckScreen.routeName,
            arguments: {"order": orderData, "title": helperText});
      } catch (e) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                content: Text("ERROR: $e"),
              );
            });
      }

      //final newOrder = TemporaryOrderData(
      //    amountInCoins: 0,
      //    type: ServiceCategory.acl,
      //    helperText: helperText,
      //    item: {"cell_type": cellType, "algorithm": algorithmType},
      //    extraData: extraData);
    }
  }

  Widget cellSizeTile(
      {required BuildContext context,
      required MediaQueryData mediaQuery,
      required String serviceCategoryType,
      required AlgorithmType algorithmType,
      required TariffSelectionType tariffSelectionType,
      required Locker? locker,
      required ACLCellType cellType,
      required Color color,
      bool isExistFree = true}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        onPressed: isExistFree
            ? () {
                if (locker?.type == LockerType.free) {
                  setState(() {
                    _orderCreating = true;
                  });
                  createFreeOrder(context, locker?.lockerId,
                      serviceCategoryType, algorithmType, cellType);
                  setState(() {
                    _orderCreating = false;
                  });
                } else {
                  tariffSelection(cellType, color, context);
                }
              }
            : null,
        child: _orderCreating
            ? const Center(
                child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    )))
            : Center(
                child: mediaQuery.size.width <= 310
                    ? Row(
                        children: [
                          if (cellType.symbol != null)
                            Expanded(
                              flex: 1,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  cellType.symbol ?? "",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: FittedBox(
                                child: Text(
                                  cellType.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          if (cellType.symbol != null)
                            Expanded(
                              flex: 2,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  cellType.symbol ?? "",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: FittedBox(
                                child: Text(
                                  cellType.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                        ],
                      ),
              ),
      ),
    );
  }
}
