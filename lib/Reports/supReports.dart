import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:inventory_app/reusableUI/focus.dart';
import 'package:inventory_app/services/ShareSave.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupRep extends StatefulWidget {
  String? supplier;

  SupRep({super.key,
    this.supplier,
  });
  @override
  _SupRepState createState() => _SupRepState();
}

class _SupRepState extends State<SupRep> {

  @override
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
  getCsv() async {

    //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

    List<List<dynamic>> rows = <List<dynamic>>[];


    rows.add(<String>['DATE', 'ITEM','QUANTITY','SUPPLIER', 'TOTAL (KSH.)'],);
    final QuerySnapshot result =
    searchController.text == '' ||  searchController.text == null  ?
    await FirebaseFirestore.instance.collection("addedStock").where('company', isEqualTo: userCompany).where('supplier', isEqualTo: widget.supplier).orderBy('timestamp', descending: true).get():
    await FirebaseFirestore.instance.collection("addedStock").where('company', isEqualTo: userCompany).where('month', isEqualTo: searchController.text).where('supplier', isEqualTo: widget.supplier).orderBy('timestamp', descending: true).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents != null) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      documents.forEach((snapshot) {
        List<String> recind = <String>[
          snapshot['date'],
          snapshot['Item'],
          snapshot['Quantity'],
          snapshot["supplier"],
          snapshot['Total'],
        ];
        rows.add(recind);
      });
      String csv = const ListToCsvConverter().convert(rows);
      if (kIsWeb) {
        ShareFiles().generateCSV(csv, '${DateFormat('MMM-yyyy').format(DateTime.now())} ${widget.supplier} Report');
      }
      else{
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        File f = await ShareFiles().localF('${DateFormat('MMM-yyyy').format(DateTime.now())} ${widget.supplier}-Report');
        f.writeAsString(csv);
        ShareFiles().shareLocal(f, '${DateFormat('MMM-yyyy').format(DateTime.now())} ${widget.supplier} Report');
      }
    }
  }
  TextEditingController searchController = TextEditingController();
  String? sQuery;
  String? _cont;
  int? _contri;
  String? contString;
  int total = 0;
  int? newTotal;
  DateTime? _selectedDate;



  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        builder: (context, child) {
          return child!;
        });

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      searchController
        ..text = DateFormat.yMMMd().format(_selectedDate!)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: searchController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Supplier reports'),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      focusNode: AlwaysDisabledFocusNode(),
                      controller: searchController,
                      onChanged: (value){
                        setState(() {
                          sQuery = searchController.text;
                        });
                      },
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                  ),
                  Card(
                    color: searchController.text == '' ||  searchController.text == null ? Colors.white: Colors.purple[300],
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
                                  searchController.text == '' ||  searchController.text == null ?
                                  "Supplies as at: ${DateFormat('dd MMM yyyy').format(DateTime.now())}": 'Total spent: KSH.$contString',
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
                          stream: searchController.text == '' ||  searchController.text == null ?
                          FirebaseFirestore.instance.collection("addedStock").where('supplier', isEqualTo: widget.supplier).orderBy('timestamp', descending: true).snapshots():
                          FirebaseFirestore.instance.collection("addedStock").where('month', isEqualTo: searchController.text).where('supplier', isEqualTo: widget.supplier).orderBy('timestamp', descending: true).snapshots(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) return const Text('Loading...');

                            return FittedBox(
                              child: DataTable(
                                columnSpacing: 10,
                                columns: <DataColumn>[
                                  const DataColumn(label: Text('DATE',style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),)),
                                  DataColumn(label: Row(
                                    children: const [
                                      VerticalDivider(),
                                      Text('ITEM',style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),),
                                    ],
                                  )),
                                  DataColumn(label: Row(
                                    children: const [
                                      VerticalDivider(),
                                      Text('QUANTITY',style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),),
                                    ],
                                  )),
                                  DataColumn(label: Row(
                                    children: const [
                                      VerticalDivider(),
                                      Text('SUPPLIER',style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),),
                                    ],
                                  )),
                                  DataColumn(label: Row(
                                    children: const [
                                      VerticalDivider(),
                                      Text('TOTAL (KSH.)',style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),),
                                    ],
                                  )),

                                ],
                                rows: _createRows(snapshot.data),

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
    int tot = 0;
    snapshot.docs.forEach((document)
    {
      SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
        _cont = document['Total'];
        _contri = int.parse(_cont!);
        newTotal = tot += _contri!;
        contString = newTotal.toString();
      }));

    });

    List<DataRow> newList = snapshot.docs.map((doc) {
      return DataRow(
          cells: [
            DataCell(Text(doc["date"],
              style: const TextStyle(fontSize: 10.0),)),
            DataCell(Row(
              children: [
                const VerticalDivider(),
                Text(doc["Item"],
                  style: const TextStyle(fontSize: 10.0),),
              ],
            )),
            DataCell(Row(
              children: [
                const VerticalDivider(),
                Text(doc["Quantity"],
                  style: const TextStyle(fontSize: 10.0),),
              ],
            )),
            DataCell(Row(
              children: [
                const VerticalDivider(),
                Text(doc["supplier"],
                  style: const TextStyle(fontSize: 10.0),),
              ],
            )),
            DataCell(Row(
              children: [
                const VerticalDivider(),
                Text(doc["Total"],
                  style: const TextStyle(fontSize: 10.0),),
              ],
            )),
          ]);}).toList();

    return newList;
  }

}