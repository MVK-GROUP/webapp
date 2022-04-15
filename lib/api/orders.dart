import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/order.dart';

class OrderApi {
  static Future<List<OrderData>> fetchOrders() async {
    final raw = await rootBundle.loadString('assets/data/orders.json');

    final assets = jsonDecode(raw) as List<dynamic>;
    List<OrderData> orders = [];
    for (var e in assets) {
      orders.add(OrderData(
          status: e["status"],
          id: e["order_id"],
          title: e['title'],
          service: e['type'],
          priceInCoins: e["amount"],
          currency: e["currency"],
          tariff: "unknown",
          place: e["location"]));
    }
    return orders;
  }
}
