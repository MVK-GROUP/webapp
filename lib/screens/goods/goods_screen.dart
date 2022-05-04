import 'package:flutter/material.dart';
import '../../models/lockers.dart';
import '../../models/order.dart';
import '../../screens/pay_screen.dart';
import '../../widgets/main_block.dart';
import '../../style.dart';
import '../../widgets/screen_title.dart';
import '../../models/goods.dart';
import '../../widgets/goods_tile.dart';
import 'all_goods_screen.dart';

class GoodsScreen extends StatelessWidget {
  static const routeName = "/goods";

  const GoodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var categories = [
      Category.fillGoods("snacks", "Снеки", [
        const GoodsItem(
          id: "lays1",
          priceInCoins: 2300,
          title: "Чіпси Лейс",
          image: "chips1.png",
        ),
        const GoodsItem(
          id: "seeds1",
          priceInCoins: 3389,
          title: "Насіння, 80 гр.",
          image: "seeds.png",
        ),
      ]),
      Category.fillGoods("boxfood", "Їжа у боксах", [
        const GoodsItem(
          id: "lays1",
          priceInCoins: 2300,
          title: "Bakery Box #1",
          image: "bakery_box.png",
        ),
        const GoodsItem(
          id: "seeds1",
          priceInCoins: 15000,
          title: "Хачапурі, 250 гр.",
          image: "hachapuri.jpg",
        ),
        const GoodsItem(
          id: "pasta",
          priceInCoins: 11212,
          title: "Паста Сет 1",
          image: "pasta1.png",
        ),
      ]),
    ];
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.mainColor, size: 32),
      ),
      body: Column(children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: ScreenTitle(
            'Товари в наявності',
            subTitle: 'Оберіть товар для покупки',
            height: 120,
          ),
        ),
        MainBlock(
            hContentPadding: 0,
            child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Text(
                                categories[index].title,
                                style: AppStyles.titleSecondaryTextStyle,
                              )),
                              const SizedBox(width: 10),
                              if (categories[index].goods.length > 2)
                                TextButton(
                                    onPressed: () => seeAll(
                                        context,
                                        categories[index].title,
                                        categories[index].goods),
                                    child: const Text("Показати всі",
                                        style: AppStyles.bodyText2)),
                            ],
                          ),
                        ),
                        Container(
                          width: double.maxFinite,
                          height: 200,
                          padding: const EdgeInsets.only(top: 4, left: 20),
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories[index].goods.length,
                              itemBuilder: (ctx, productIndex) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: 20, top: 10, bottom: 10),
                                  child: GoodsItemTileWidget(
                                    onTap: () => chooseGoodsItem(context,
                                        categories[index].goods[productIndex]),
                                    textAlign: TextAlign.left,
                                    imagePath: categories[index]
                                        .goods[productIndex]
                                        .imagePath,
                                    title: categories[index]
                                        .goods[productIndex]
                                        .title,
                                    subTitle: Text(
                                      categories[index]
                                          .goods[productIndex]
                                          .getPriceWithCurrency(
                                              currency: "UAH"),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  );
                })),
      ]),
    );
  }

  void seeAll(BuildContext context, String title, List<GoodsItem> goods) async {
    var goodsItem = await Navigator.pushNamed(context, AllGoodsScreen.routeName,
        arguments: {
          "title": "Оберіть товар",
          "subtitle": title,
          "goods": goods,
        });
    if (goodsItem != null) {
      chooseGoodsItem(context, goodsItem as GoodsItem);
    }
  }

  void chooseGoodsItem(BuildContext context, GoodsItem goodsItem) {
    final newOrder = TemporaryOrderData(
        amountInCoins: goodsItem.priceInCoins,
        type: ServiceCategory.vendingMachine,
        helperText: "Після сплати апарат видасть вам це замовлення",
        item: goodsItem);
    Navigator.of(context)
        .pushNamed(PayScreen.routeName, arguments: {"order": newOrder});
  }
}
