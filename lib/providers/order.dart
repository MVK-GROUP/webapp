import 'package:flutter/foundation.dart';
import 'package:mvk_app/models/lockers.dart';
import '../models/order.dart';
import '../api/orders.dart';

class OrdersNotifier with ChangeNotifier {
  List<OrderData>? _orders;
  var _lastUpdate = 0;

  final String? authToken;

  OrdersNotifier(this.authToken, this._orders);

  List<OrderData>? get orders {
    if (_orders == null) {
      return null;
    }
    return [...?_orders];
  }

  void setLastUpdateTime(time) {
    _lastUpdate = time;
  }

  int get lastUpdateTime {
    return _lastUpdate;
  }

  bool? isExistOrdersWithStatus(List<OrderStatus> statuses) {
    return _orders?.any((element) => statuses.contains(element.status));
  }

  List<OrderData> getActiveAclsOrders() {
    List<OrderData> orders = [];
    var foundOrders = _orders?.where((order) =>
        [OrderStatus.hold, OrderStatus.active].contains(order.status) &&
        [
          ServiceCategory.acl,
          ServiceCategory.phoneCharging,
          ServiceCategory.powerbank
        ].contains(order.service));
    if (foundOrders != null) {
      orders.addAll(foundOrders);
    }
    return orders;
  }

  Future<List<OrderData>?> fetchAndSetOrders() async {
    try {
      _orders = await OrderApi.fetchOrders(authToken);
      notifyListeners();
      return _orders;
    } catch (e) {
      _orders = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<OrderData> addOrder(int lockerId, String title,
      {Map<String, Object>? data}) async {
    try {
      var order = await OrderApi.createOrder(lockerId, title, data, authToken);
      _orders?.insert(0, order);
      notifyListeners();
      return order;
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderData> checkOrder(int orderId) async {
    try {
      var order = await OrderApi.fetchOrderById(orderId, authToken);
      int? index = _orders?.indexWhere((element) => element.id == orderId);
      if (index != null && index != -1) {
        _orders?[index] = order;
        notifyListeners();
        return order;
      } else {
        throw Exception("error");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderData> checkOrderWithoutNotify(int orderId) async {
    try {
      var order = await OrderApi.fetchOrderById(orderId, authToken);
      return order;
    } catch (e) {
      rethrow;
    }
  }

  void resetOrders() {
    _orders = null;
    notifyListeners();
  }
}
