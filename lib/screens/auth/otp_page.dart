import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvk_app/providers/auth.dart';
import 'package:mvk_app/style.dart';
import 'package:provider/provider.dart';
import '../../api/auth.dart';
import 'package:pinput/pinput.dart';
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
  bool _isInit = false;
  bool _isWrongCode = false;
  bool _isLoading = false;
  bool _isCanResend = false;
  bool _isResendLoading = false;
  Timer? _timer;
  int _start = 20;
  late FocusNode _focusNode;
  late double screenWidth;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      startTimer();
      _focusNode = FocusNode();
      screenWidth = MediaQuery.of(context).size.width;
      _isInit = true;
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => FocusScope.of(context).requestFocus(_focusNode));
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer!.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Widget buildOtpInputWidget() {
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
      autofillHints: const [AutofillHints.oneTimeCode],
      keyboardType: TextInputType.text,
      autofocus: true,
      focusNode: _focusNode,
      length: 4,
      onCompleted: (otpCode) async {
        setState(() {
          _isLoading = true;
        });
        try {
          await Provider.of<Auth>(context, listen: false)
              .confirmOtp(widget.phoneNumber, otpCode);
          widget.changePage(PageType.nextScreen);
        } catch (e) {
          setState(() {
            _isWrongCode = true;
            _isLoading = false;
          });
        }
      },
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
    );
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
                  'auth.phone_verification'.tr(),
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
                          TextSpan(text: 'auth.otp_enter_code'.tr()),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: ' ' + 'auth.otp_change_number'.tr(),
                              style: const TextStyle(
                                  color: AppColors.secondaryColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  widget.changePage(PageType.enterPhone);
                                }),
                        ]),
                  ),
                  margin: EdgeInsets.symmetric(
                      horizontal: screenWidth > 385 ? 30 : 10, vertical: 5),
                ),
                const SizedBox(
                  height: 30,
                ),
                buildOtpInputWidget(),
                const SizedBox(height: 10),
                if (_isWrongCode)
                  Text(
                    'auth.otp_invalid_code'.tr(),
                    style: const TextStyle(
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
                    'auth.otp_repeat'
                        .tr(namedArgs: {'time': _start.toString()}),
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
                          showSnackbarMessage("auth.otp_sending_error".tr());
                        }
                      } catch (e) {
                        showSnackbarMessage("auth.otp_sending_error".tr());
                      }

                      setState(() {
                        _isResendLoading = false;
                        _isCanResend = false;
                        _start = 20;
                        startTimer();
                      });
                    },
                    child: Text(
                      'auth.otp_send_new_code'.tr(),
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
