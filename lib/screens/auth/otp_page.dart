import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mvk_app/providers/auth.dart';
import 'package:mvk_app/style.dart';
import 'package:provider/provider.dart';
import '../../api/auth.dart';
import 'auth_screen.dart' show PageType;

class OtpPage extends StatefulWidget {
  final Function(PageType) changePage;
  final String phoneNumber;

  const OtpPage({required this.changePage, required this.phoneNumber, Key? key})
      : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  List<String?> otpCode = [null, null, null, null];
  bool _isWrongCode = false;
  bool _isLoading = false;
  bool _isCanResend = false;
  bool _isResendLoading = false;
  Timer? _timer;
  int _start = 20;

  @override
  void initState() {
    super.initState();
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
          : Column(children: [
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
                      style:
                          const TextStyle(fontSize: 18, color: Colors.black45),
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
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              ),
              const SizedBox(
                height: 36,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _textFieldOTP(1),
                _textFieldOTP(2),
                _textFieldOTP(3),
                _textFieldOTP(4),
              ]),
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
                      showSnackbarMessage("Не вдалось повторно відправити код");
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
            ]),
    );
  }

  Widget _textFieldOTP(int index) {
    return Container(
      height: 75,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: AspectRatio(
        aspectRatio: 0.8,
        child: TextField(
            autofocus: true,
            onChanged: (value) async {
              if (value.length == 1 && index != 4) {
                FocusScope.of(context).nextFocus();
              }
              if (value.isEmpty && index != 1) {
                FocusScope.of(context).previousFocus();
              }
              if (value.isEmpty) {
                otpCode[index - 1] = null;
              } else {
                otpCode[index - 1] = value;
              }
              if (!otpCode.contains(null)) {
                final otpCodeStr = otpCode.join('');

                setState(() {
                  _isLoading = true;
                });
                try {
                  await Provider.of<Auth>(context, listen: false)
                      .confirmOtp(widget.phoneNumber, otpCodeStr);
                  widget.changePage(PageType.nextScreen);
                } catch (e) {
                  setState(() {
                    _isWrongCode = true;
                    otpCode = [null, null, null, null];
                  });
                }

                setState(() {
                  _isLoading = false;
                });
              }
            },
            showCursor: false,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counter: const Offstage(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 2, color: Theme.of(context).colorScheme.secondary),
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

  void showSnackbarMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      text,
      textAlign: TextAlign.center,
    )));
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
}
