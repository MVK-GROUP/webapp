import 'package:flutter/foundation.dart';
import 'lockers.dart';

class OrderItem {
  final String id;
  final String? helperText;
  final ServiceCategory type;
  final Object item;
  final int amountInCoins;
  final String currency;
  final String? place;
  late final String date;

  OrderItem({
    required this.id,
    required this.amountInCoins,
    required this.type,
    required this.item,
    this.place,
    this.helperText,
    this.currency = "UAH",
  }) {
    date = DateTime.now().toString();
  }

  String get payable {
    return (amountInCoins / 100).toString();
  }

  String get payableWithCurrency {
    return "$payable $currency";
  }
}

class OrderItemNotifier with ChangeNotifier {
  OrderItem? _orderItem;

  void setOrderItem(OrderItem orderItem) {
    notifyListeners();
    _orderItem = orderItem;
  }

  OrderItem? get orderItem {
    return _orderItem;
  }
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
