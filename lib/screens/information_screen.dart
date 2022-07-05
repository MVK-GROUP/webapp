import 'package:flutter/material.dart';
import 'package:mvk_app/screens/global_menu.dart';

import '../style.dart';

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

  final int? orderId;

  const ErrorPaymentScreen({this.orderId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InformationWidget(
          title: orderId == null ? "Error" : "Success. OrderId: $orderId"),
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
