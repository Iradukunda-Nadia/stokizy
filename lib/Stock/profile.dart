import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/Stock/summary.dart';
import 'package:inventory_app/reusableUI/dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class GuardProfile extends StatefulWidget {
  final Map<String,dynamic>? uniform ;
  final Map<String,dynamic>? assets;
  final String? name;
  final String? id;
  final String? docID;
  final String? assign;
  final String? region;
  final String? pfn;

  const GuardProfile({super.key,
  this.uniform,
  this.pfn,
  this.name,
  this.assets,
  this.id,
  this.docID,
  this.assign,
  this.region});

  @override
  _GuardProfileState createState() => _GuardProfileState();
}

class _GuardProfileState extends State<GuardProfile> {
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
  void _submitCommand() {
    //get state of our Form
    final form = formKey.currentState;

    if (form!.validate() ) {
      form.save();

      _loginCommand();
    }
  }
  Future<void> _loginCommand() async {
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = FirebaseFirestore.instance.collection('issuance');
      await reference.doc(widget.docID).update({
        "assign": assign,
        'region': region,

      });


    }).then((result) =>

        _showRequest());

  }

  void _showRequest() {
    // flutter defined function
    final form = formKey.currentState;
    form!.reset();
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
  String? assign;
  String? region;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name!),
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
                    name: widget.name?? '',
                    id: widget.id?? '',
                    docID: widget.docID?? '',
                    pfn: widget.pfn?? '',
                    form: "issued",
                  )));
              },
          ),

        ],
      )
        ],
      ),
      floatingActionButton: kIsWeb? const Offstage():FloatingActionButton.extended(
        label: const Text('Add Item'),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => SOF(
              name: widget.name?? '',
              id: widget.id?? '' ,
              docID: widget.docID?? '',
              pfn: widget.pfn?? '',
              company: userCompany?? '',
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
                      Container(
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
                     ListTile(
                       subtitle:  Row(
                         children: [
                           Text(
                             'ID: ${widget.id}'
                             ,style: const TextStyle(
                               fontSize: 14.0,
                               color:Colors.blueGrey,
                               letterSpacing: 1.5,
                               fontWeight: FontWeight.w400
                           ),
                           ),
                           const SizedBox(
                             width: 10,
                           ),
                           Text(
                             'PF NO: ${widget.pfn}'
                             ,style: const TextStyle(
                               fontSize: 14.0,
                               color:Colors.blueGrey,
                               letterSpacing: 1.5,
                               fontWeight: FontWeight.bold
                           ),
                           ),
                         ],
                       ),
                     ),
                      const Divider(),
                      ListTile(
                        onTap: (){
                          _settingModalBottomSheet(context);
                        },
                        subtitle: Column(
                          children: [
                            Text(
                              assign == '' || assign == null ? 'Assignment: ${widget.assign}': 'Assignment: ${assign}'
                              ,style: const TextStyle(
                                fontSize: 12.0,
                                color:Colors.blueGrey,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold
                            ),
                            ),
                            Text(
                              region == '' || region == null ? 'Region: ${widget.region}': 'Region: ${region}'
                              ,style: const TextStyle(
                                fontSize: 12.0,
                                color:Colors.blueGrey,
                                fontWeight: FontWeight.w400
                            ),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.edit, color: Colors.purple[300],),
                      ),


                      const SizedBox(
                        height: 10,
                      ),
                      Card(child: Container(
                        child: Column(
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
                                    final Map<String,dynamic> items = Map<String, dynamic>.from(snapshot.data["uniform"]) ;
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
                                                title: Text("$key"),
                                                subtitle: Text("${items[key].toString()}"),
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
                        ),
                      ),),
                    ]
                ),
            ),
          ]
      ),
    );
  }
  void _settingModalBottomSheet(context){
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc){
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                      ),
                      const SizedBox(height: 40.0,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Container(
                          child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'SFUIDisplay'
                            ),
                            decoration: InputDecoration(
                              errorStyle: const TextStyle(color: Colors.red),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              labelText: 'New Assignment',
                            ),
                            validator: (val) =>
                            val!.isEmpty  ? 'Field cannot be empty' : null,
                            onSaved: (val) => assign = val,
                            onChanged: (val){
                              setState(() {
                                assign = val;
                              });
                            },

                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Container(
                          child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'SFUIDisplay'
                            ),
                            decoration: InputDecoration(
                              errorStyle: const TextStyle(color: Colors.red),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              labelText: 'Region',
                            ),
                            validator: (val) =>
                            val!.isEmpty  ? 'Field cannot be empty' : null,
                            onSaved: (val) => region = val,
                            onChanged: (val){
                              setState(() {
                                region = val;
                              });
                            },

                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(70, 10, 70, 0),
                        child: MaterialButton(
                          onPressed: _submitCommand,
                          color: Colors.white,
                          elevation: 16.0,
                          minWidth: 400,
                          height: 50,
                          textColor: Colors.purple[300],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child : const Text('Submit',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'SFUIDisplay',
                              fontWeight: FontWeight.bold,
                            ),),
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}

