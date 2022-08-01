import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../style.dart';

class Tariff {
  final int priceInCoins;
  final int _time;
  const Tariff(this._time, this.priceInCoins);

  factory Tariff.fromJson(Map<String, dynamic> json) {
    return Tariff(json['time'], json['price']);
  }

  String get hours {
    var d = Duration(minutes: _time);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  int get minutes {
    return _time ~/ 60;
  }

  int get seconds {
    return _time;
  }

  String get humanHours {
    return "<" + humanEqualHours;
  }

  String get humanEqualHours {
    var d = Duration(seconds: _time);
    if (d.inHours < 1) {
      return "datetime.minute".plural(d.inMinutes);
    }
    var time = "datetime.hour".plural(d.inHours);
    if (d.inMinutes > 60) {
      time += " " + "datetime.minute".plural(d.inMinutes - d.inHours * 60);
    }
    return time;
  }

  String get price {
    return (priceInCoins / 100).toStringAsFixed(2);
  }

  String priceWithCurrency(String currency) {
    return '$price $currency';
  }
}

class ACLCellType {
  final String title;
  final int id;
  final String? symbol;
  final List<Tariff> _tariffs = [];
  String _currency = "UAH";
  Tariff? _overduePayment;

  ACLCellType(
    this.id,
    this.title, {
    this.symbol,
  });

  factory ACLCellType.fromJson(Map<String, dynamic> json,
      {required String lang}) {
    String title = json["title"] ?? "unknown".tr();
    if (json.containsKey("title_$lang")) {
      title = json["title_$lang"];
    }
    var cellType = ACLCellType(json["id"], title, symbol: json["symbol"]);
    if (json.containsKey("tariffs") && json["tariffs"] != null) {
      for (var element in (json["tariffs"] as List<dynamic>)) {
        cellType.addTariff(Tariff(element["time"], element["price"]));
      }
    }
    if (json.containsKey("overdue_payment") &&
        json["overdue_payment"] != null) {
      cellType.setOverduePayment(Tariff(
          json["overdue_payment"]["time"], json["overdue_payment"]["price"]));
    }
    return cellType;
  }

  List<Tariff> get tariff {
    return _tariffs;
  }

  Tariff? get overduePayment {
    return _overduePayment;
  }

  String get onelineTitle {
    return title.replaceAll("\n", ", ");
  }

  String get currency {
    return _currency;
  }

  void setCurrency(String currency) {
    _currency = currency;
  }

  void addTariff(Tariff tariff) {
    _tariffs.add(tariff);
  }

  void setOverduePayment(Tariff tariff) {
    _overduePayment = tariff;
  }
}

Future<Map<String, Object?>> servicesLoad() async {
  final raw = await rootBundle.loadString('assets/data/tariffs.json');
  final assets = jsonDecode(raw) as Map<String, dynamic>;
  var color = AppColors.mainColor;
  if (assets.containsKey("color")) {
    var colorValue = int.tryParse('0xFF' + assets['color']);
    if (colorValue != null) {
      color = Color(colorValue);
    }
  }

  List<ACLCellType> sizes = [];
  if (assets.containsKey("cell_types")) {
    sizes = (assets["cell_types"] as List<dynamic>).map((e) {
      var cellType = ACLCellType(e["id"], e["title"], symbol: e["symbol"]);
      if (assets.containsKey("currency")) {
        cellType.setCurrency(assets["currency"]);
      }
      if ((e as Map<String, dynamic>).containsKey("tariffs")) {
        var tariffs = e["tariffs"] as List<dynamic>;
        for (var tariff in tariffs) {
          cellType.addTariff(Tariff(tariff["time"], tariff["price"] as int));
        }
      }
      return cellType;
    }).toList();
  }

  return {
    "color": color,
    "sizes": sizes,
  };
}
