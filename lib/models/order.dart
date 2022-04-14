import 'dart:convert';

import 'package:flutter/services.dart';

import 'services.dart';

class OrderItem {
  final String id;
  final double amount;
  final ACLCellType chosenCell;
  final String chosenTariff;

  OrderItem(this.id, this.amount, this.chosenCell, this.chosenTariff);
}

class OrderData {
  final int status;
  final String id;
  final String title;
  final String service;
  final String amount;
  final String currency;
  final String tariff;
  final String? place;
  late final String date;

  OrderData(
      {this.status = 0,
      required this.id,
      required this.title,
      required this.service,
      required this.amount,
      required this.currency,
      required this.tariff,
      this.place}) {
    date = DateTime.now().toString();
  }
}
