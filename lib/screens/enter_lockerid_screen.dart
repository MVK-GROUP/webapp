import 'package:flutter/material.dart';
import 'package:mvk_app/api/http_exceptions.dart';
import 'package:mvk_app/api/orders.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/providers/order.dart';
import 'package:mvk_app/screens/global_menu.dart';
import 'package:mvk_app/screens/qr_scanner_screen.dart';
import 'package:mvk_app/style.dart';
import 'package:mvk_app/widgets/dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../api/lockers.dart';

class EnterLockerIdScreen extends StatefulWidget {
  static const routeName = "/enter-lockerid";

  const EnterLockerIdScreen({Key? key}) : super(key: key);

  @override
  State<EnterLockerIdScreen> createState() => _EnterLockerIdScreenState();
}

class _EnterLockerIdScreenState extends State<EnterLockerIdScreen> {
  late TextEditingController _lockerIdController;
  List<String?> lockerId = [null, null, null, null];
  var isFetchingData = false;

  @override
  void initState() {
    super.initState();
    _lockerIdController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    lockerId = [null, null, null, null];
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _lockerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        iconTheme: const IconThemeData(color: AppColors.mainColor),
        elevation: 0.0,
        actions: [
          IconButton(
            iconSize: 36,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, MenuScreen.routeName, (route) => false);
            },
            icon: const Icon(Icons.home),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: SafeArea(
        child: isFetchingData
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Spacer(),
                      Text(
                        'Проскануйте QR-код',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (kIsWeb) {
                            final lockerId = await Navigator.of(context)
                                .pushNamed(QrScannerScreen.routeName);
                            if (lockerId != null) {
                              if (lockerId is String) {
                                enteredLockerId(context, lockerId);
                              }
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                title: Text("Інформація"),
                                content: Text(
                                    "Даний функціонал не доступний на цьому типі пристрою"),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [AppShadows.getShadow200()],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            SizedBox(
                              height: 92,
                              width: 92,
                              child: Image.asset(
                                "assets/images/scan_qr.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "СКАНУВАТИ QR",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.mainColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 2,
                              indent: 25,
                              endIndent: 25,
                              color: AppColors.mainColor.withOpacity(0.5),
                            ),
                          ),
                          const Text(
                            "АБО",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 2,
                              indent: 25,
                              endIndent: 25,
                              color: AppColors.mainColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Spacer(),
                      Text(
                        'Введіть LockerId',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _textFieldOTP(1),
                            _textFieldOTP(2),
                            _textFieldOTP(3),
                            _textFieldOTP(4),
                          ]),
                      const Spacer(),
                    ]),
              ),
      ),
    );
  }

  bool isValidLockerId(String lockerId) {
    return lockerId.length >= 4 && int.tryParse(lockerId) != null;
  }

  void enteredLockerId(BuildContext context, String lockerId) async {
    if (!isValidLockerId(lockerId)) {
      return;
    }
    setState(() {
      isFetchingData = true;
    });

    final homeMenuButon = TextButton.icon(
      icon: const Icon(Icons.home),
      label: const Text('Головне меню'),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
    try {
      final isActive = await LockerApi.isActive(lockerId);
      if (!isActive) {
        final action = await showDialog(
            context: context,
            builder: (ctx) {
              return DefaultAlertDialog(
                title: "Технічні несправності",
                body: "На жаль, даний комплекс не на зв'язку :(",
                actions: [homeMenuButon],
              );
            });
        Provider.of<OrdersNotifier>(context, listen: false).resetOrders();
        Provider.of<LockerNotifier>(context, listen: false).resetLocker();
        setState(() {
          isFetchingData = false;
        });
        if (action != null) {
          Navigator.pushReplacementNamed(context, MenuScreen.routeName);
        }
        return;
      }

      await Provider.of<LockerNotifier>(context, listen: false)
          .setLocker(lockerId);

      Provider.of<OrdersNotifier>(context, listen: false).resetOrders();
      setState(() {
        isFetchingData = false;
      });
      Navigator.pushNamedAndRemoveUntil(
          context, MenuScreen.routeName, (route) => false);
    } catch (onError) {
      String titleMessage = "Щось пішло не так...";
      String bodyMessage = "Вибачте, в нас технічні неспровності :(";

      if (onError is HttpException) {
        if (onError.statusCode == 404) {
          titleMessage = "Комлпекс не знайдено";
          bodyMessage =
              "Спробуйте відсканувати QR-код на комплексі або введіть коректний LockerID";
        }
      }
      setState(() {
        isFetchingData = false;
      });
      final action = await showDialog(
          context: context,
          builder: (ctx) {
            return DefaultAlertDialog(
              title: titleMessage,
              body: bodyMessage,
              actions: [
                homeMenuButon,
                const SizedBox(width: 5),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16)),
                  icon: const Icon(Icons.qr_code),
                  label: const Text(
                    'Сканувати ще',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });

      if (action == null) {
      } else {
        Navigator.pushReplacementNamed(context, MenuScreen.routeName);
      }
    }
  }

  Widget _textFieldOTP(int index) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppShadows.getShadow100()]),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: AspectRatio(
        aspectRatio: 0.8,
        child: TextField(
            autofocus: true,
            onChanged: (value) {
              if (value.length == 1 && index != 4) {
                FocusScope.of(context).nextFocus();
              }
              if (value.isEmpty && index != 1) {
                FocusScope.of(context).previousFocus();
              }
              if (value.isEmpty) {
                lockerId[index - 1] = null;
              } else {
                lockerId[index - 1] = value;
              }
              if (!lockerId.contains(null)) {
                enteredLockerId(context, lockerId.join(''));
              }
            },
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counter: const Offstage(),
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 2,
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).colorScheme.background,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            )),
      ),
    );
  }
}