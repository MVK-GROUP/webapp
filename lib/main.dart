import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'app.dart';

void main() {
  setPathUrlStrategy();
  String url = Uri.base.toString();
  print(url);
  runApp(const App());
}
