import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:mvk_app/api/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _phone;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    // todo: upcomment if expiryDate field will be used
    //if (_expiryDate != null &&
    //    _expiryDate!.isAfter(DateTime.now()) &&
    //    _token != null) {
    //  return _token;
    //}
    return _token;
  }

  String? get phone {
    return _phone;
  }

  Future<void> confirmOtp(String? phone, String otpCode) async {
    try {
      _token = await AuthApi.confirmOtpAndObtainToken(phone ?? "", otpCode);
      _phone = phone;
      //_autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "phone": _phone,
      });
      prefs.setString("userData", userData);
    } catch (e) {
      rethrow;
    }
  }

  void logout() async {
    _token = null;
    _expiryDate = null;
    _phone = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData') ?? "{}")
        as Map<String, dynamic>;
    print("extracted user data: $extractedUserData");

    _token = extractedUserData['token'] as String;
    _phone = extractedUserData['phone'] as String;
    notifyListeners();
    //_autoLogout();
    return true;
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
