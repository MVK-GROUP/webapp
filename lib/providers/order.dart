import 'package:flutter/foundation.dart';
import 'package:mvk_app/models/lockers.dart';
import 'package:mvk_app/models/services.dart';
import '../models/order.dart';
import '../api/orders.dart';

class OrdersNotifier with ChangeNotifier {
  List<OrderData>? _orders;

  List<OrderData>? get orders {
    if (_orders == null) {
      return null;
    }
    return [...?_orders];
  }

  Future<List<OrderData>?> fetchAndSetOrders() async {
    _orders = await OrderApi.fetchOrders();
    notifyListeners();
    return _orders;
  }

  Future<OrderData> addOrder(int lockerId, String title,
      {Map<String, Object>? data}) async {
    var order = await OrderApi.addOrder(lockerId, title, data);
    _orders?.insert(0, order);
    notifyListeners();
    return order;
  }
}
