import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_app/Stock/summary.dart';
import 'package:inventory_app/reusableUI/dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class ReturnItem extends StatefulWidget {
  final Map<String,dynamic>? uniform ;
  final Map<String,dynamic>? assets;
  final String? name;
  final String? id;
  final String? docID;
  final String? region;
  final String? assign;
  final String? dateCleared;
  final String? reason;
  final String? pfn;

  const ReturnItem({super.key,
  this.uniform,
  this.name,
  this.assets,
  this.id,
  this.docID,
  this.assign,
  this.region,
  this.dateCleared,
  this.reason,
  this.pfn,
  });

  @override
  _ReturnItemState createState() => _ReturnItemState();
}

class _ReturnItemState extends State<ReturnItem> {
  String? item;
  String? qt;

  final formKey = GlobalKey<FormState>();
  bool? isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    qt = '0';
    isLoading = false;
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
        title: Text(widget.name??''),
        centerTitle: true,
        actions: <Widget>[
          Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              MaterialButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                color: Colors.red[700],
                child: const Text('Summary',
                    style: TextStyle(fontSize: 16.0, color: Colors.white)),
                onPressed: (){
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => Sum(
                        name: widget.name ??'',
                        id: widget.id ??'',
                        form: "returns",
                        docID: widget.docID ??'',
                        assign : widget.assign ??'',
                        region: widget.region ??'',
                        reason: widget.reason ??'',
                        dateCleared: widget.dateCleared ??'',
                        pfn: widget.pfn ??'',
                      )));
                },
              )


            ],
          )
        ],
      ),
      floatingActionButton: kIsWeb? const Offstage(): FloatingActionButton.extended(
        label: const Text('Return Items'),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => Details(
              name: widget.name ??'',
              id: widget.id ??'',
              docID: widget.docID ??'',
              company: userCompany ??'',
            )));
        },
      ),
      body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[

            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: Container(
                        alignment: const Alignment(0.0,2.5),
                        child: const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars.png',
                          ),
                          radius: 60.0,
                        ),
                      ),
                    ),
                    Text(
                      'Name: ${widget.name}'
                      ,style: const TextStyle(
                        fontSize: 18.0,
                        color:Colors.blueGrey,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold
                    ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'ID: ${widget.id}'
                      ,style: const TextStyle(
                        fontSize: 18.0,
                        color:Colors.blueGrey,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w400
                    ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Card(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:MainAxisSize.min,
                      children: <Widget>[
                        const Center(
                          child: Text(
                            "Items",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w700),
                          ),
                        ),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance.collection("issuance").doc(widget.docID).snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                final Map<String,dynamic> items = Map<String, dynamic>.from(snapshot.data!["uniform"]) ;
                                return Flexible(
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: items.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      String key = items.keys.elementAt(index);
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          ListTile(
                                            title: Text(key),
                                            subtitle: Text(items[key].toString()),
                                          ),
                                          const Divider(
                                            height: 2.0,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return const Text('');
                              }
                            }),

                      ],
                    ),),
                  ]
              ),
            ),
          ]
      ),
    );
  }
}

