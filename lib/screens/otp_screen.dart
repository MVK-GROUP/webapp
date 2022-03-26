import 'package:flutter/material.dart';
import '../widgets/main_button.dart';
import '../colors.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = '/otp-confirm';

  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xfff7f6fb),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/welcome_img.png',
                width: 240,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _textFieldOTP(first: true),
              _textFieldOTP(),
              _textFieldOTP(),
              _textFieldOTP(last: true),
            ]),
            Container(
              child: RichText(
                text: const TextSpan(
                    style: TextStyle(fontSize: 18, color: Colors.black45),
                    children: [
                      TextSpan(text: 'Код був відправлений на номер '),
                      TextSpan(
                          text: '+380954941949',
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            ),
            const SizedBox(
              height: 40,
            ),
            MainButton(text: 'Перевірити', onButtonPress: () {}),
          ]),
        ),
      ),
    );
  }

  Widget _textFieldOTP({bool first = false, bool last = false}) {
    return Container(
      height: 75,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: AspectRatio(
        aspectRatio: 0.8,
        child: TextField(
            autofocus: true,
            onChanged: (value) {
              if (value.length == 1 && last == false) {
                FocusScope.of(context).nextFocus();
              }
              if (value.isEmpty && first == false) {
                FocusScope.of(context).previousFocus();
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
                borderSide: const BorderSide(width: 2, color: secondaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2, color: Colors.blue),
                borderRadius: BorderRadius.circular(12),
              ),
            )),
      ),
    );
  }
}
