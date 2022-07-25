import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mvk_app/api/http_exceptions.dart';
import 'package:mvk_app/models/order.dart';
import 'package:mvk_app/providers/order.dart';
import 'package:mvk_app/screens/acl/choose_order_screen.dart';
import 'package:mvk_app/screens/auth/auth_screen.dart';
import 'package:mvk_app/widgets/confirm_dialog.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import 'goods/goods_screen.dart';
import 'history/detail_order_dialog.dart';
import 'acl/size_selection_screen.dart';
import 'history/history_screen.dart';
import 'enter_lockerid_screen.dart';
import '../style.dart';
import '../models/lockers.dart';
import '../widgets/photo_tile.dart';
import '../widgets/icon_tile.dart';
import '../widgets/main_block.dart';

class MenuScreen extends StatefulWidget {
  static const routeName = '/menu';

  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Locker? locker;
  late Future _initOrdersFuture;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      locker = Provider.of<LockerNotifier>(context, listen: false).locker;
      _initOrdersFuture = _obtainInitOrdersFuture();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  Future<List<OrderData>?> _obtainInitOrdersFuture() async {
    final ordersNotifier = Provider.of<OrdersNotifier>(context, listen: false);
    if (ordersNotifier.orders == null) {
      try {
        await ordersNotifier.fetchAndSetOrders();
      } catch (e) {
        if (e is HttpException && e.statusCode == 401) {
          Navigator.pushNamedAndRemoveUntil(
              context, AuthScreen.routeName, (route) => false);
        }
        return Future.error(e.toString());
      }
    }
    return ordersNotifier.getActiveAclsOrders();
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
                  builder: (context) => ConfirmDialog(
                      title: "home.logout".tr(),
                      text: "home.logout_confirm".tr()));
              if (isConfirmed != null) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AuthScreen.routeName, (route) => false);

                Provider.of<Auth>(context, listen: false).logout();
                Provider.of<OrdersNotifier>(context, listen: false)
                    .resetOrders();
                Provider.of<LockerNotifier>(context, listen: false)
                    .resetLocker();
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
      body: SizedBox(
          width: double.infinity,
          child: FutureBuilder(
              future: _initOrdersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center();
                } else {
                  if (snapshot.error != null) {
                    print("Error: ${snapshot.error.toString()}");
                    return Center(
                      child: Text("home.unknown_error".tr()),
                    );
                  }
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 40),
                        width: 220,
                        child: Image.asset(
                          "assets/logo/mvk_logo.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Text(
                          locker == null
                              ? "home.no_locker".tr()
                              : locker?.fullLockerName ?? "",
                          textAlign: TextAlign.center,
                          style: AppStyles.subtitleTextStyle,
                        ),
                      ),
                      if (locker == null)
                        MainBlock(
                          maxWidth: 400,
                          child: ListView(children: iconTiles(context)),
                        ),
                      if (locker != null)
                        MainBlock(
                          child: ListView(
                              shrinkWrap: true,
                              children: menuItems(context, locker,
                                  snapshot.data as List<OrderData>?)),
                        ),
                    ],
                  );
                }
              })),
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
            builder: (context) => AlertDialog(
                  title: Text("home.not_implemented_title".tr()),
                  content: Text("home.not_implemented_text".tr()),
                ));
        return;
    }
    Provider.of<ServiceNotifier>(context, listen: false).setService(service);
    Navigator.pushNamed(context, routeName);
  }

  List<PhotoTile> menuItems(
      BuildContext context, Locker? lckr, List<OrderData>? activeOrders) {
    List<PhotoTile> items = [];
    for (var element in lckr!.services) {
      items.add(PhotoTile(
        imageUrl: element.imageUrl,
        backgroundColor: element.color,
        title: element.action,
        onTap: () => onTap(context, element),
      ));
    }

    if (lckr.services.isNotEmpty &&
        activeOrders != null &&
        activeOrders.isNotEmpty) {
      items.add(PhotoTile(
        backgroundColor: lckr.services.first.color,
        title: "home.pick_up_stuff".tr(),
        onTap: () {
          if (activeOrders.length > 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChooseOrderScreen(
                        orders: activeOrders,
                      )),
            );
          } else {
            showOrderDetail(context, activeOrders.first);
          }
        },
      ));
    }

    return items;
  }

  void showOrderDetail(BuildContext context, OrderData order) async {
    await showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (ctx) => ChangeNotifierProvider.value(
              value: order,
              child: const DetailOrderNotifierDialog(),
            ));
  }

  List<Widget> iconTiles(BuildContext context) {
    return [
      const SizedBox(height: 20),
      IconTile(
        text: "home.find_locker".tr(),
        icon: Icons.qr_code_scanner_outlined,
        onTap: () {
          Navigator.pushNamed(context, EnterLockerIdScreen.routeName);
        },
      ),
      const SizedBox(height: 20),
      IconTile(
        text: "home.history".tr(),
        icon: Icons.history,
        onTap: () {
          Navigator.pushNamed(context, HistoryScreen.routeName);
        },
      ),
    ];
  }
}
