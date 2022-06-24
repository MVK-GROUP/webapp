import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvk_app/api/http_exceptions.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/screens/global_menu.dart';
import 'package:mvk_app/screens/qr_scanner_screen.dart';
import 'package:mvk_app/style.dart';
import 'package:mvk_app/widgets/dialog.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
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
  var isFetchingData = false;

  String lockerId = "";
  final formKey = GlobalKey<FormState>();

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
                            final res = await Navigator.of(context)
                                .pushNamed(QrScannerScreen.routeName);
                            if (res != null) {
                              if (res is String) {
                                lockerId = res;
                                enteredLockerId();
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
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: Form(
                          key: formKey,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 30),
                              child: PinCodeTextField(
                                appContext: context,
                                autoFocus: false,
                                textStyle: const TextStyle(
                                  color: AppColors.mainColor,
                                  fontSize: 24,
                                ),
                                pastedTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                length: 4,
                                blinkWhenObscuring: true,
                                animationType: AnimationType.fade,
                                pinTheme: PinTheme(
                                  activeColor: Colors.white,
                                  selectedColor:
                                      Theme.of(context).colorScheme.background,
                                  selectedFillColor: Colors.white,
                                  inactiveFillColor: Colors.white,
                                  inactiveColor: Colors.white,
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(12),
                                  fieldHeight: 60,
                                  fieldWidth: 60,
                                  activeFillColor: Colors.white,
                                ),
                                cursorColor: AppColors.mainColor,
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                enableActiveFill: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        signed: true, decimal: true),
                                boxShadows: [AppShadows.getShadow100()],
                                onCompleted: (v) async {
                                  await enteredLockerId();
                                },
                                onChanged: (value) {
                                  setState(() {
                                    lockerId = value;
                                  });
                                },
                                beforeTextPaste: (text) {
                                  debugPrint("Allowing to paste $text");
                                  return true;
                                },
                              )),
                        ),
                      ),
                      const Spacer(),
                    ]),
              ),
      ),
    );
  }

  bool isValidLockerId(String lockerId) {
    return lockerId.length >= 4 && int.tryParse(lockerId) != null;
  }

  Future<void> enteredLockerId() async {
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
}