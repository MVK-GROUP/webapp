import 'package:flutter/material.dart';
import 'package:mvk_app/screens/auth/otp_page.dart';
import 'package:mvk_app/screens/auth/phone_page.dart';
import 'package:mvk_app/screens/auth/welcome_page.dart';
import 'package:mvk_app/screens/global_menu.dart';

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
  final controller = PageController(
    initialPage: 0,
  );
  String? phoneNumber;

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

  void changePageTo(PageType page) {
    switch (page) {
      case PageType.welcome:
        controller.jumpToPage(0);
        break;
      case PageType.enterPhone:
        controller.jumpToPage(1);
        break;
      case PageType.enterOtp:
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          print("changePageTo(2). hasPrimaryFocus");
          currentFocus.unfocus();
        }
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
