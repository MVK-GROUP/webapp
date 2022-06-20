import 'package:flutter/material.dart';
import 'package:mvk_app/screens/auth/auth_screen.dart';
import 'package:mvk_app/widgets/confirm_dialog.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import 'goods/goods_screen.dart';
import 'size_selection_screen.dart';
import 'history/history_screen.dart';
import 'enter_lockerid_screen.dart';
import '../style.dart';
import '../models/lockers.dart';
import '../widgets/photo_tile.dart';
import '../widgets/icon_tile.dart';
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
          const SizedBox(width: 10),
          IconButton(
            iconSize: 26,
            color: AppColors.mainColor,
            onPressed: () async {
              var isConfirmed = await showDialog(
                  context: context,
                  builder: (context) => const ConfirmDialog(
                      title: "Вихід",
                      text: "Ви впевнені що хочете вийти з цього акаунту?"));
              if (isConfirmed != null) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AuthScreen.routeName, (route) => false);
                Provider.of<Auth>(context, listen: false).logout();
              }
            },
            icon: const Icon(Icons.exit_to_app),
          ),
          const Spacer(),
          IconButton(
            iconSize: 36,
            color: AppColors.mainColor,
            onPressed: () {
              Navigator.of(context).pushNamed(HistoryScreen.routeName);
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            iconSize: 36,
            color: AppColors.mainColor,
            onPressed: () {
              Navigator.of(context).pushNamed(EnterLockerIdScreen.routeName);
            },
            icon: const Icon(Icons.qr_code),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<LockerNotifier>(
              builder: (context, lockerNotifier, child) {
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      ScreenTitle(
                        'Головне меню',
                        subTitle: lockerNotifier.locker == null
                            ? "Для нових замовлень потрібно знайти Locker"
                            : lockerNotifier.locker?.fullLockerName,
                      ),
                      if (lockerNotifier.locker == null)
                        MainBlock(
                          maxWidth: 400,
                          child: ListView(children: iconTiles(context)),
                        ),
                      if (lockerNotifier.locker != null)
                        MainBlock(
                          child: ListView(
                              shrinkWrap: true,
                              children:
                                  menuItems(context, lockerNotifier.locker)),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void onTap(BuildContext context, Service service) {
    String routeName;
    switch (service.category) {
      case ServiceCategory.vendingMachine:
        routeName = GoodsScreen.routeName;
        break;
      case ServiceCategory.acl:
        routeName = SizeSelectionScreen.routeName;
        break;
      default:
        showDialog(
            context: context,
            builder: (context) => const AlertDialog(
                  title: Text("Ще не реалізовано"),
                  content: Text("Даний функціонал буде реалізовано пізніше"),
                ));
        return;
    }
    Provider.of<ServiceNotifier>(context, listen: false).setService(service);
    Navigator.pushNamed(context, routeName);
  }

  List<PhotoTile> menuItems(BuildContext context, Locker? lckr) {
    List<PhotoTile> items = [];
    for (var element in lckr!.services) {
      items.add(PhotoTile(
        id: element.serviceId,
        imageUrl: element.imageUrl,
        backgroundColor: element.color,
        title: element.action,
        onTap: () => onTap(context, element),
      ));
    }

    return items;
  }

  List<Widget> iconTiles(BuildContext context) {
    return [
      const SizedBox(height: 20),
      IconTile(
        text: "Знайти комплекс",
        icon: Icons.qr_code_scanner_outlined,
        onTap: () {
          Navigator.pushNamed(context, EnterLockerIdScreen.routeName);
        },
      ),
      const SizedBox(height: 20),
      IconTile(
        text: "Історія замовлень",
        icon: Icons.history,
        onTap: () {
          Navigator.pushNamed(context, HistoryScreen.routeName);
        },
      ),
    ];
  }
}
