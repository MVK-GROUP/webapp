import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mvk_app/models/services.dart';
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
  static ServiceCategory fromString(String? value) {
    if (value == "acl") {
      return ServiceCategory.acl;
    } else if (value == "powerbank") {
      return ServiceCategory.powerbank;
    }
    return ServiceCategory.unknown;
  }

  static String typeToString(ServiceCategory value) {
    if (value == ServiceCategory.acl) {
      return "acl";
    } else if (value == ServiceCategory.powerbank) {
      return "powerbank";
    } else if (value == ServiceCategory.phoneCharging) {
      return "phone_charge";
    }
    return "unknown";
  }
}

enum TariffSelectionType {
  tariffSelection,
  setTime,
  quick,
  unknown,
}

extension TariffSelectionTypeExt on TariffSelectionType {
  static TariffSelectionType fromString(String? value) {
    if (value == "tariff_selection") {
      return TariffSelectionType.tariffSelection;
    } else if (value == "set_time") {
      return TariffSelectionType.setTime;
    } else if (value == "quick") {
      return TariffSelectionType.quick;
    }
    return TariffSelectionType.unknown;
  }
}

enum AlgorithmType {
  qrReading,
  enterPinOnComplex,
  selfService,
  unknown,
}

extension AlgorithmTypeExt on AlgorithmType {
  static AlgorithmType fromString(String? value) {
    if (value == "qr_reading") {
      return AlgorithmType.qrReading;
    } else if (value == "enter_pin") {
      return AlgorithmType.enterPinOnComplex;
    } else if (value == "self_service") {
      return AlgorithmType.selfService;
    }
    return AlgorithmType.unknown;
  }

  static String toStr(AlgorithmType algorithm) {
    if (algorithm == AlgorithmType.qrReading) {
      return "qr_reading";
    } else if (algorithm == AlgorithmType.enterPinOnComplex) {
      return "enter_pin";
    } else if (algorithm == AlgorithmType.selfService) {
      return "self_service";
    }
    return "unknown";
  }
}

class Service {
  final String serviceId;
  final ServiceCategory category;
  final String title;
  final String? imageUrl;
  final Color color;
  final String action;
  final Map<String, Object> data;

  Service(
      {required this.serviceId,
      required this.title,
      this.imageUrl,
      this.color = AppColors.mainColor,
      this.action = "Unknown",
      this.category = ServiceCategory.unknown,
      this.data = const {}});

  factory Service.fromJson(Map<String, dynamic> json) {
    var serviceCategory = ServiceCategoryExt.fromString(json["service"]);
    Map<String, Object> data = {};

    String title;
    String action;
    switch (serviceCategory) {
      case ServiceCategory.acl:
        title = "Камера схову";
        action = "Покласти речі";

        data["algorithm"] = AlgorithmTypeExt.fromString(json["algorithm"]);
        data["tariff_selection_type"] =
            TariffSelectionTypeExt.fromString(json["tariff_selection_type"]);
        List<ACLCellType> cellTypes = [];

        if (json.containsKey("cell_types")) {
          for (var element in (json["cell_types"] as List<dynamic>)) {
            cellTypes.add(ACLCellType.fromJson(element));
          }
        }
        data["cell_types"] = cellTypes;
        break;
      case ServiceCategory.laundry:
        title = "Хімчистка";
        action = "Хімчистка";
        break;
      case ServiceCategory.phoneCharging:
        title = "Зарядка гаджету";
        action = "Зарядити гаджет";
        break;
      case ServiceCategory.powerbank:
        title = "Повербанк";
        action = "Скористатись повербанком";
        break;
      case ServiceCategory.vendingMachine:
        title = "Торговий автомати";
        action = title;
        break;

      default:
        title = "Невідомо";
        action = title;
    }
    var color = AppColors.mainColor;
    if (json.containsKey("color")) {
      var colorValue = int.tryParse('0xFF' + json['color']);
      if (colorValue != null) {
        color = Color(colorValue);
      }
    }

    return Service(
      serviceId: json["service_id"],
      category: serviceCategory,
      title: title,
      action: action,
      color: color,
      data: data,
    );
  }
}

class ServiceNotifier with ChangeNotifier {
  Service? _currentService;
  ServiceNotifier();

  void setService(Service service) {
    _currentService = service;
    notifyListeners();
  }

  Service? get service {
    return _currentService;
  }

  bool get isContainService {
    return _currentService != null;
  }
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

  static String typeToString(LockerType value) {
    if (value == LockerType.paid) {
      return "paid";
    } else if (value == LockerType.hub) {
      return "hub";
    }
    return "free";
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
  final String? imageUrl;
  final List<Service> services = [];

  Locker({
    required this.lockerId,
    required this.name,
    required this.type,
    this.status = LockerStatus.unknown,
    this.imageUrl,
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
      imageUrl: json["image"],
    );

    if (json.containsKey("services")) {
      var services = json["services"] as List<dynamic>;
      for (Map<String, dynamic> service in services) {
        locker.addService(Service.fromJson(service));
      }
    }

    return locker;
  }
}

class LockerNotifier with ChangeNotifier {
  Locker? _currenctLocker;

  Locker? get locker {
    return _currenctLocker;
  }

  Future<Locker?> setLocker(String? id) async {
    if (id == null) {
      _currenctLocker = null;
      notifyListeners();
      return null;
    } else {
      try {
        _currenctLocker = await LockerApi.fetchLockerById(id);
        notifyListeners();
        return _currenctLocker;
      } catch (e) {
        _currenctLocker = null;
        rethrow;
      }
    }
  }

  void setExistingLocker(Locker? locker) {
    _currenctLocker = locker;
    notifyListeners();
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

class CellStatus {
  final String cellId;
  final String status;
  final String typeId;
  final String service;

  const CellStatus(this.cellId, this.status, this.typeId, this.service);

  factory CellStatus.fromJson(Map<String, dynamic> json) {
    return CellStatus(
        json["cell"], json["status"], json["type"], json["service"]);
  }
}
