import 'dart:convert';

import 'package:flutter/services.dart';

enum ServiceCategory {
  laundry,
  vendingMachine,
  phoneCharging,
  unknown,
}

class Service {
  final int serviceId;
  final ServiceCategory category;
  final String title;
  final String imageUrl;

  const Service({
    required this.serviceId,
    required this.title,
    required this.imageUrl,
    this.category = ServiceCategory.unknown,
  });
}

class Locker {
  final int lockerId;
  final String name;
  final String? address;
  final double? latitude;
  final double? longtitude;
  final List<Service> services = [];

  Locker(this.lockerId, this.name,
      {this.address, this.latitude, this.longtitude});

  void addService(Service service) {
    services.add(service);
  }
}

class Assets {
  Assets();

  List<Locker>? _lockers;

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/lockers.json');
    final assets = jsonDecode(raw) as List<dynamic>;
    _lockers = assets.map((element) {
      var locker = Locker(element['locker_id'], element['name']);
      for (var service in (element['services'] as List<dynamic>)) {
        locker.addService(Service(
          serviceId: service['service_id'],
          title: service['title'],
          imageUrl: service['picture_url'],
        ));
      }
      return locker;
    }).toList();
  }

  List<Locker>? getLockers() {
    return _lockers;
  }

  Locker getLockerById(int id) {
    return _lockers?.firstWhere((element) => element.lockerId == id) ??
        Locker(0, "");
  }
}