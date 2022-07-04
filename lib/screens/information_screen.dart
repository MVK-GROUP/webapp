import 'package:flutter/material.dart';
import 'package:mvk_app/screens/global_menu.dart';

import '../style.dart';

class SuccessPaymentScreen extends StatelessWidget {
  static const routeName = '/success-payment/';
  const SuccessPaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const InformationWidget(
        title: "Success",
      ),
    );
  }
}

class ErrorPaymentScreen extends StatelessWidget {
  static const routeName = '/error-payment/';
  const ErrorPaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.mainColor, size: 32),
      ),
      body: const InformationWidget(title: "Error"),
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
