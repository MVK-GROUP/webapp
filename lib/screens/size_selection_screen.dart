import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: ScreenTitle(
              'Оберіть розмір комірки',
            ),
          ),
          MainBlock(
            child: FutureBuilder(
                future: servicesLoad(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data != null) {
                      final data = snapshot.data as Map<String, dynamic>;
                      return Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: GridView(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 250,
                                    childAspectRatio:
                                        mediaQuery.size.width <= 310 ? 2 : 1),
                            shrinkWrap: true,
                            children: (data["sizes"] as List<ACLCellType>)
                                .map((size) => cellSizeTile(
                                    context, mediaQuery, size, data["color"]))
                                .toList(),
                          ),
                        ),
                      );
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          ),
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
      Navigator.pushNamed(context, PayScreen.routeName,
          arguments: {"cell_type": cellType, "chosen_tariff": chosenTariff});
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
        onPressed: () => tariffSelection(cellType, color, context),
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
