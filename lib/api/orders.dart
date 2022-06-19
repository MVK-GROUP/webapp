import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'settings.dart';
import '../models/order.dart';
import 'http_exceptions.dart';

class OrderApi {
  static const baseUrl = domain + "/api/v1";

  static Future<List<OrderData>> fetchOrders(String? token) async {
    print("fetch orders");
    var apiUrl = "/orders/";
    try {
      var res = await http.get(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (res.statusCode == 200) {
        List<OrderData> orders = [];
        var data = json.decode(utf8.decode(res.bodyBytes)) as List<dynamic>;
        for (var element in data) {
          orders.add(OrderData.fromJson(element));
        }
        print("orders: $orders");
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

  static Future<OrderData> fetchOrderById(int orderId, String? token) async {
    var apiUrl = "/orders/$orderId";
    try {
      var res = await http.get(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (res.statusCode == 200) {
        var data =
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        return OrderData.fromJson(data);
      } else if (res.statusCode == 404) {
        throw HttpException("Такого замовлення не існує",
            statusCode: res.statusCode);
      } else {
        throw HttpException("Вибачте, в нас технічні несправності...",
            statusCode: res.statusCode);
      }
    } on SocketException {
      throw HttpException("Вибачте, в нас технічні несправності...",
          statusCode: 500);
    } catch (e) {
      rethrow;
    }
  }

  static Future<OrderData> addOrder(
      int lockerId, String title, Object? data, String? token) async {
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
          "Authorization": "Token $token",
        },
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        return OrderData.fromJson(response);
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<String?> openCell(int orderId, String? token) async {
    var apiUrl = "/orders/$orderId/open-cell";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token",
        },
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        print(response);
        return response["task_num"];
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<String?> putThings(int orderId, String? token) async {
    var apiUrl = "/orders/$orderId/put-things";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token",
        },
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        print(response);
        return response["task_num"];
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<String?> getThings(int orderId, String? token) async {
    var apiUrl = "/orders/$orderId/get-things";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token",
        },
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        print(response);
        return response["task_num"];
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<int> checkOpenCellTask(
      int orderId, String numTask, String? token) async {
    var apiUrl = "/orders/$orderId/check-task/$numTask";
    try {
      //await Future.delayed(Duration(seconds: 2));
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token",
        },
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        print(response);
        if (response['status'] == 'success' &&
            response.containsKey('task_status')) {
          return response["task_status"];
        }
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<bool> isExistActiveOrders(String? token) async {
    var apiUrl = "/orders/active";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token",
        },
      );
      if (rawResponse.statusCode < 400) {
        final response =
            json.decode(utf8.decode(rawResponse.bodyBytes)) as List<dynamic>;
        return response.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
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
