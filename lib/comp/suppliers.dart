
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/Reports/supReports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Suppliers extends StatefulWidget {
  const Suppliers({super.key});

  @override
  _SuppliersState createState() => _SuppliersState();
}

class _SuppliersState extends State<Suppliers> {
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
  String? userLogo;
  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userCompany = prefs.getString('company');
      userLogo = prefs.getString('logo');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suppliers"),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: const Color(0xffC3B1E1),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('New Supplier'),
        //Widget to display inside Floating Action Button, can be `Text`, `Icon` or any widget.
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => const NewSupplier()));
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                    stream: FirebaseFirestore.instance.collection("suppliers").where('company', isEqualTo: userCompany).snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        // <3> Retrieve `List<DocumentSnapshot>` from snapshot
                        // ignore: missing_return
                        final List<DocumentSnapshot> documents = snapshot.data!.docs;
                        return ListView(
                            children: documents
                            // ignore: missing_return
                                .map((doc) => doc['name'].toLowerCase().contains(searchController.text.toLowerCase()) ?
                                Column(
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(CupertinoPageRoute(
                                            builder: (context) => SupRep(
                                              supplier: doc['name'],
                                            )));
                                      },
                                      title: Text(doc['name'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ): const Offstage())
                                .toList());
                      } else {
                        return const Text('');
                      }

                    })
            ),
          ],
        ),
      ),
    );
  }
}

class NewSupplier extends StatefulWidget {
  const NewSupplier({super.key});

  @override
  _NewSupplierState createState() => _NewSupplierState();
}

class _NewSupplierState extends State<NewSupplier> {
  String? name;
  String? id;
  String? item;
  String? qt;
  String? pfn;
  String? region;
  String? assignment;

  final formKey = GlobalKey<FormState>();
  final itemsKey = GlobalKey<FormState>();
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
  String? userLogo;
  getStringValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userCompany = prefs.getString('company');
      userLogo = prefs.getString('logo');
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
      CollectionReference reference = FirebaseFirestore.instance.collection('suppliers');
      await reference.add({
        "name": name,
        'company': userCompany,

      });

      FirebaseFirestore.instance.collection('company').doc(userCompany).update({
        'suppliers' : FieldValue.increment(1),
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
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: const Text("Your data has been added"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("close"),
              onPressed: () {
                Navigator.of(context).pop();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
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
                        labelText: 'Supplier Name',

                      ),
                      validator: (val) =>
                      val!.isEmpty  ? 'Field cannot be empty' : null,
                      onSaved: (val) => name = val,
                      onChanged: (val){
                        setState(() {
                          name = val;
                        });
                      },

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
                      child : Text(isLoading == true? 'Loading ...':'Submit',
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