class SOF extends StatefulWidget {
  String? name;
  String? id;
  String? docID;
  String? pfn;
  String? company;

  SOF({
    this.name, this.id, this.docID, this.pfn, this.company,
});

  @override
  _SOFState createState() => _SOFState();
}

class _SOFState extends State<SOF> {
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
            SizedBox(
              height: 60.0,
              child:  StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("inStock").where('company', isEqualTo: widget.company).orderBy('item', descending: false).snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return const Text("Please wait");
                    return DropdownButtonFormField(
                        items: snapshot.data!.docs != null && snapshot.data!.docs.isNotEmpty ? snapshot.data!
                            .docs.map<DropdownMenuItem<Object>>((
                            DocumentSnapshot document) {
                          return DropdownMenuItem(
                              value: document["item"]??'',
                              child: Text(document["item"]??''));
                        }).toList(): [
                          const DropdownMenuItem(
                              value: 'No Items added!',
                              child: Text('No Items added!')),
                        ],
                        validator: (value) => value == null
                            ? 'Please Select a Item' : null,
                        onChanged: (value) {
                          setState(() {
                            itemController.text = value as String;
                          });
                        },
                        hint: const Text("Select Item"),
                        style: const TextStyle(color: Colors.black),

                      );
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Container(
                child: TextFormField(
                  enabled: isLoading == true ? false: true,
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
                          fontSize: 11
                      )
                  ),
                  validator: (val) =>
                  val!.isEmpty  ? 'Field cannot be empty' : null,
                  onChanged: (val){
                  },

                ),
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
            {'count': FieldValue.increment(-(int.parse(qtTECs[i].text)))});
      });
      FirebaseFirestore.instance.collection('issuance')
          .doc(widget.docID)
          .update({
        'uniform.${itemTECs[i].text}': FieldValue.increment(
            int.parse(qtTECs[i].text)),
      });

        CollectionReference reference = FirebaseFirestore.instance.collection('issued');
        CollectionReference reff = FirebaseFirestore.instance.collection('issueRep');

        await reference.doc(
            '${widget.id}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}')
            .set({
          "date": DateFormat(' yyyy- MM - dd').format(DateTime.now()),
          "dt": DateFormat('dd MMM yyyy').format(DateTime.now()),
          "month": DateFormat(' yyyy- MM').format(DateTime.now()),
          'timestamp': DateTime.now(),
          "company": userCompany ?? 'pelt',
          'status': 'pending',
          'name': widget.name ??'',
          'id': widget.id ?? '',
          'sig': bs64,

        }, SetOptions(merge: true));
        if (itemTECs[i].text.toString().toLowerCase() == 'boots'
            || itemTECs[i].text.toString().toLowerCase() == 'torch'
            || itemTECs[i].text .toString().toLowerCase() == 'torche' ){
          final String docID = '${widget.id}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
          FirebaseFirestore.instance.collection('deductions')
              .doc(widget.docID)
              .set({
            'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
            'timestamp': DateTime.now(),
            'id': widget.id ?? '',
            'name': widget.name ??'',
            'pfn': widget.pfn,
            'company': userCompany,

          }, SetOptions(merge: true));
          FirebaseFirestore.instance.collection('deductions')
              .doc(widget.docID)
              .update({
            'Items.${itemTECs[i].text}': FieldValue.increment(
                int.parse(qtTECs[i].text)),
          });
        }
      FirebaseFirestore.instance.collection('issued')
            .doc(
            '${widget.id}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}')
            .update({
          'Items.${itemTECs[i].text}': FieldValue.increment(
              int.parse(qtTECs[i].text)),
        });

        await reff.add({
          'item': itemTECs[i].text,
          'quantity': qtTECs[i].text,
          "dt": DateFormat('dd MMM yyyy').format(DateTime.now()),
          "date": DateFormat(' yyyy- MM - dd').format(DateTime.now()),
          "month": DateFormat(' yyyy- MM').format(DateTime.now()),
          'timestamp': DateTime.now(),
          "company": userCompany ?? '',
          'name': widget.name ?? '',
          'id': widget.id ??'',
          'type': 'issued',
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form  (
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: IconButton(onPressed: (){
                                          _controller.clear();
                                        }, icon: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                          child: Icon(Icons.close),
                                        )),
                                      ),
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

            ],
          ),
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