import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvk_app/api/http_exceptions.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/screens/global_menu.dart';
import 'package:mvk_app/screens/qr_scanner_screen.dart';
import 'package:mvk_app/style.dart';
import 'package:mvk_app/widgets/dialog.dart';
import 'package:pinput/pinput.dart';
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
                        'set_locker.scan_qr'.tr(),
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
                              builder: (context) => AlertDialog(
                                title: Text("information".tr()),
                                content:
                                    Text("functionality_is_not_available".tr()),
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
                            Text(
                              "set_locker.scan_qr_action".tr(),
                              style: const TextStyle(
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
                          Text(
                            "set_locker.or".tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
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
                        'set_locker.enter_locker_id'.tr(),
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
                            child: buildLockerIdInputWidget(),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ]),
              ),
      ),
    );
  }

  Widget buildLockerIdInputWidget() {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
          fontSize: 24,
          color: AppColors.mainColor,
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [AppShadows.getShadow200()],
        borderRadius: BorderRadius.circular(12),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border:
          Border.all(color: Theme.of(context).colorScheme.background, width: 2),
    );
    return Pinput(
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      length: 4,
      onCompleted: (otpCode) async {
        await enteredLockerId();
      },
      onChanged: (value) {
        setState(() {
          lockerId = value;
        });
      },
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
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
      label: Text('main_menu'.tr()),
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
                title: "attention_title".tr(),
                body: "complex_offline".tr(),
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
      String titleMessage = "something_went_wrong_with_dots".tr();
      String bodyMessage = "we_have_technical_problems".tr();

      if (onError is HttpException) {
        if (onError.statusCode == 404) {
          titleMessage = "set_locker.complex_not_found".tr();
          bodyMessage = "set_locker.try_scan_qr_or_enter_id".tr();
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
                  label: Text(
                    'set_locker.scan_again'.tr(),
                    style: const TextStyle(fontSize: 16),
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
