import 'package:flutter/material.dart';
import '../style.dart';
import '../widgets/photo_tile.dart';
import '../models/lockers.dart';

class MenuScreen extends StatefulWidget {
  static const routeName = '/menu';

  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Locker locker;
  bool isLoading = true;

  @override
  void initState() {
    lockerInit();
    super.initState();
  }

  void lockerInit() {
    var assets = Assets();
    assets.load().then((value) {
      setState(() {
        locker = assets.getLockerById(10002);
        isLoading = false;
      });
    });
  }

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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Головне меню',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                fullLockerName,
                                textAlign: TextAlign.center,
                                style: subtitleTextStyle,
                              ),
                            )
                          ]),
                    ),
                    Expanded(
                      child: Container(
                          margin: const EdgeInsets.only(top: 20),
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
                                    children: menuItems(),
                                  ))
                            ],
                          )),
                    ),
                  ],
                ),
              ));
  }

  List<PhotoTile> menuItems() {
    List<PhotoTile> items = [];
    for (var element in locker.services) {
      items.add(PhotoTile(element.imageUrl, element.title));
    }
    return items;
  }

  String get fullLockerName {
    if (locker.name.isNotEmpty && locker.address != null) {
      return "${locker.name}, ${locker.address}";
    }
    return locker.address ?? locker.name;
  }
}
