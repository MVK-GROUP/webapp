import 'package:flutter/material.dart';
import 'package:mvk_app/screens/payment_check_screen.dart';
import 'package:mvk_app/widgets/confirm_dialog.dart';
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

class SizeSelectionScreen extends StatelessWidget {
  static const routeName = '/size-selection';

  const SizeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final currentService =
        Provider.of<ServiceNotifier>(context, listen: false).service;
    if (currentService == null) {
      return Utils.goToMenu(Navigator.of(context));
    }
    final cellTypes = currentService.data["cell_types"] as List<ACLCellType>;

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
                        context, mediaQuery, size, currentService.color))
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
      final newOrder = OrderItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amountInCoins: chosenTariff.priceInCoins,
          helperText:
              "Після сплати комплекс відчинить комірку і ви зможете покласти свої речі",
          type: ServiceCategory.acl,
          item: {"cell_type": cellType, "chosen_tariff": chosenTariff});
      Navigator.pushNamed(context, PayScreen.routeName,
          arguments: {"order": newOrder});
    }
  }

  void createFreeOrder(BuildContext context, ACLCellType cellType) async {
    var confirmDialog = await showDialog(
      context: context,
      builder: (ctx) => const ConfirmDialog(
          title: "Увага",
          text:
              "Максимальний час безкоштовного використання комірки становить 5 годин. Після підтвердження замовлення Вам відкриється комірка. Підтвердіть або скасуйте замовлення"),
    );
    if (confirmDialog != null) {
      final newOrder = OrderItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amountInCoins: 0,
          type: ServiceCategory.acl,
          item: {"cell_type": cellType});
      Navigator.pushNamed(context, PaymentCheckScreen.routeName,
          arguments: {"order": newOrder});
    }
  }

  Widget cellSizeTile(BuildContext context, MediaQueryData mediaQuery,
      ACLCellType cellType, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        onPressed: () {
          if (cellType.tariff.isEmpty) {
            createFreeOrder(context, cellType);
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
