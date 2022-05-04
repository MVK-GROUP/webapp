import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/lockers.dart';
import '../models/order.dart';
import 'http_exceptions.dart';

class Api {
  static const baseUrl = "http://localhost:8000/api/v1";

  static Future<Locker> fetchLockerById(String lockerId) async {
    var apiUrl = "/lockers/$lockerId";
    try {
      var res = await http.get(Uri.parse(baseUrl + apiUrl));

      if (res.statusCode == 200) {
        var locker = Locker.fromJson(
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
        return locker;
      } else {
        throw HttpException(res.reasonPhrase.toString(),
            statusCode: res.statusCode);
      }
    } on SocketException {
      throw HttpException("SocketException", statusCode: 500);
    } catch (e) {
      rethrow;
    }
  }
}

class OrderApi {
  static const baseUrl = "http://localhost:8000/api/v1";

  static Future<List<OrderData>> fetchOrders() async {
    var apiUrl = "/orders/";
    try {
      var res = await http.get(Uri.parse(baseUrl + apiUrl));

      if (res.statusCode == 200) {
        List<OrderData> orders = [];
        var data = json.decode(utf8.decode(res.bodyBytes)) as List<dynamic>;
        for (var element in data) {
          orders.add(OrderData.fromJson(element));
        }
        return orders;
      } else {
        throw HttpException(res.reasonPhrase.toString(),
            statusCode: res.statusCode);
      }
    } on SocketException {
      throw HttpException("SocketException", statusCode: 500);
    } catch (e) {
      rethrow;
    }
  }

  static Future<OrderData> addOrder(
      int lockerId, String title, Object? data) async {
    var apiUrl = "/orders/new";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        body: json.encode({
          'locker_id': lockerId,
          'title': title,
          'data': data,
        }),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;

        print(response);
        return OrderData.fromJson(response);
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<List<OrderData>> fetchDumpOrders() async {
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
          data: null,
          date: DateTime.now(),
          place: e["location"]));
    }
    return orders;
  }
}
