import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:inventory_app/Stock/stockReport.dart';
import 'package:shared_preferences/shared_preferences.dart';


class InStock extends StatefulWidget {
  const InStock({super.key});

  @override
  _InStockState createState() => _InStockState();
}

class _InStockState extends State<InStock> {
  String? _cat;
  String? Item;
  String? qt;
  String? up;
  String? supplier;

  Future getCourse() async{
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore.collection("inStock").where("type", isEqualTo: _cat ).get();
    return qn.docs;

  }

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    qt = '0';
    up ='0';
    setState(() {
      _cat = "uniform";
    });
    getStringValue();
  }
  var qtController = TextEditingController();
  var upController = TextEditingController();

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
      appBar: AppBar(title: const Text("Items In Stock"), centerTitle: true,

        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => const StockReport()));},
                icon: const Icon(Icons.folder, size: 30,)),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add Item'),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => addStock()));
        },
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: 1100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 20.0,
                      maxHeight: 40.0,
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          child: MaterialButton(
                            onPressed: (){
                              setState(() {
                                _cat = "uniform";
                              });
                            },
                            color: _cat == 'uniform'?  Colors.purple[300]: const Color(0xffC3B1E1,),
                            elevation: 10.0,
                            minWidth: 150,
                            height: _cat == 'uniform'?  20: 30,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(_cat == 'uniform'?  'UNIFORMS': 'Uniforms',
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'SFUIDisplay',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          child: MaterialButton(
                            onPressed: (){
                              setState(() {
                                _cat = "asset";
                              });
                            },
                            color: _cat == 'asset'?  Colors.purple[300]: const Color(0xffC3B1E1,),
                            elevation: 10.0,
                            minWidth: 150,
                            height: _cat == 'asset'?  20: 30,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(_cat == 'asset'?  'ASSETS': 'Assets',
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'SFUIDisplay',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                Flexible(
                  fit: FlexFit.loose,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("inStock").where("type", isEqualTo: _cat ).where('company', isEqualTo: userCompany).snapshots(),
                      builder: (context, AsyncSnapshot snapshot){
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Text("Loading... Please wait"),
                          );
                        }if (snapshot.data == null){
                          return const Center(
                            child: Text("There is no data"),);
                        }else{
                          final List<DocumentSnapshot> documents = snapshot.data!.docs;
                          return ListView(
                          children: documents
                          // ignore: missing_return

                              .map((doc) => Card(
                            child: Stack(
                              alignment: FractionalOffset.topLeft,
                              children: <Widget>[
                                ListTile(
                                  title: Text("${doc["item"]}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 25.0,
                                    ),),
                                  trailing: Text("${(doc["count"]).toString()}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 30.0,
                                    ),),
                                ),

                              ],
                            ),
                          ),)
                            .toList());

                        }
                      }),)
              ]
          ),
        ),
      ),
    );
  }
}

class addStock extends StatefulWidget {
  @override
  _addStockState createState() => _addStockState();
}

class _addStockState extends State<addStock> {
  String? _cat;
  String? item;
  String? qt;
  String? up;
  String? supplier;

