import 'package:flutter/material.dart';
import '../models/services.dart';
import '../widgets/main_block.dart';
import '../widgets/screen_title.dart';
import '../style.dart';
import 'global_menu.dart';

class PayScreen extends StatelessWidget {
  static const routeName = '/pay-window';

  const PayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: AlertDialog(
            elevation: 5,
            title: const Text(
                "Необхідні дані для здійснення оплати відсутні. Оберіть необхідну операцію в головному меню"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(MenuScreen.routeName);
                  },
                  child: const Text("Ok"))
            ]),
      );
    }
    var orderData = args as Map<String, Object>;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: mainColor, size: 32),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ScreenTitle(
            "Оплатіть замовлення",
            subTitle: (orderData["cell_type"] as ACLCellType).onelineTitle,
          ),
        ),
        MainBlock(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Оплатіть замовлення. Після сплати вам відчиниться комірка і ви зможете покласти свої речі",
                style: TextStyle(color: mainColor, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey,
            )
          ],
        )))
      ]),
    );
  }
}
