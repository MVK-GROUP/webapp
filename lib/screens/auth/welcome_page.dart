import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mvk_app/screens/auth/auth_screen.dart';
import 'package:mvk_app/style.dart';
import 'package:mvk_app/utilities/locales.dart';
import '../../widgets/image_banner.dart';
import '../../widgets/main_button.dart';

class WelcomePage extends StatelessWidget {
  final Function(PageType) changePage;
  final Function(LocaleObject?) selectedLocale;
  final LocaleObject currentLocale;

  const WelcomePage(
      {required this.changePage,
      required this.currentLocale,
      required this.selectedLocale,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const ImageBanner(
                  'assets/images/welcome_img.png',
                  imageFit: BoxFit.fitHeight,
                  hConstraint: 280,
                ),
                Container(
                  child: Text(
                    'auth.welcome_title'.tr(),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  padding: const EdgeInsets.all(6.0),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.public,
                      color: AppColors.mainColor,
                      size: 32,
                    ),
                    const SizedBox(width: 20),
                    LanguageDropDownWidget(
                        locale: currentLocale, selectedLocale: selectedLocale),
                  ],
                ),
                const Spacer(),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: MainButton(
                    text: 'auth.welcome_start'.tr(),
                    icon: Icons.arrow_right_alt,
                    iconLocation: IconLocation.right,
                    onButtonPress: () => changePage(PageType.enterPhone),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            )),
      )
    ]);
  }
}

class LanguageDropDownWidget extends StatelessWidget {
  final LocaleObject locale;
  final Function selectedLocale;

  const LanguageDropDownWidget(
      {required this.locale, required this.selectedLocale, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<LocaleObject>(
      value: locale,
      icon: const Icon(Icons.keyboard_arrow_down),
      elevation: 4,
      underline: null,
      style: const TextStyle(
          color: AppColors.mainColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.8),
      focusColor: Colors.white,
      onChanged: (LocaleObject? newValue) => selectedLocale(newValue),
      items: SupportedLocales.lockaleObjects.map((LocaleObject value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value.title),
        );
      }).toList(),
    );
  }
}
