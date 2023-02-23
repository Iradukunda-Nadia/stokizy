

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/LandingPages/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? _password;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _submitCommand() {
    //get state of our Form
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      setState(() {
        _errorMessage = "";
      });
      _loginCommand();
    }
  }


  _loginCommand() async {
    print('Login initiated');
    var collectionReference = FirebaseFirestore.instance.collection('users');
    var query = collectionReference.where('id', isEqualTo: _password);
    if (kDebugMode) {
      print('query: $query');
    }
    query.get().then((querySnapshot) {
      if (kDebugMode) {
        print('Query running');
      }
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'invalid login details';
        });

      }
      else {
        querySnapshot.docs.forEach((document)
        async {

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('user', document['dept']);
          prefs.setString('company', document['company']);
          if (!kIsWeb) {
            FirebaseMessaging.instance.subscribeToTopic('all${document['company']}');
            FirebaseMessaging.instance.subscribeToTopic('${document['dept']}-${document['company']}');
          }

          Navigator.of(context).pushReplacement( CupertinoPageRoute(
              builder: (BuildContext context) =>  Dashboard(userID: document['company'],)
          ));
        });
      }
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print('error $error');
      }
    });
  }
  String? _errorMessage;
  bool isHidden = true;
  void _toggleHiddenView() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffC3B1E1),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Welcome', style: TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'DelaGothicOne'),),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 8.0),
                  child: Center(
                    child: TextFormField(
                      maxLines: 1,
                      obscureText: isHidden,
                      obscuringCharacter: '*',
                      autofocus: false,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                      ),
                      cursorColor: Colors.white,
                      textAlign: TextAlign.center,
                      autocorrect: false,
                      validator: (value) => value!.length < 5 ? 'The Key should be atleast 5 characters' : null,
                      onSaved: (value) => _password = value,
                      decoration: InputDecoration(
                        hintText: 'Please enter your Key',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                        contentPadding: EdgeInsets.zero,
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _toggleHiddenView();
                          },
                          child: !isHidden
                              ? Icon(
                            CupertinoIcons.eye_slash,
                            color: Theme.of(context).disabledColor,
                            size: 20,
                          )
                              : Icon(
                            CupertinoIcons.eye,
                            color: Theme.of(context).disabledColor,
                            size: 20,
                          ),
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.lock,
                          color: Theme.of(context).disabledColor,
                          size: 20,
                        ),
                        isCollapsed: false,
                      ),
                    ),
                  ),
                ),
                showErrorMessage(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(70, 10, 70, 0),
                  child: MaterialButton(
                    onPressed: _submitCommand,
                    color: Colors.purple[300],
                    elevation: 16.0,
                    minWidth: 400,
                    height: 50,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: const Text('SIGN IN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget showErrorMessage() {
    if (_errorMessage != "" && _errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage ?? 'error',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 13.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }
}