import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mvk_app/utilities/locales.dart';
import 'package:url_strategy/url_strategy.dart';
import 'app.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
    child: const App(),
    supportedLocales: SupportedLocales.locales,
    path: 'assets/translations',
  ));
}
