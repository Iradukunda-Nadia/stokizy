import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:inventory_app/Stock/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'newStaff.dart';

class Issue extends StatefulWidget {
  const Issue({super.key});

  @override
  _IssueState createState() => _IssueState();
}

class _IssueState extends State<Issue> {
  TextEditingController searchController = TextEditingController();
  String? sQuery;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sQuery = '';
    getStringValue();
  }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issuance'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('New Staff'),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => NewStaff()));
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {

                });
              },
              controller: searchController,
              decoration: const InputDecoration(
                  labelText: "Enter name",
                  hintText: "Name",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("issuance").where('company', isEqualTo: userCompany).orderBy('assign', descending: true).snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    // <3> Retrieve `List<DocumentSnapshot>` from snapshot
                    // ignore: missing_return
                    final List<DocumentSnapshot> documents = snapshot.data.docs;
                    return ListView(
                        children: documents
                            // ignore: missing_return
                            .map((doc) => doc['name'].toLowerCase().contains(searchController.text.toLowerCase()) || doc['id'].contains(searchController.text.toLowerCase())  ?
                        ListTile(
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) => GuardProfile(
                                  uniform: Map<String, dynamic>.from(doc["uniform"]),
                                  name: doc['name'].toUpperCase(),
                                  id: doc['id'],
                                  assign: doc['assign'],
                                  region: doc['region'],
                                  pfn: doc['pfn'],
                                  docID: doc.id,
                                )));
                          },
                          leading: const CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              'https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars.png',
                            ),
                          ),
                          title: Text(doc['name'].toUpperCase(),

                          ),
                          subtitle: Text('ID: ${doc['id']}'),
                        ): const Offstage(),)
                            .toList());
                  } else {
                    return const Text('');
                    }

                })
          ),
        ],
      ),
    );
  }
}


