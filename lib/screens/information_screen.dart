import 'package:flutter/material.dart';
import 'package:mvk_app/screens/global_menu.dart';

import '../style.dart';
import '../widgets/button.dart';

class SuccessPaymentScreen extends StatelessWidget {
  static const routeName = '/success-payment/';

  final int? orderId;

  const SuccessPaymentScreen({this.orderId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InformationWidget(
        title: orderId == null ? "Success" : "Success. OrderId: $orderId",
      ),
    );
  }
}

class ErrorPaymentScreen extends StatelessWidget {
  static const routeName = '/error-payment/';

  final String? title;

  const ErrorPaymentScreen({this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Нажаль, сталася помилка",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(color: AppColors.secondaryColor),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 200,
                child: Image.asset("assets/images/error.png"),
              ),
              const SizedBox(height: 25),
              Text(
                title ?? "",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 40),
              ElevatedIconButton(
                icon: const Icon(Icons.home),
                text: "До головного меню",
                onPressed: () {
                  Navigator.pushReplacementNamed(context, MenuScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InformationWidget extends StatelessWidget {
  final String title;
  const InformationWidget({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, MenuScreen.routeName);
                },
                child: const Text("До головного меню"))
          ]),
    );
  }
}
