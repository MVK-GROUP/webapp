import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mvk_app/screens/auth/otp_page.dart';
import 'package:mvk_app/screens/auth/phone_page.dart';
import 'package:mvk_app/screens/auth/welcome_page.dart';
import 'package:mvk_app/screens/global_menu.dart';
import 'package:mvk_app/utilities/locales.dart';

enum PageType {
  welcome,
  enterPhone,
  enterOtp,
  nextScreen,
}

class AuthScreen extends StatefulWidget {
  final String? prevRouteName;

  const AuthScreen({this.prevRouteName, Key? key}) : super(key: key);
  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late LocaleObject currentLocale;
  bool isInit = false;
  final controller = PageController(
    initialPage: 0,
  );
  String? phoneNumber;

  @override
  void didChangeDependencies() {
    if (!isInit) {
      currentLocale =
          SupportedLocales.getLocaleByCode(context.locale.languageCode);
      isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          WelcomePage(
            changePage: changePageTo,
            selectedLocale: changeLocale,
            currentLocale: currentLocale,
          ),
          PhoneWidget(
            changePage: changePageTo,
            setPhone: setPhoneNumber,
          ),
          OtpNewPage(
            phoneNumber: phoneNumber ?? "",
            changePage: changePageTo,
          ),
        ],
      ),
    ));
  }

  void changeLocale(LocaleObject? localeObject) async {
    if (localeObject != null) {
      setState(() {
        currentLocale = localeObject;
      });
      await context.setLocale(localeObject.locale);
    }
  }

  void changePageTo(PageType page) async {
    switch (page) {
      case PageType.welcome:
        controller.jumpToPage(0);
        break;
      case PageType.enterPhone:
        controller.jumpToPage(1);
        break;
      case PageType.enterOtp:
        controller.jumpToPage(2);
        break;
      case PageType.nextScreen:
        if (widget.prevRouteName != null) {
          Navigator.pushReplacementNamed(context, widget.prevRouteName ?? '/');
        } else {
          Navigator.pushReplacementNamed(context, MenuScreen.routeName);
        }
        break;
      default:
    }
  }

  void setPhoneNumber(String? phone) {
    setState(() {
      phoneNumber = phone;
    });
  }
}
