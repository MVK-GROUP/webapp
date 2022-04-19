import 'package:flutter/material.dart';
import 'history/history_screen.dart';
import 'global_menu.dart';
import '../style.dart';
import '../widgets/button.dart';

class PaymentCheckScreen extends StatelessWidget {
  static const routeName = 'payment-check/';

  const PaymentCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 35, right: 35, top: 20),
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
                        "Замовлення оплачено. Зараз відчиниться комірка #7 та роздрукується чек. Обережно покладіть речі та закрийте комірку",
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
                      ElevatedIconButton(
                        icon: const Icon(Icons.history),
                        text: "Переглянути замовлення",
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, HistoryScreen.routeName);
                        },
                      ),
                      const SizedBox(height: 15),
                      ElevatedIconButton(
                        icon: const Icon(Icons.home),
                        text: "До головного меню",
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, MenuScreen.routeName);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ]),
          ),
        );
      }),
    ));
  }
}
