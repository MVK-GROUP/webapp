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

class OrderData {
  final int status;
  final int id;
  final String title;
  final ServiceCategory service;
  final int priceInCoins;
  final String currency;
  final Map<String, Object>? data;
  final String? place;
  final DateTime date;

  OrderData({
    this.status = 0,
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
    var service = ServiceCategoryExt.getByString(jsonData["service"]);
    if (service == ServiceCategory.acl ||
        service == ServiceCategory.powerbank) {
      data["end_date"] = DateTime.fromMillisecondsSinceEpoch(
          (json["created_at_timestamp"] + jsonData["time"]) * 1000);
      data["algorithm"] = AlgorithmTypeExt.fromString(jsonData["algorithm"]);
      if (jsonData.containsKey("pin")) {
        data["pin"] = jsonData["pin"];
      }
    }
    if (json.containsKey("locker") && json["locker"] != null) {
      place = '${json["locker"]["name"]}, ${json["locker"]["address"]}';
    }
    return OrderData(
      id: json["id"],
      title: json["title"] ?? "Невідомо",
      service: service,
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

  String get humanTimeLeft {
    if (data != null && data!.containsKey("end_date")) {
      var endDate = data!["end_date"] as DateTime;
      final duration = endDate.difference(DateTime.now());
      if (duration.inSeconds < 0) {
        return "Час вийшов";
      }
      final diffInDays = duration.inDays;
      var diffInHours = duration.inHours;
      var diffInMinutes = duration.inMinutes;
      String humanDate = "";
      if (diffInDays >= 1) {
        humanDate += "$diffInDays д. ";
        diffInHours -= diffInDays * 24;
        diffInMinutes -= diffInHours * 60;
      }
      if (diffInHours >= 1) {
        humanDate += "$diffInHours год. ";
        diffInMinutes -= diffInHours * 60;
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
