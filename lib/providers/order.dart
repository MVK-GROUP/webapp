import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../api/orders.dart';

class Orders with ChangeNotifier {
  List<OrderData> _orders = [];

  List<OrderData> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    _orders = await OrderApi.fetchOrders();
    notifyListeners();
  }

  Future<void> addOrder(OrderData order) async {
    _orders.add(order);
  }
}
