import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../api/orders.dart';
import 'package:mvk_app/style.dart';

enum ServiceCategory {
  laundry,
  vendingMachine,
  powerbank,
  phoneCharging,
  acl,
  unknown,
}

extension ServiceCategoryExt on ServiceCategory {
  static ServiceCategory getByString(String value) {
    if (value == "acl") {
      return ServiceCategory.acl;
    } else if (value == "powerbank") {
      return ServiceCategory.powerbank;
    }
    return ServiceCategory.unknown;
  }
}

class Service {
  final int serviceId;
  final ServiceCategory category;
  final String title;
  final String imageUrl;
  final Color color;

  const Service({
    required this.serviceId,
    required this.title,
    required this.imageUrl,
    this.color = AppColors.mainColor,
    this.category = ServiceCategory.unknown,
  });
}

enum LockerType {
  free,
  paid,
  hub,
}

extension LockerTypeExt on LockerType {
  static LockerType getByString(String value) {
    if (value == "paid") {
      return LockerType.paid;
    } else if (value == "hub") {
      return LockerType.hub;
    }
    return LockerType.free;
  }
}

enum LockerStatus {
  ok,
  cannotConnect,
  unknown,
}

extension LockerStatusExt on LockerStatus {
  static LockerStatus getByString(String value) {
    if (value == "ok") {
      return LockerStatus.ok;
    } else if (value == "cannot_connect") {
      return LockerStatus.cannotConnect;
    }
    return LockerStatus.unknown;
  }
}

class Locker {
  final int lockerId;
  final String name;
  final String? address;
  final double? latitude;
  final double? longtitude;
  final String? description;
  final LockerStatus status;
  final LockerType type;
  final List<Service> services = [];

  Locker({
    required this.lockerId,
    required this.name,
    required this.type,
    this.status = LockerStatus.unknown,
    this.address,
    this.latitude,
    this.longtitude,
    this.description,
  });

  void addService(Service service) {
    services.add(service);
  }

  String get fullLockerName {
    if (name.isNotEmpty && address != null) {
      return "$name, $address";
    }
    return address ?? name;
  }

  factory Locker.fromJson(Map<String, dynamic> json) {
    var locker = Locker(
      lockerId: json["lockerID"],
      name: json["name"],
      description: json["description"],
      address: json["address"],
      latitude: json["latitude"],
      longtitude: json["longitude"],
      type: LockerTypeExt.getByString(
        json["type"],
      ),
      status: LockerStatusExt.getByString(
        json["status"],
      ),
    );

    if (json.containsKey("services")) {
      var services = json["services"] as List<dynamic>;
      for (Map<String, dynamic> service in services) {
        var serviceCategory =
            ServiceCategoryExt.getByString(service["service"]);

        var color = AppColors.mainColor;
        if (service.containsKey("color")) {
          var colorValue = int.tryParse('0xFF' + service['color']);
          if (colorValue != null) {
            color = Color(colorValue);
          }
        }

        locker.addService(Service(
          serviceId: 1,
          title: "service['title']",
          imageUrl: "service['picture_url']",
          category: serviceCategory,
          color: color,
        ));
      }
    }

    return locker;

    // "services": [
    //     {\
    //         "algorithm": "tariff_selection",
    //         "cell_types": {
    //             "service": "acl",
    //             "color": "2D308F",
    //             "algorithm": "tariff_selection",
    //             "currency": "UAH",
    //             "cell_types": [
    //                 {
    //                     "id": 1,
    //                     "title": "МАЛЕНЬКА\n415x435x798",
    //                     "symbol": "S",
    //                     "icon": null
    //                 },
    //                 {
    //                     "id": 2,
    //                     "title": "СЕРЕДНЯ\n475x435x798",
    //                     "symbol": "M",
    //                     "icon": null
    //                 },
    //                 {
    //                     "id": 3,
    //                     "title": "ВЕЛИКА\n515x435x798",
    //                     "symbol": "L",
    //                     "icon": null
    //                 }
    //             ]
    //         }
    //     }
    // ]
  }
}

class LockerNotifier with ChangeNotifier {
  Locker? _currenctLocker;

  Locker? get locker {
    return _currenctLocker;
  }

  Future<Locker?> setLocker(String? id) async {
    if (id == null) {
      notifyListeners();
      return null;
    } else {
      try {
        _currenctLocker = await Api.fetchLockerById(id);
        notifyListeners();
        return _currenctLocker;
      } catch (e) {
        _currenctLocker = null;
        rethrow;
      }
    }
  }
}

class Assets {
  Assets();

  List<Locker>? _lockers;

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/lockers.json');
    final assets = jsonDecode(raw) as List<dynamic>;
    _lockers = assets.map((element) {
      var locker = Locker(
          lockerId: element['locker_id'],
          name: element['name'],
          type: LockerType.free);
      for (var service in (element['services'] as List<dynamic>)) {
        var serviceCategory = ServiceCategory.unknown;
        if ((service as Map<String, dynamic>).containsKey('category')) {
          if (service['category'] == "vending_machine") {
            serviceCategory = ServiceCategory.vendingMachine;
          } else if (service['category'] == "laundry") {
            serviceCategory = ServiceCategory.laundry;
          } else if (service['category'] == "charge_phone" ||
              service['category'] == "acl") {
            serviceCategory = ServiceCategory.acl;
          }
        }
        locker.addService(Service(
          serviceId: service['service_id'],
          title: service['title'],
          imageUrl: service['picture_url'],
          category: serviceCategory,
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
        Locker(lockerId: 0, name: "", type: LockerType.free);
  }
}
