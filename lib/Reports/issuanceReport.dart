import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:inventory_app/services/ShareSave.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class issuanceReport extends StatefulWidget {
  @override
  _issuanceReportState createState() => _issuanceReportState();
}

class _issuanceReportState extends State<issuanceReport> {

  getCsv() async {
    //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.
    List<List<dynamic>> rows = <List<dynamic>>[];


    rows.add(<String>['DATE', 'ITEM','QUANTITY','NAME', 'ID'],);
    final QuerySnapshot result =
    await FirebaseFirestore.instance.collection("issueRep").where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents != null) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      documents.forEach((snapshot) {
        List<String> recind = <String>[
          snapshot['date'],
          snapshot['item'],
          snapshot['quantity'],
          snapshot['name'],
          snapshot['id'],

        ];
        rows.add(recind);
      });

      String csv = const ListToCsvConverter().convert(rows);
      if (kIsWeb) {
        ShareFiles().generateCSV(csv, '${DateFormat('MMM-yyyy').format(DateTime.now())} IssuanceReport.csv');
      }
      else{
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        File f = await ShareFiles().localF('${DateFormat('MMM-yyyy').format(DateTime.now())} IssuanceReport.csv');
        f.writeAsString(csv);
        ShareFiles().shareLocal(f, '${DateFormat('MMM-yyyy').format(DateTime.now())} IssuanceReport');
      }


    }
  }
  void initState() {
    // TODO: implement initState
    super.initState();
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
        automaticallyImplyLeading: true,
        title: const Text('Issuance Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Row(children: const [
          Icon(Icons.file_download),
          SizedBox(width: 5.0,),
          Text('Download Report')
        ],),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {
          getCsv();
        },
      ),
     body: Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[

        SingleChildScrollView(
          child: RepaintBoundary(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 40.0,
                ),
                Card(
                  child: Container(
                    margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 10.0,
                        ),
                        Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Items Issued as at: ${DateFormat(' dd MMM yyyy').format(DateTime.now())}",
                                style: const TextStyle(
                                    fontSize: 12.0, fontWeight: FontWeight.w700),
                              ),



                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),

                      ],
                    ),
                  ),
                ),

                Card(
                  child: Column(
                    mainAxisSize:MainAxisSize.min,
                    children: <Widget>[
                      StreamBuilder(
                        stream: FirebaseFirestore.instance.collection("issueRep").where('company', isEqualTo: userCompany).orderBy('timestamp', descending: true).snapshots(),
                        builder: (context,AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) return const Text('Loading...');

                          return FittedBox(
                            child: Center(
                              child: DataTable(
                                columnSpacing: 10,
                                headingRowColor: MaterialStateProperty.all(Colors.grey[400]),
                                columns: <DataColumn>[
                                  const DataColumn(label: Text('DATE',style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),)),
                                  DataColumn(label: Row(
                                    children: const [
                                      VerticalDivider(),
                                      Text('ITEM',style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),),
                                    ],
                                  )),
                                  DataColumn(label: Row(
                                    children: const [
                                      VerticalDivider(),
                                      Text('QUANTITY',style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),),
                                    ],
                                  )),
                                  DataColumn(label: Row(
                                    children: const [
                                      VerticalDivider(),
                                      Text('NAME',style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),),
                                    ],
                                  )),
                                  DataColumn(label: Row(
                                    children: const [
                                      VerticalDivider(),
                                      Text('ID',style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),),
                                    ],
                                  )),
                                  ],
                                rows: _createRows(snapshot.data),

                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                )

              ],
            ),
          ),
        ),

      ],
    ),
    );
  }

  List<DataRow> _createRows(QuerySnapshot snapshot) {

    List<DataRow> newList = snapshot.docs.map((doc) {
      return DataRow(
          cells: [
            DataCell(Text(doc["date"],
              style: const TextStyle(fontSize: 12.0),)),
            DataCell(Row(
              children: [
                const VerticalDivider(),
                Text(doc["item"],
                  style: const TextStyle(fontSize: 12.0),),
              ],
            )),
            DataCell(Row(
              children: [
                const VerticalDivider(),
                Text(doc["quantity"],
                  style: const TextStyle(fontSize: 12.0),),
              ],
            )),
            DataCell(Row(
              children: [
                const VerticalDivider(),
                Text(doc["name"],
                  style: const TextStyle(fontSize: 12.0),),
              ],
            )),
            DataCell(Row(
              children: [
                const VerticalDivider(),
                Text(doc["id"],
                  style: const TextStyle(fontSize: 12.0),),
              ],
            )),
            ]);}).toList();

    return newList;
  }

}