class Details extends StatefulWidget {
  final String? name;
  final String? id;
  final String? docID;
  final String? company;
  const Details({super.key,
  this.name, this.id, this.docID, this.company
  });
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  var itemTECs = <TextEditingController>[];
  var qtTECs = <TextEditingController>[];
  var cards = <Card>[];
  bool? see;
  Card createCard() {
    var itemController = TextEditingController();
    var qtController = TextEditingController();
    itemTECs.add(itemController);
    qtTECs.add(qtController);
    return Card(
      child:  ListTile(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Item ${cards.length + 1}'),
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection("issuance").doc(widget.docID).snapshots(),
                builder: (context,AsyncSnapshot snapshot) {
                  final Map<String,dynamic> items = snapshot.hasData? Map<String, dynamic>.from(snapshot
                      .data!["uniform"]) : {};
                  List itemsList = items.entries.toList();
                  if (!snapshot.hasData) {
                    return const Text("Please wait");
                  }
                  else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      child: itemsList.isNotEmpty
                          ? DropdownButtonFormField(
                        items: itemsList.map((item) {
                          return DropdownMenuItem(value: item.key, child: Text(item.key));
                        }).toList(),
                        validator: (value) => value!.toString().isEmpty ? 'Email cannot be blank' : null,
                        onChanged: (value) {
                          setState(() {
                            itemController.text = value as String;
                          });
                        },
                        hint: const Text(
                          "Select Item",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: const TextStyle(color: Colors.black),
                      )
                          : DropdownButtonFormField(
                        items: const [
                          DropdownMenuItem(value: 'No item was issued', child: Text('No item was issued'))
                        ],
                        validator: (value) => value!.toString().isEmpty ? 'Email cannot be blank' : null,
                        onChanged: (value) {
                          setState(() {
                            itemController.text = value as String;
                          });
                        },
                        hint: const Text(
                          "Select Item",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }
                }
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: TextFormField(
                inputFormatters: [FilteringTextInputFormatter. digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                controller: qtController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'SFUIDisplay'
                ),
                decoration: InputDecoration(

                    errorStyle: const TextStyle(color: Colors.red),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    labelText: 'Quantity',
                    labelStyle: const TextStyle(
                        fontSize: 16
                    )
                ),
                validator: (val) =>
                val!.isEmpty  ? 'Field cannot be empty' : null,
                onChanged: (val){
                },

              ),
            ),
          ],
        ),
        trailing: InkWell(
            onTap: (){
              setState(() {
                cards.removeAt(cards.length-1);
                itemTECs.removeAt(itemTECs.length-1);
                qtTECs.removeAt(qtTECs.length-1);
              });
            },
            child: const Icon(Icons.delete,
                color: Colors.red) ),

      ),
    );
  }
  @override
  void initState() {
    super.initState();
    getStringValue();
    cards.add(createCard());
    isLoading = false;

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
  final formKey = GlobalKey<FormState>();
  void _submitCommand() {
    //get state of our Form
    final form = formKey.currentState;

    if (form!.validate() && _signKey.currentState!.validate()) {
      form.save();
      if( _controller.isEmpty){
        setState(() {
          isLoading = false;
        });
        Dialogs().showSignatureWarning(context);
      }
      else{
        _signKey.currentState!.save();
        _loginCommand();
      }

    }
  }
  bool? isLoading;

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.indigo,
    exportBackgroundColor: Colors.transparent,
  );


  Future<void> _loginCommand() async {
    setState(() {
      isLoading = true;

    });
    CollectionReference ref = FirebaseFirestore.instance
        .collection('inStock');

    Uint8List? data = await _controller.toPngBytes();
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/sign.jpg').create();
    file.writeAsBytesSync(data!);
    String bs64 = base64Encode(data);

    for (int i = 0; i < cards.length; i++) {
      QuerySnapshot eventsQuery = await ref.where('company', isEqualTo: userCompany).where(
          'item', isEqualTo: itemTECs[i].text).get();

      eventsQuery.docs.forEach((msgDoc) {
        msgDoc.reference.update(
            {'count': FieldValue.increment(int.parse(qtTECs[i].text))});
      });
      FirebaseFirestore.instance.collection('issuance')
          .doc(widget.docID)
          .update({
        'uniform.${itemTECs[i].text}': FieldValue.increment(
            -(int.parse(qtTECs[i].text))),
        'company': userCompany ?? '',
      });

      CollectionReference reference = FirebaseFirestore.instance.collection('cleared');
      CollectionReference reff = FirebaseFirestore.instance.collection('issueRep');

      await reference.doc(
          '${widget.id}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}')
          .set({
        "date": DateFormat(' yyyy- MM - dd').format(DateTime.now()),
        "dt": DateFormat('dd MMM yyyy').format(DateTime.now()),
        "month": DateFormat(' yyyy- MM').format(DateTime.now()),
        'timestamp': DateTime.now(),
        "company": userCompany ?? '',
        'status': 'pending',
        'name': widget.name ?? '',
        'id': widget.id ??'',
        'sig': bs64,

      }, SetOptions(merge: true));


      FirebaseFirestore.instance.collection('cleared')
          .doc(
          '${widget.id}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}')
          .update({
        'Items.${itemTECs[i].text}': FieldValue.increment(
            int.parse(qtTECs[i].text)),
      });

      await reff.add({
        'item': itemTECs[i].text,
        'quantity': '-${qtTECs[i].text}',
        "dt": DateFormat('dd MMM yyyy').format(DateTime.now()),
        "date": DateFormat(' yyyy- MM - dd').format(DateTime.now()),
        "month": DateFormat(' yyyy- MM').format(DateTime.now()),
        'timestamp': DateTime.now(),
        "company": userCompany ??'',
        'name': widget.name ??'',
        'id': widget.id ??'',
        'type': 'Cleared',
      });
    }
    _showRequest();
  }

  void _showRequest() {
    // flutter defined function
    final form = formKey.currentState;
    form!.reset();
    _signKey.currentState!.reset();
    setState(() {
      isLoading = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext cxt) {
        // return object of type Dialog
        return AlertDialog(
          content: const Text("Your data has been added"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("close"),
              onPressed: () {
                Navigator.of(cxt).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  final _signKey = GlobalKey<FormState>();
  String? dDate;
  String? reason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form  (
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(

                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(

                        errorStyle: const TextStyle(color: Colors.red),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        labelText: 'Reason for being discharged',

                      ),
                      validator: (val) =>
                      val!.isEmpty  ? 'Field cannot be empty' : null,
                      onChanged: (val){
                        reason = val;
                      },
                      onSaved: (val){
                        reason = val;
                      },

                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cards.length,
                          itemBuilder: (BuildContext context, int index) {
                            return cards[index];
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: MaterialButton(
                            child: const Text('add another item'),
                            onPressed: () => setState(() => cards.add(createCard())),
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
            Form(
              key: _signKey,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0,10.0,10.0,10.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: const Border(
                        top: BorderSide(width: 2.0, color: Colors.black),
                        left: BorderSide(width: 2.0, color: Colors.black),
                        right: BorderSide(width: 2.0, color: Colors.black),
                        bottom: BorderSide(width: 2.0, color: Colors.black),
                      ),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        Signature(
                          controller: _controller,
                          height: 150,
                          backgroundColor: Colors.white,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                              child: Text('Signature', style: TextStyle(color: Colors.black),),
                            ),
                            IconButton(onPressed: (){
                              _controller.clear();
                            }, icon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                              child: Icon(Icons.close),
                            )),
                          ],
                        ),
                      ],
                    ),
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(70, 10, 70, 0),
              child: MaterialButton(
                onPressed: isLoading == true ? null: _submitCommand,
                color: Colors.white,
                elevation: 16.0,
                minWidth: 400,
                height: 50,
                textColor: Colors.purple[300],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                child : Text( isLoading == true? 'Loading ...':'Submit',
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'SFUIDisplay',
                    fontWeight: FontWeight.bold,
                  ),),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PersonEntry {
  final String item;
  final String qt;

  PersonEntry(this.item, this.qt,);
  @override
  String toString() {
    return 'Person: name= $item, age= $qt';
  }
}