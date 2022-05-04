import 'package:flutter/material.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/utilities/urils.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import 'history/history_screen.dart';
import 'global_menu.dart';
import '../style.dart';
import '../providers/order.dart';
import '../widgets/button.dart';

class PaymentCheckScreen extends StatefulWidget {
  static const routeName = 'payment-check/';

  const PaymentCheckScreen({Key? key}) : super(key: key);

  @override
  State<PaymentCheckScreen> createState() => _PaymentCheckScreenState();
}

class _PaymentCheckScreenState extends State<PaymentCheckScreen> {
  var _isLoading = false;
  var _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });

      final arg = ModalRoute.of(context)?.settings.arguments;
      var locker = Provider.of<LockerNotifier>(context).locker;
      if (arg == null || locker == null) {
        Navigator.pushReplacementNamed(context, MenuScreen.routeName);
        return;
      }

      final existArgs = arg as Map<String, Object>;
      final order = existArgs["order"] as TemporaryOrderData;
      Provider.of<OrdersNotifier>(context)
          .addOrder(locker.lockerId, order.title, data: order.extraData)
          .then((value) {
        print("value: $value");
        setState(() {
          _isLoading = false;
        });
      }).catchError((err) {
        print("error: $err");
      });
      super.didChangeDependencies();
    }
    _isInit = true;
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    var locker = Provider.of<LockerNotifier>(context).locker;
    if (arg == null || locker == null) {
      return Utils.goToMenu(Navigator.of(context));
    }
    final existArgs = arg as Map<String, Object>;
    final order = existArgs["order"] as TemporaryOrderData;

    return Scaffold(body: SafeArea(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
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
                              order.helperText ?? "",
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
