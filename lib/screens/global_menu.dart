import 'package:flutter/material.dart';
import '../style.dart';

class MenuScreen extends StatelessWidget {
  static const routeName = '/menu';

  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            iconSize: 36,
            onPressed: () {},
            icon: const Icon(Icons.history),
          ),
          IconButton(
            iconSize: 36,
            onPressed: () {},
            icon: const Icon(Icons.qr_code),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: Container(
          padding: const EdgeInsets.only(top: 20),
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Головне меню',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'HUB Locker #1001, вул. Солом’янська 3',
                          textAlign: TextAlign.center,
                          style: subtitleTextStyle,
                        ),
                      )
                    ]),
              ),
              Expanded(
                child: Container(
                    decoration: const BoxDecoration(
                        color: secondaryBackgroundColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(20),
                            height: 8,
                            width: 80,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 46, left: 30, right: 30),
                          child: ListView(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.only(bottom: 20),
                                height: 100,
                                child: const Text(
                                  'Торговий автомат',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                alignment: Alignment.center,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.only(bottom: 20),
                                height: 100,
                                child: const Text(
                                  'Камера схову',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                alignment: Alignment.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          )),
    );
  }
}
