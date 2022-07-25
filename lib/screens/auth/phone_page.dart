import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mvk_app/api/auth.dart';
import '../../widgets/main_button.dart';
import 'auth_screen.dart' show PageType;

class PhoneWidget extends StatefulWidget {
  final Function(PageType) changePage;
  final Function(String?) setPhone;

  const PhoneWidget(
      {required this.changePage, required this.setPhone, Key? key})
      : super(key: key);

  @override
  State<PhoneWidget> createState() => _PhoneWidgetState();
}

class _PhoneWidgetState extends State<PhoneWidget> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'UA';
  PhoneNumber number = PhoneNumber(isoCode: 'UA');
  bool _isSendingPhone = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_focusNode));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            Text(
              'phone_verification'.tr(),
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: InternationalPhoneNumberInput(
                autoFocus: true,
                focusNode: _focusNode,
                inputDecoration: InputDecoration(
                    hintText: 'phone_number'.tr(),
                    hintStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.black38),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 3)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.background,
                            width: 3))),
                onInputChanged: (PhoneNumber currentNumber) {
                  number = currentNumber;
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'phone_invalid_number'.tr();
                  }
                  return null;
                },
                textStyle: const TextStyle(fontSize: 24, letterSpacing: 1.5),
                selectorTextStyle: const TextStyle(fontSize: 20),
                selectorConfig: const SelectorConfig(
                  setSelectorButtonAsPrefixIcon: true,
                  leadingPadding: 20,
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                initialValue: number,
                formatInput: false,
                textFieldController: controller,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
              ),
            ),
            Container(
              child: Text(
                'phone_help_text'.tr(),
                style: const TextStyle(fontSize: 18, color: Colors.black45),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            ),
            const SizedBox(
              height: 20,
            ),
            const Spacer(),
            _isSendingPhone
                ? const MainButton(isWaitingButton: true, mHorizontalInset: 30)
                : MainButton(
                    text: 'phone_get_code'.tr(),
                    onButtonPress: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      formKey.currentState!.save();

                      setState(() {
                        _isSendingPhone = true;
                      });
                      if (number.phoneNumber != null) {
                        try {
                          final wasSent =
                              await AuthApi.createOtp(number.phoneNumber ?? "");

                          if (wasSent) {
                            widget.setPhone(number.phoneNumber);
                            widget.changePage(PageType.enterOtp);
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      content: Text("phone_not_sent".tr()),
                                    ));
                          }
                        } catch (e) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    content: Text("phone_not_sent".tr()),
                                  ));
                        }
                      }

                      setState(() {
                        _isSendingPhone = false;
                      });
                    },
                    mHorizontalInset: 30,
                  ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
