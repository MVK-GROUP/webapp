class GoodsItem {
  final String id;
  final String title;
  final int priceInCoins;
  final String? image;
  final String? description;

  const GoodsItem({
    required this.id,
    required this.title,
    required this.priceInCoins,
    required this.image,
    this.description,
  });

  String get price {
    return (priceInCoins / 100).toStringAsFixed(2);
  }

  String getPriceWithCurrency({String currency = "UAH"}) {
    return "$price $currency";
  }

  String get imagePath {
    return image == null
        ? "assets/images/no-image.png"
        : "assets/images/uploads/" + image!;
  }
}

class Category {
  final String id;
  final String title;
  final String? image;
  final List<GoodsItem> _goods = [];

  Category(this.id, this.title, {this.image});

  factory Category.fillGoods(
      String categoryId, String categoryTitle, List<GoodsItem> items) {
    var category = Category(categoryId, categoryTitle);
    for (var element in items) {
      category.addGoodsItem(element);
    }
    return category;
  }

  void addGoodsItem(GoodsItem item) {
    _goods.add(item);
  }

  List<GoodsItem> get goods {
    return _goods;
  }
}
