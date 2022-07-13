import 'package:flutter/cupertino.dart';

import '../api/orders.dart';
import 'lockers.dart';

class TemporaryOrderData {
  final String? helperText;
  final ServiceCategory type;
  final Object item;
  final int amountInCoins;
  final String currency;
  final String? place;
  final Map<String, Object>? extraData;

  TemporaryOrderData({
    required this.amountInCoins,
    required this.type,
    required this.item,
    this.extraData,
    this.place,
    this.helperText,
    this.currency = "UAH",
  });

  String get title {
    switch (type) {
      case ServiceCategory.acl:
        return "Оренда комірки";
      case ServiceCategory.laundry:
        return "Хімчистка";
      case ServiceCategory.vendingMachine:
        return "Торговий автомат";
      default:
        return "----------";
    }
  }

  String get payable {
    return (amountInCoins / 100).toString();
  }

  String get payableWithCurrency {
    return "$payable $currency";
  }
}

enum OrderStatus {
  beforeCreating,
  created,
  inProgress,
  hold,
  active,
  completed,
  canceled,
  error,
  expired,
}

extension OrderStatusExt on OrderStatus {
  static OrderStatus fromString(String? value) {
    if (value == "before_creating") {
      return OrderStatus.beforeCreating;
    } else if (value == "created") {
      return OrderStatus.created;
    } else if (value == "in progress") {
      return OrderStatus.inProgress;
    } else if (value == "hold") {
      return OrderStatus.hold;
    } else if (value == "active") {
      return OrderStatus.active;
    } else if (value == "completed") {
      return OrderStatus.completed;
    } else if (value == "canceled") {
      return OrderStatus.canceled;
    } else if (value == "error") {
      return OrderStatus.error;
    } else if (value == "expired") {
      return OrderStatus.expired;
    }
    return OrderStatus.error;
  }
}

class OrderData with ChangeNotifier {
  OrderStatus status;
  final int id;
  final String title;
  final ServiceCategory service;
  final int priceInCoins;
  final String currency;
  final Map<String, Object>? data;
  final String? place;
  final DateTime date;
  final String? payData;
  final String? paySignature;
  int firstActionTimestamp;
  int lastActionTimestamp;

