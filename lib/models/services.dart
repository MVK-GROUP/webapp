import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../style.dart';

class Tariff {
  final double price;
  final int time;
  const Tariff(this.time, this.price);

  String get hours {
    var d = Duration(minutes: time);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}

class ACLCellType {
  final String title;
  final int id;
  final String? symbol;
  final List<Tariff> _tariffs = [];

  ACLCellType(this.id, this.title, {this.symbol});

  List<Tariff> get tariff {
    return _tariffs;
  }

  void addTariff(Tariff tariff) {
    _tariffs.add(tariff);
  }
}

Future<Map<String, Object?>> servicesLoad() async {
  final raw = await rootBundle.loadString('assets/data/tariffs.json');
  final assets = jsonDecode(raw) as Map<String, dynamic>;
  var color = mainColor;
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
      if ((e as Map<String, dynamic>).containsKey("tariffs")) {
        var tariffs = e["tariffs"] as List<dynamic>;
        for (var tariff in tariffs) {
          cellType.addTariff(
              Tariff(tariff["time"], (tariff["price"] as num).toDouble()));
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
