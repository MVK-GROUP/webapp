import 'package:flutter/material.dart';
import '../screens/global_menu.dart';

class Utils {
  static Widget? checkRouteArg(NavigatorState navigator, dynamic arg) {
    if (arg == null) {
      Future.delayed(Duration.zero).then((_) {
        navigator.pushReplacementNamed(MenuScreen.routeName);
      });
      return Container();
    }

    return null;
  }
}
