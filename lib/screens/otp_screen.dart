import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = '/otp-confirm';

  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<String?> otpCode = [null, null, null, null];
  bool isWrongCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              text: const TextSpan(
                  style: TextStyle(fontSize: 18, color: Colors.black45),
                  children: [
                    TextSpan(
                        text: 'Введіть код, який був відправлений на номер '),
                    TextSpan(
                        text: '+380954941949',
                        style: TextStyle(fontWeight: FontWeight.bold))
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
          if (isWrongCode)
            const Text(
              'Неправильний код',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(
            height: 18,
          ),
          const Spacer(),
          const Text(
            'Не отримали код?',
            style: TextStyle(fontSize: 16, color: Colors.black45),
          ),
          const SizedBox(
            width: 5,
          ),
          TextButton(
            onPressed: () {},
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
      ),
    ));
  }

  Widget _textFieldOTP(int index) {
    return Container(
      height: 75,
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
                otpCode[index - 1] = null;
              } else {
                otpCode[index - 1] = value;
              }
              if (!otpCode.contains(null)) {
                print('otp code: $otpCode');
                if (otpCode.join('') != '1111') {
                  setState(() {
                    isWrongCode = true;
                  });
                } else {
                  setState(() {
                    isWrongCode = false;
                  });
                  print('code is correct...');
                }
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
}
