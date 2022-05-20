import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mvk_app/screens/enter_lockerid_screen.dart';
import 'package:mvk_app/screens/global_menu.dart';
import 'package:mvk_app/style.dart';
import 'package:provider/provider.dart';

import '../api/http_exceptions.dart';
import '../api/orders.dart';
import '../models/lockers.dart';
import '../providers/order.dart';
import '../widgets/button.dart';

class ConfirmLockerScreen extends StatefulWidget {
  final String lockerId;
  const ConfirmLockerScreen(this.lockerId, {Key? key}) : super(key: key);

  @override
  State<ConfirmLockerScreen> createState() => _ConfirmLockerScreenState();
}

class _ConfirmLockerScreenState extends State<ConfirmLockerScreen> {
  late Future _getLockerFuture;
  Locker? locker;

  Future _obtainGetLockerFuture() async {
    final isExist = await OrderApi.isExistActiveOrders();
    if (isExist) {
      try {
        await Provider.of<LockerNotifier>(context, listen: false)
            .setLocker(widget.lockerId);
        Navigator.of(context).pushReplacementNamed(MenuScreen.routeName);
        return;
      } catch (e) {
        if (e is HttpException) {
          if (e.statusCode == 404) {
            Navigator.of(context)
                .pushReplacementNamed(EnterLockerIdScreen.routeName);
            return;
          }
        }
        Navigator.of(context).pushReplacementNamed(MenuScreen.routeName);
        return;
      }
    }
    try {
      locker = await LockerApi.fetchLockerById(widget.lockerId);
    } catch (e) {
      Navigator.of(context).pushReplacementNamed(EnterLockerIdScreen.routeName);
      return;
    }
  }

  @override
  void initState() {
    _getLockerFuture = _obtainGetLockerFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: _getLockerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center();
                } else {
                  if (snapshot.error != null) {
                    // TODO: notify user OR/AND go to menu screen
                    print("Error: ${snapshot.error.toString()}");
                    return Center(
                      child: Text("Error: ${snapshot.error.toString()}"),
                    );
                  } else {
                    if (locker != null) {
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Column(
                          children: [
                            const Text(
                              "Комплекс перед Вами має такий вигляд та адрес?",
                              textAlign: TextAlign.center,
                              style: AppStyles.titleSecondaryTextStyle,
                            ),
                            const SizedBox(height: 10),
                            if (locker!.imageUrl == null)
                              Image.asset(
                                "assets/images/no-image-2.png",
                                width: 250,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            if (locker!.imageUrl != null)
                              Image.network(
                                locker!.imageUrl ??
                                    "http://placehold.jp/3d4070/ffffff/250x250.png?text=NO%20IMAGE&css=%7B%22border-radius%22%3A%2230px%22%7D",
                                width: 250,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              locker!.fullLockerName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.mainColor),
                            ),
                            const SizedBox(height: 20),
                            ElevatedDefaultButton(
                                child: const Text(
                                  "ТАК",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 4),
                                ),
                                buttonColor: AppColors.successColor,
                                onPressed: () {
                                  Provider.of<LockerNotifier>(context,
                                          listen: false)
                                      .setExistingLocker(locker);
                                  Provider.of<OrdersNotifier>(context,
                                          listen: false)
                                      .resetOrders();
                                  Navigator.pushReplacementNamed(
                                      context, MenuScreen.routeName);
                                }),
                            const SizedBox(height: 30),
                            ElevatedIconButton(
                              icon: const Icon(Icons.qr_code_scanner_outlined),
                              textStyle: GoogleFonts.openSans(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                              text: "Ні, сканувати комплекс",
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, EnterLockerIdScreen.routeName);
                              },
                            ),
                            const SizedBox(height: 15),
                            ElevatedIconButton(
                              icon: const Icon(Icons.home),
                              text: "До головного меню",
                              textStyle: GoogleFonts.openSans(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, MenuScreen.routeName);
                              },
                            ),
                          ],
                        ),
                      ));
                    } else {
                      return const Center();
                    }
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
