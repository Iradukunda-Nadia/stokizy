import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/LandingPages/dashboard.dart';
import 'package:inventory_app/LandingPages/login.dart';
import 'package:inventory_app/reusableUI/processLoader.dart';
import 'package:inventory_app/services/loginService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late final temp;

  @override
  void initState() {
    temp = LoginService().checkCompany().onError((error, stackTrace) {
      return 'noCompany';
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: FutureBuilder(
          future: temp,
        builder: (context, snapshot) {
            if(snapshot.hasData) {
              if (kDebugMode) {
                print('company: ${snapshot.data}');
              }
              return snapshot.data == 'noCompany' ? const Login() : Dashboard(userID: snapshot.data!.toString(),);
            }
            else if(snapshot.hasError){
              if (kDebugMode) {
                print('company: ${snapshot.error}');
              }
              return const Login();
            }
            else{
              return const Scaffold(
                backgroundColor: Color(0xffC3B1E1),
                body: Center(
                  child: ProcessLoader(),
                ),
              );
            }
          }
      ),
    );
  }
}


