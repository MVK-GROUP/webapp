import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Text(
              "Зачекайте, іде перевірка замовленя...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}
