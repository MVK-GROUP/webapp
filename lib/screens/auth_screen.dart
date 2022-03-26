import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../widgets/main_button.dart';
import 'otp_screen.dart';
import '../colors.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuthBody(),
    );
  }
}

class AuthBody extends StatefulWidget {
  const AuthBody({Key? key}) : super(key: key);

  @override
  State<AuthBody> createState() => _AuthBodyState();
}

class _AuthBodyState extends State<AuthBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'UA';
  PhoneNumber number = PhoneNumber(isoCode: 'UA');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: InternationalPhoneNumberInput(
              inputDecoration: InputDecoration(
                  hintText: 'Номер телефону',
                  hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.black38),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: secondaryColor, width: 3))),
              onInputChanged: (PhoneNumber number) {},
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return 'Некоректний номер телефону';
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
            child: const Text(
              'Ми відправимо SMS-код для підтвердження номеру телефону',
              style: TextStyle(fontSize: 18, color: Colors.black45),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          ),
          const SizedBox(
            height: 100,
          ),
          MainButton(
            text: 'Далі',
            onButtonPress: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
              formKey.currentState!.save();

              Navigator.of(context).pushNamed(OtpScreen.routeName);
            },
            mHorizontalInset: 30,
          ),
        ],
      ),
    );
  }

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');

    setState(() {
      this.number = number;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
