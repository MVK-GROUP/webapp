import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:mvk_app/providers/auth.dart';
import 'package:mvk_app/style.dart';
import 'package:provider/provider.dart';
import '../../api/auth.dart';
import 'auth_screen.dart' show PageType;

class OtpNewPage extends StatefulWidget {
  final Function(PageType) changePage;
  final String phoneNumber;

  const OtpNewPage(
      {required this.changePage, required this.phoneNumber, Key? key})
      : super(key: key);

  @override
  State<OtpNewPage> createState() => _OtpNewPageState();
}

class _OtpNewPageState extends State<OtpNewPage> {
  bool _isWrongCode = false;
  bool _isLoading = false;
  bool _isCanResend = false;
  bool _isResendLoading = false;
  Timer? _timer;
  int _start = 20;
  final FocusNode _focusNode = FocusNode();
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_focusNode));
    Future.delayed(Duration.zero, () {
      startTimer();
    });
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Верифікація',
                  style: Theme.of(context).textTheme.headline4,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black45),
                        children: [
                          const TextSpan(
                              text:
                                  'Введіть код, який був відправлений на номер '),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: ' (змінити)',
                              style: const TextStyle(
                                  color: AppColors.secondaryColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  widget.changePage(PageType.enterPhone);
                                  //Navigator.pushReplacementNamed(
                                  //    context, AuthScreen.routeName);
                                }),
                        ]),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: Form(
                    key: formKey,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 30),
                        child: PinCodeTextField(
                          focusNode: _focusNode,
                          appContext: context,
                          autoFocus: true,
                          enablePinAutofill: false,
                          textStyle: const TextStyle(
                            color: AppColors.mainColor,
                            fontSize: 24,
                          ),
                          pastedTextStyle: const TextStyle(
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 4,
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            activeColor: AppColors.secondaryColor,
                            selectedColor:
                                Theme.of(context).colorScheme.background,
                            selectedFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            inactiveColor: AppColors.secondaryColor,
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(12),
                            fieldHeight: 60,
                            fieldWidth: 60,
                            activeFillColor: Colors.white,
                          ),
                          cursorColor: AppColors.mainColor,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          boxShadows: [AppShadows.getShadow200()],
                          onCompleted: (v) async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await Provider.of<Auth>(context, listen: false)
                                  .confirmOtp(widget.phoneNumber, currentText);
                              widget.changePage(PageType.nextScreen);
                            } catch (e) {
                              setState(() {
                                _isWrongCode = true;
                                _isLoading = false;
                              });
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            debugPrint("Allowing to paste $text");
                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            return true;
                          },
                        )),
                  ),
                ),
                if (_isWrongCode)
                  const Text(
                    'Ви ввели не правильний код або час для введення коду закінчився',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(
                  height: 18,
                ),
                const Spacer(),
                if (!_isCanResend && !_isResendLoading)
                  Text(
                    'Повторно відправити код через $_start',
                    style: const TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                if (_isResendLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                if (_isCanResend && !_isResendLoading)
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        _isResendLoading = true;
                        _isCanResend = false;
                        _isWrongCode = false;
                      });
                      try {
                        final wasSent =
                            await AuthApi.createOtp(widget.phoneNumber);
                        if (!wasSent) {
                          showSnackbarMessage(
                              "Не вдалось повторно відправити код");
                        }
                      } catch (e) {
                        showSnackbarMessage(
                            "Не вдалось повторно відправити код");
                      }

                      setState(() {
                        _isResendLoading = false;
                        _isCanResend = false;
                        _start = 20;
                        startTimer();
                      });
                    },
                    child: Text(
                      'Відправити новий код',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
    );
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _isCanResend = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void showSnackbarMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      text,
      textAlign: TextAlign.center,
    )));
  }
}
