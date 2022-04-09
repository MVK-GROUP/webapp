import 'package:flutter/material.dart';
import '../style.dart';
import '../widgets/photo_tile.dart';
import '../models/lockers.dart';
import '../widgets/screen_title.dart';
import '../widgets/main_block.dart';

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
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            iconSize: 36,
            color: mainColor,
            onPressed: () {},
            icon: const Icon(Icons.history),
          ),
          IconButton(
            iconSize: 36,
            color: mainColor,
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
                  ScreenTitle(
                    'Головне меню',
                    subTitle: fullLockerName,
                  ),
                  MainBlock(
                    child: ListView(
                      children: menuItems(),
                    ),
                  )
                ],
              ),
            ),
    );
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
