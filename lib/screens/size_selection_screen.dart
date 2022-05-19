import 'package:flutter/material.dart';
import 'package:mvk_app/api/http_exceptions.dart';
import 'package:mvk_app/api/orders.dart';
import 'package:mvk_app/screens/payment_check_screen.dart';
import 'package:mvk_app/widgets/confirm_dialog.dart';
import 'package:mvk_app/widgets/sww_dialog.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../style.dart';
import '../models/lockers.dart';
import '../utilities/urils.dart';
import '../widgets/main_block.dart';
import '../widgets/screen_title.dart';
import '../widgets/tariff_dialog.dart';
import '../models/services.dart';
import '../screens/pay_screen.dart';

class SizeSelectionScreen extends StatefulWidget {
  static const routeName = '/size-selection';

  const SizeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<SizeSelectionScreen> createState() => _SizeSelectionScreenState();
}

class _SizeSelectionScreenState extends State<SizeSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final currentService =
        Provider.of<ServiceNotifier>(context, listen: false).service;
    if (currentService == null) {
      return Utils.goToMenu(Navigator.of(context));
    }

    final cellTypes = currentService.data["cell_types"] as List<ACLCellType>;
    final algorithmType = currentService.data["algorithm"] as AlgorithmType;
    final serviceCategoryType =
        ServiceCategoryExt.typeToString(currentService.category);
    final locker = Provider.of<LockerNotifier>(context, listen: false).locker;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.mainColor, size: 32),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ScreenTitle(
              'Оберіть розмір комірки',
              subTitle: 'Послуга "${currentService.title}"',
            ),
          ),
          MainBlock(
              child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: GridView(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: mediaQuery.size.width <= 310 ? 2 : 1),
                shrinkWrap: true,
                children: cellTypes
                    .map((size) => cellSizeTile(
                        context,
                        mediaQuery,
                        serviceCategoryType,
                        algorithmType,
                        locker,
                        size,
                        currentService.color))
                    .toList(),
              ),
            ),
          )),
        ],
      ),
    );
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
      final newOrder = TemporaryOrderData(
          amountInCoins: chosenTariff.priceInCoins,
          helperText:
              "Після сплати комплекс відчинить комірку і ви зможете покласти свої речі",
          type: ServiceCategory.acl,
          item: {"cell_type": cellType, "chosen_tariff": chosenTariff});
      Navigator.pushNamed(context, PayScreen.routeName,
          arguments: {"order": newOrder});
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
            service: serviceCategoryType, typeId: cellType.id);
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

      var helperText = "Замовлення створено. ";
      if (algorithmType == AlgorithmType.qrReading) {
        helperText +=
            "В замовленні буде міститись QR-код, який ви можете використати для відкриття комірки. Після відкриття комірки покладіть свої речі та закрийте її";
      } else {
        helperText +=
            "Зараз відчиниться комірка #7 та роздрукується чек. Обережно покладіть речі та закрийте комірку";
      }

      Map<String, Object> extraData = {};
      extraData["type"] = "free";
      extraData["time"] = cellType.tariff.first.minutes;
      extraData["paid"] = 0;
      extraData["hourly_pay"] = cellType.tariff.first.priceInCoins;
      extraData["service"] =
          ServiceCategoryExt.typeToString(ServiceCategory.acl);
      extraData["algorithm"] = AlgorithmTypeExt.toStr(algorithmType);
      //extraData["cell_id"] = "5";
      extraData["cell_id"] = orderedCell;
      //extraData["pin"] = "999999";

      final newOrder = TemporaryOrderData(
          amountInCoins: 0,
          type: ServiceCategory.acl,
          helperText: helperText,
          item: {"cell_type": cellType, "algorithm": algorithmType},
          extraData: extraData);

      Navigator.pushNamed(context, PaymentCheckScreen.routeName,
          arguments: {"order": newOrder});
    }
  }

  Widget cellSizeTile(
      BuildContext context,
      MediaQueryData mediaQuery,
      String serviceCategoryType,
      AlgorithmType algorithmType,
      Locker? locker,
      ACLCellType cellType,
      Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        onPressed: () {
          print("tariff: ${cellType.tariff}");
          if (locker?.type == LockerType.free) {
            createFreeOrder(context, locker?.lockerId, serviceCategoryType,
                algorithmType, cellType);
          } else {
            tariffSelection(cellType, color, context);
          }
        },
        child: Center(
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
