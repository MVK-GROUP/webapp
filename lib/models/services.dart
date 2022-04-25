import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../style.dart';

class Tariff {
  final int priceInCoins;
  final int _time;
  const Tariff(this._time, this.priceInCoins);

  String get hours {
    var d = Duration(minutes: _time);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String get humanHours {
    var d = Duration(minutes: _time);
    var ending = "годин";
    if (d.inHours < 2) {
      ending = "години";
    }
    return "<${d.inHours} $ending";
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

  ACLCellType(this.id, this.title, {this.symbol});

  factory ACLCellType.fromJson(Map<String, dynamic> json) {
    var cellType =
        ACLCellType(json["id"], json["title"], symbol: json["symbol"]);
    if (json.containsKey("tariff")) {
      // ADD TARIFF
    }
    return cellType;
  }

  List<Tariff> get tariff {
    return _tariffs;
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