  OrderData({
    this.status = OrderStatus.created,
    required this.id,
    required this.title,
    required this.service,
    required this.priceInCoins,
    required this.date,
    this.currency = "UAH",
    this.data,
    this.place,
    this.firstActionTimestamp = 0,
    this.lastActionTimestamp = 0,
    this.payData,
    this.paySignature,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    String? place;
    var date = DateTime.fromMillisecondsSinceEpoch(
        json["created_at_timestamp"] * 1000);
    Map<String, Object> data = {};
    int paid = 0;
    String? payData;
    String? paySignature;

    var jsonData = json["data"] as Map<String, dynamic>;
    var service = ServiceCategoryExt.fromString(jsonData["service"]);
    if (service == ServiceCategory.acl ||
        service == ServiceCategory.powerbank) {
      data["end_date"] = DateTime.fromMillisecondsSinceEpoch(
          (json["created_at_timestamp"] + jsonData["time"]) * 1000);
      data["algorithm"] = AlgorithmTypeExt.fromString(jsonData["algorithm"]);
      if (jsonData.containsKey("pin")) {
        data["pin"] = jsonData["pin"];
      }
      if (jsonData.containsKey("cell_id")) {
        data["cell_id"] = jsonData["cell_id"];
      }
      if (jsonData.containsKey("paid")) {
        paid = jsonData["paid"];
      }
      if (json.containsKey("pay_data")) {
        payData = json["pay_data"];
        paySignature = json["pay_signature"];
      }
      if (jsonData.containsKey("overdue_payment") &&
          jsonData["overdue_payment"] != null) {
        data["overdue_payment"] = jsonData["overdue_payment"];
      }
    }
    if (json.containsKey("locker") && json["locker"] != null) {
      place = '${json["locker"]["name"]}, ${json["locker"]["address"]}';
    }
    int firstActionTimestamp = 0;
    int lastActionTimestamp = 0;
    if (json.containsKey("first_action_timestamp") &&
        json["first_action_timestamp"] != null) {
      firstActionTimestamp = json["first_action_timestamp"];
    }
    if (json.containsKey("last_action_timestamp") &&
        json["last_action_timestamp"] != null) {
      lastActionTimestamp = json["last_action_timestamp"];
    }
    return OrderData(
      id: json["id"],
      title: json["title"] ?? "Невідомо",
      service: service,
      status: OrderStatusExt.fromString(json["status"]),
      priceInCoins: paid,
      data: data.isEmpty ? null : data,
      place: place,
      date: date,
      firstActionTimestamp: firstActionTimestamp,
      lastActionTimestamp: lastActionTimestamp,
      payData: payData,
      paySignature: paySignature,
    );
  }

  String get humanDate {
    return datetimeToHumanDate(date);
  }

  String datetimeToHumanDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  bool get isExpired {
    return status == OrderStatus.expired || timeLeftInSeconds < 1;
  }

  String get humanTimeLeft {
    if (data != null && data!.containsKey("end_date")) {
      var endDate = data!["end_date"] as DateTime;
      final duration = endDate.difference(DateTime.now());
      if (duration.inSeconds < 0) {
        return "Час вийшов";
      }
      final diffInDays = duration.inDays;
      var diffInHours = duration.inHours - duration.inDays * 24;
      var diffInMinutes = duration.inMinutes - duration.inHours * 60;

      String humanDate = "";
      if (diffInDays >= 1) {
        humanDate += "$diffInDays д. ";
      }
      if (diffInHours >= 1) {
        humanDate += "$diffInHours год. ";
      }
      if (diffInMinutes >= 1) {
        humanDate += "$diffInMinutes хв.";
      }
      return humanDate;
    } else {
      return "Невідомо";
    }
  }

  String get humanTimePassed {
    if (data != null && data!.containsKey("end_date")) {
      var endDate = data!["end_date"] as DateTime;
      final duration = DateTime.now().difference(endDate);
      if (duration.inSeconds < 0) {
        return "невідомо";
      }
      final diffInDays = duration.inDays;
      var diffInHours = duration.inHours - duration.inDays * 24;
      var diffInMinutes = duration.inMinutes - duration.inHours * 60;

      String humanDate = "";
      if (diffInDays >= 1) {
        humanDate += "$diffInDays д. ";
      }
      if (diffInHours >= 1) {
        humanDate += "$diffInHours год. ";
      }
      if (diffInMinutes >= 0) {
        humanDate += "$diffInMinutes хв.";
      }
      return humanDate;
    } else {
      return "Невідомо";
    }
  }

  String get needToPayExtra {
    final endDate = data!["end_date"] as DateTime;
    final diff = DateTime.now().difference(endDate).inSeconds;
    try {
      final overdueTariff = data!['overdue_payment'] as Map<String, dynamic>;
      var res = (diff / overdueTariff['time']).ceil() * overdueTariff['price'];
      return "${(res / 100).toStringAsFixed(2)} $currency";
    } catch (e) {
      return "--- $currency";
    }
  }

  int get timeLeftInSeconds {
    if (data != null && data!.containsKey("end_date")) {
      var endDate = data!["end_date"] as DateTime;
      return endDate.difference(DateTime.now()).inSeconds;
    } else {
      return 0;
    }
  }

  String get price {
    return (priceInCoins / 100).toStringAsFixed(2);
  }

  String get humanPrice {
    return "$price $currency";
  }

  Future<bool> checkOrder(String? token) async {
    try {
      var fetchedOrder = await OrderApi.fetchOrderById(id, token);
      if (!isEqual(fetchedOrder)) {
        updateOrder(fetchedOrder);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  void updateOrder(OrderData changedOrder) {
    status = changedOrder.status;
    firstActionTimestamp = changedOrder.firstActionTimestamp;
    lastActionTimestamp = changedOrder.lastActionTimestamp;
    notifyListeners();
  }

  bool isEqual(OrderData other) {
    return other.id == id &&
        other.firstActionTimestamp == firstActionTimestamp &&
        other.lastActionTimestamp == lastActionTimestamp &&
        other.status == status;
  }
}
