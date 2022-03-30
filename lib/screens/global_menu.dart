import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  static const routeName = '/menu';

  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Menu')),
    );
  }
}
