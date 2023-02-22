
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService{
  Future checkCompany() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString('company');
    if (kDebugMode) {
      print('uid: $uid');
    }
    if (uid == null){
      return 'noCompany';
    }
    else {
      return uid;
    }
  }
}