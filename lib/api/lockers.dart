import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'settings.dart';
import '../models/lockers.dart';
import 'http_exceptions.dart';

const domain =
    debugServer ? "http://localhost:8000" : "https://lockershub.online";

class LockerApi {
  static const baseUrl = domain + "/api/v1";

  static Future<Locker> fetchLockerById(String lockerId) async {
    var apiUrl = "/lockers/$lockerId";
    try {
      var res = await http.get(Uri.parse(baseUrl + apiUrl));
      if (res.statusCode == 200) {
        var locker = Locker.fromJson(
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
        return locker;
      } else {
        throw HttpException(res.reasonPhrase.toString(),
            statusCode: res.statusCode);
      }
    } on SocketException {
      throw HttpException("SocketException", statusCode: 500);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<CellStatus>> getFreeCells(
    int lockerId, {
    String? service,
    int? typeId,
  }) async {
    var apiUrl = "/lockers/$lockerId/cells/free";

    try {
      Map<String, Object> bodyData = {};
      if (service != null) {
        bodyData["service"] = service;
      }
      if (typeId != null) {
        bodyData["type_id"] = typeId.toString();
      }

      var res = await http.post(
        Uri.parse(baseUrl + apiUrl),
        body: json.encode(bodyData),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
      );
      if (res.statusCode == 200) {
        var response =
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

        final data = response["data"] as List<dynamic>;
        List<CellStatus> cells = [];
        for (var element in data) {
          cells.add(CellStatus.fromJson(element));
        }
        return cells;
      } else if (res.body.contains("error")) {
        throw HttpException("Не можемо зв'язатись з комплексом :(",
            statusCode: 400);
      } else {
        throw HttpException(res.reasonPhrase.toString(), statusCode: 500);
      }
    } on SocketException {
      throw HttpException("SocketException", statusCode: 500);
    } catch (e) {
      if (e is HttpException && e.statusCode == 400) {
        rethrow;
      }
      throw HttpException(e.toString(), statusCode: 500);
    }
  }

  static Future<bool> isActive(String lockerId) async {
    var apiUrl = "/lockers/$lockerId/is-active";
    try {
      var res = await http.get(Uri.parse(baseUrl + apiUrl));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body["is_active"];
      } else {
        throw HttpException(res.reasonPhrase.toString(),
            statusCode: res.statusCode);
      }
    } on SocketException {
      throw HttpException("SocketException", statusCode: 500);
    } catch (e) {
      rethrow;
    }
  }
}