  Future getCourse() async{
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore.collection("inStock").where("type", isEqualTo: _cat ).get();
    return qn.docs;

  }
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    qt = '0';
    up ='0';
    setState(() {
      _cat = "uniform";
    });
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
  var qtController = TextEditingController();
  var upController = TextEditingController();
  bool? isLoading;
  void _submitCommand() {
    //get state of our Form
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();

      _loginCommand();
    }
  }
  Future<void> _loginCommand() async {
    final form = formKey.currentState;
    setState(() {
      isLoading = true;

    });

    print('Loading');

    CollectionReference ref = FirebaseFirestore.instance
        .collection('inStock');

    QuerySnapshot eventsQuery =  await ref.where('company', isEqualTo: userCompany).where('item', isEqualTo: item).get();

    if(eventsQuery.docs.isNotEmpty) {
      eventsQuery.docs.forEach((msgDoc) {
        msgDoc.reference.update({'count': FieldValue.increment(int.parse(qt ?? '0'))});
      });
    }
    else{
      CollectionReference reference = FirebaseFirestore.instance.collection('inStock');
      await reference.add({
        "item": item,
        "type": 'uniform',
        "company": userCompany,
        'count': int.parse(qt ?? '0'),
      });
    }

    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = FirebaseFirestore.instance.collection('addedStock');

      await reference.add({
        "Item": item,
        "Quantity": qt,
        "unitPrice": up,
        "Total": (int.parse(up??'0')*int.parse(qt??'0')).toString(),
        "supplier": supplier,
        "date" : DateFormat(' yyyy- MM - dd').format(DateTime.now()),
        "month" : DateFormat(' yyyy- MM').format(DateTime.now()),
        'timestamp': DateTime.now(),
        "company": userCompany,
        'status': 'pending',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Add Stock'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  SizedBox(
                    height: 60.0,
                    child:  StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection("inStock").where('company', isEqualTo: userCompany).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Text("Please wait");
                          return Autocomplete(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              }
                              else{
                                List<String> matches = snapshot.data!.docs.map((
                                    DocumentSnapshot document) {
                                  return document["item"].toString();
                                }).toList();

                                matches.retainWhere((s){
                                  return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                });
                                return matches;
                              }
                            },
                            onSelected: (String selection) {
                              setState(() {
                                item = selection;
                              });
                            },

                            fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted
                                ) {
                              return TextFormField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'SFUIDisplay'
                                ),
                                decoration: InputDecoration(
                                    errorStyle: const TextStyle(color: Colors.red),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.1),
                                    labelText: 'Item',
                                    labelStyle: const TextStyle(
                                        fontSize: 11
                                    )
                                ),
                                validator: (val) =>
                                val!.isEmpty  ? 'Field cannot be empty' : null,
                                onSaved: (val){
                                  setState(() {
                                    item = fieldTextEditingController.text;
                                  });
                                },
                              );
                            },
                          );
                        }
                    ),
                  ),
                  SizedBox(
                    height: 60.0,
                    child:  StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection("suppliers").where('company', isEqualTo: userCompany).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Text("Please wait");
                          return /*Autocomplete(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              }
                              else{
                                List<String> matches = snapshot.data!.docs.map((
                                    DocumentSnapshot document) {
                                  return document["name"].toString();
                                }).toList();

                                matches.retainWhere((s){
                                  return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                });
                                return matches;
                              }
                            },
                            onSelected: (String selection) {
                              setState(() {
                                supplier = selection;
                              });
                            },
                            fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted
                                ) {
                              return TextFormField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'SFUIDisplay'
                                ),
                                decoration: InputDecoration(
                                    errorStyle: const TextStyle(color: Colors.red),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.1),
                                    labelText: 'Supplier',
                                    labelStyle: const TextStyle(
                                        fontSize: 11
                                    )
                                ),
                                validator: (val) =>
                                val!.isEmpty  ? 'Field cannot be empty' : null,
                                onSaved: (val){
                                  setState(() {
                                    supplier = fieldTextEditingController.text;
                                  });
                                },
                              );
                            },
                          );*/

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: DropdownButtonFormField(
                              items: snapshot.data!.docs != null && snapshot.data!.docs.isNotEmpty ? snapshot.data!
                                  .docs.map<DropdownMenuItem<Object>>((
                                  DocumentSnapshot document) {
                                return DropdownMenuItem(
                                    value: document["name"],
                                    child: Text(document["name"]));
                              }).toList(): [
                                const DropdownMenuItem(
                                value: 'No suppliers added!',
                                child: Text('No suppliers added!')),
                              ],
                              value: supplier,
                              validator: (value) => value == null
                                  ? 'Please Select a supplier' : null,
                              onChanged: (value) {
                                setState(() {
                                  supplier = value as String?;
                                });
                              },
                              hint: const Text("Select Supplier", style: TextStyle(
                                  fontSize: 11
                              ),),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'SFUIDisplay'
                              ),

                            ),
                          );
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: TextFormField(
                      controller: qtController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      textCapitalization: TextCapitalization.sentences,
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
                      onSaved: (val) => qt = val,
                      onChanged: (val){
                        setState(() {
                          qt = val;
                        });
                      },

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: TextFormField(
                      controller: upController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'SFUIDisplay'
                      ),
                      decoration: InputDecoration(
                          errorStyle: const TextStyle(color: Colors.red),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          suffixText: '(KSH)',
                          labelText: 'Unit Price',
                          labelStyle: const TextStyle(
                              fontSize: 11
                          )
                      ),
                      validator: (val) =>
                      val!.isEmpty  ? 'Field cannot be empty' : null,
                      onSaved: (val) => up = val,
                      onChanged: (val){
                        setState(() {
                          up = val;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: ListTile(
                      title: const Text('Total (KSH)', style: TextStyle(fontSize: 11),),
                      subtitle:  Text(qtController.text == '' || upController.text == '' ? '...':(int.parse(qtController.text)*int.parse(upController.text)).toString()),
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
          ),
        ),
      ),
    );
  }
}
