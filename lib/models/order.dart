import 'services.dart';

class OrderItem {
  final String id;
  final double amount;
  final ACLCellType chosenCell;
  final String chosenTariff;

  OrderItem(this.id, this.amount, this.chosenCell, this.chosenTariff);
}

class OrderData {
  final int status;
  final String id;
  final String title;
  final String service;
  final int priceInCoins;
  final String currency;
  final String tariff;
  final String? place;
  late final String date;

  OrderData(
      {this.status = 0,
      required this.id,
      required this.title,
      required this.service,
      required this.priceInCoins,
      required this.currency,
      required this.tariff,
      this.place}) {
    date = DateTime.now().toString();
  }

  String get price {
    return (priceInCoins / 100).toStringAsFixed(2);
  }

  String get humanPrice {
    return "$price $currency";
  }
}
