import 'package:flutter/material.dart';
import '../../widgets/goods_tile.dart';
import '../../models/goods.dart';
import '../../style.dart';
import '../../utilities/urils.dart';

class AllGoodsScreen extends StatelessWidget {
  static const routeName = '/all-goods';

  const AllGoodsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final arg = ModalRoute.of(context)?.settings.arguments;
    final check = Utils.checkRouteArg(navigator, arg);
    if (check != null) return check;

    final existArgs = arg as Map<String, Object>;
    final title = existArgs["title"] as String;
    final subTitle = existArgs.containsKey("subtitle")
        ? existArgs["subtitle"] as String
        : null;
    final goods = existArgs["goods"] as List<GoodsItem>;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppColors.backgroundColor,
        iconTheme: const IconThemeData(color: AppColors.mainColor, size: 32),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, top: 10, right: 30),
            child: Column(children: [
              Text(
                title,
                style: AppStyles.titleTextStyle,
              ),
              if (subTitle != null)
                Text(
                  subTitle,
                  style: AppStyles.subtitleTextStyle,
                ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                    itemCount: goods.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisExtent: 160,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      return GoodsItemTileWidget(
                        onTap: () => Navigator.of(context).pop(goods[index]),
                        height: 140,
                        imagePath: goods[index].imagePath,
                        title: goods[index].title,
                        subTitle: Text(
                          goods[index].getPriceWithCurrency(currency: "UAH"),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
