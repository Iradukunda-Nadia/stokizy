import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NewStaff extends StatefulWidget {
  @override
  _NewStaffState createState() => _NewStaffState();
}

class _NewStaffState extends State<NewStaff> {
  String? name;
  String? id;
  String? Item;
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
    final form = formKey.currentState;
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = FirebaseFirestore.instance.collection('issuance');

      await reference.add({
        'date': DateFormat(' yyyy- MM - dd').format(DateTime.now()),
        "name": name,
        'id': id,
        'company': userCompany,
        'assign': assignment,
        'region': region,
        'pfn': pfn,
        "uniform": {},
      });

      FirebaseFirestore.instance.collection('company').doc(userCompany).update({
        'staff' : FieldValue.increment(1),
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
      builder: (BuildContext ctx) {
        // return object of type Dialog
        return AlertDialog(
          content: const Text("Your data has been added"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("close"),
              onPressed: () {
                Navigator.pop(ctx);
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
        automaticallyImplyLeading: true,
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
                          labelText: 'Name',

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
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'SFUIDisplay'
                      ),
                      decoration: InputDecoration(

                          errorStyle: const TextStyle(color: Colors.red),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelText: 'ID Number',

                      ),
                      validator: (val) =>
                      val!.isEmpty  ? 'Field cannot be empty' : null,
                      onSaved: (val) => id = val,
                      onChanged: (val){
                        setState(() {
                          id = val;
                        });
                      },

                    ),
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
                        labelText: 'Assignment',

                      ),
                      validator: (val) =>
                      val!.isEmpty  ? 'Field cannot be empty' : null,
                      onSaved: (val) => assignment = val,
                      onChanged: (val){
                        setState(() {
                          assignment = val;
                        });
                      },

                    ),
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
                        labelText: 'PF NO.',

                      ),
                      validator: (val) =>
                      val!.isEmpty  ? 'Field cannot be empty' : null,
                      onSaved: (val) => pfn = val,
                      onChanged: (val){
                        setState(() {
                          pfn = val;
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
