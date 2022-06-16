import 'package:flutter/material.dart';
import 'package:mvk_app/screens/auth/auth_screen.dart';
import '../../widgets/image_banner.dart';
import '../../widgets/main_button.dart';

class WelcomePage extends StatelessWidget {
  final Function(PageType) changePage;

  const WelcomePage({required this.changePage, Key? key}) : super(key: key);

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
