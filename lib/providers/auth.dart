import 'package:flutter/widgets.dart';
import 'package:mvk_app/api/auth.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _phone;

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
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
