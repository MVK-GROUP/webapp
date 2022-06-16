import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'app.dart';

Future<void> main() async {
  setPathUrlStrategy();
  runApp(const App());
}
