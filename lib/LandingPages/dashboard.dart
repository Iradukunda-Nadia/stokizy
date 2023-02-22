import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/LandingPages/login.dart';
import 'package:inventory_app/Reports/deductionsRep.dart';
import 'package:inventory_app/Reports/issuanceReport.dart';
import 'package:inventory_app/Stock/inStock.dart';
import 'package:inventory_app/Stock/issuance.dart';
import 'package:inventory_app/returns/replace.dart';
import 'package:inventory_app/returns/returns.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../comp/suppliers.dart';

class Dashboard extends StatefulWidget {
  final String? userID;
  const Dashboard({Key? key,
    this.userID,
  }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? userCompany;
  String? currentUser;

  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userCompany = prefs.getString('company');
      currentUser = prefs.getString('user');
    });

  }

  @override
  void initState() {
    if (!kIsWeb) {_messaging.subscribeToTopic('procurement');}
    _messaging.getToken().then((token) {});
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              content: ListTile(
                title: Text(message.notification!.title!),
                subtitle: Text(message.notification!.body!),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    },);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              content: ListTile(
                title: Text(message.notification!.title!),
                subtitle: Text(message.notification!.body!),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    },);
    getStringValue();
    super.initState();
  }
  Logout()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('company');
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
    const Login()), (Route<dynamic> route) => false);
  }

  Future<void>handleRefresh()async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('userCompany: $userCompany');
    return Scaffold(
        backgroundColor: const Color(0xffC3B1E1),
        appBar: AppBar(
          title: const Text("INVENTORY"),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: const Color(0xffC3B1E1),
          actions: <Widget>[

            Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: PopupMenuButton(
                    icon: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.exit_to_app,
                          color: Colors.red[900],)),
                    onSelected: (String value) {
                      switch (value) {
                        case 'Logout':
                          Logout();
                          break;
                      // Other cases for other menu options
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: "Logout",
                        child: Row(
                          children: const <Widget>[
                            Text("Logout"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            )
          ],
        ),
        body:SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: handleRefresh,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 30.0,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => const InStock()));
                      },
                      child: CircleAvatar(
                        maxRadius: 60.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.arrow_downward_sharp),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text("Stock-In"),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => const Issue()));
                      },
                      child: CircleAvatar(
                        maxRadius: 60.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.arrow_upward_sharp),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text("Stock-Out"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),/*
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => const Replace()));
                      },
                      child: CircleAvatar(
                        maxRadius: 60.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(CupertinoIcons.arrow_uturn_left),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text("Return"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),*/

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => const Return()));
                      },
                      child: CircleAvatar(
                        maxRadius: 60.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.exit_to_app),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text("Clearance"),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => const Replace()));
                      },
                      child: CircleAvatar(
                        maxRadius: 60.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(Icons.compare_arrows_outlined),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text("Replacement"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 70.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shadowColor: Colors.black12,
                    color: Colors.white70,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0,35.0,8.0,35.0),
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance.collection("company").doc(userCompany).snapshots(),
                          builder: (context,AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: 1,
                                      itemBuilder: (BuildContext context, int index) {
                                        return IntrinsicHeight(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: (){
                                                    Navigator.of(context).push(CupertinoPageRoute(
                                                        builder: (context) => const Suppliers()));
                                                  },
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        Text(snapshot.data['suppliers'] > 100 ? '100+': '${snapshot.data['suppliers'
                                                        ].toString()}+',
                                                          style: const TextStyle(
                                                            fontSize: 30.0,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black87,
                                                          ),),
                                                        const Text('SUPPLIER \n Reports'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const VerticalDivider(color: Colors.purpleAccent),
                                                GestureDetector(
                                                  onTap: (){
                                                    Navigator.of(context).push(CupertinoPageRoute(
                                                        builder: (context) => issuanceReport()));
                                                  },
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        Text(snapshot.data['issuance'
                                                        ] > 100 ? '100+': '${snapshot.data['issuance'
                                                        ].toString()}+',
                                                          style: const TextStyle(
                                                            fontSize: 30.0,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black87,
                                                          ),),
                                                        const Text('ISSUANCE \n Reports'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const VerticalDivider(color: Colors.purpleAccent),
                                                GestureDetector(
                                                  onTap: (){
                                                    Navigator.of(context).push(CupertinoPageRoute(
                                                        builder: (context) => Deductions()));
                                                  },
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        Text(snapshot.data['deductions'
                                                        ] > 100 ? '100+': '${snapshot.data['deductions'
                                                        ].toString()}+',
                                                          style: const TextStyle(
                                                            fontSize: 30.0,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black87,
                                                          ),),
                                                        const Text('DEDUCTIONS \n Reports'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ));
                                      },
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const Text('');
                            }
                          }),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
