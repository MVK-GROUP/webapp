import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/lockers.dart';
import '../models/order.dart';
import 'http_exceptions.dart';

class Api {
  static const baseUrl = "http://localhost:8000/api/v1";

  static Future<Locker> fetchLockerById(String lockerId) async {
    var apiUrl = "/lockers/$lockerId";
    var res = await http.get(Uri.parse(baseUrl + apiUrl));
    try {
      if (res.statusCode == 200) {
        var locker = Locker.fromJson(
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
        return locker;
      } else {
        throw HttpException(res.reasonPhrase.toString());
      }
    } catch (e) {
      rethrow;
    }
  }
}

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
