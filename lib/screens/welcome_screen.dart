import 'package:flutter/material.dart';
import '../widgets/image_banner.dart';
import '../widgets/main_button.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
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
                    'Ми надаємо послуги автоматичних камер зберігання, видачі товарів та багато іншого.',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  padding: const EdgeInsets.all(6.0),
                ),
                const Spacer(),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: MainButton(
                    text: 'Почати',
                    icon: Icons.arrow_right_alt,
                    iconLocation: IconLocation.right,
                    onButtonPress: () => nextScreen(context),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            )),
      )
    ]));
  }

  void nextScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
  }
}
