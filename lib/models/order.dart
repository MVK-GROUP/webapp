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
  created,
  inProgress,
  hold,
  completed,
  canceled,
  error,
  expired,
}

extension OrderStatusExt on OrderStatus {
  static OrderStatus fromString(String? value) {
    if (value == "created") {
      return OrderStatus.created;
    } else if (value == "in progress") {
      return OrderStatus.inProgress;
    } else if (value == "hold") {
      return OrderStatus.hold;
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

class OrderData {
  final OrderStatus status;
  final int id;
  final String title;
  final ServiceCategory service;
  final int priceInCoins;
  final String currency;
  final Map<String, Object>? data;
  final String? place;
  final DateTime date;

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
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    String? place;
    var date = DateTime.fromMillisecondsSinceEpoch(
        json["created_at_timestamp"] * 1000);

    Map<String, Object> data = {};
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
    }
    if (json.containsKey("locker") && json["locker"] != null) {
      place = '${json["locker"]["name"]}, ${json["locker"]["address"]}';
    }
    return OrderData(
      id: json["id"],
      title: json["title"] ?? "Невідомо",
      service: service,
      status: OrderStatusExt.fromString(json["status"]),
      priceInCoins: 0,
      data: data.isEmpty ? null : data,
      place: place,
      date: date,
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
}
