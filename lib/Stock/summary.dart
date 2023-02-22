import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';

class Sum extends StatefulWidget {
  final Map<String,dynamic>? uniform ;
  final Map<String,dynamic>? assets;
  String? name;
  String? id;
  String? docID;
  String? form;
  String? region;
  String? assign;
  String? reason;
  String? dateCleared;
  String? pfn;
  Sum({
    this.uniform,
    this.name,
    this.assets,
    this.id,
    this.docID,
    this.form,
    this.region,
    this.assign,
    this.dateCleared,
    this.reason,
    this.pfn,
  });

  @override
  _SumState createState() => _SumState();
}

class _SumState extends State<Sum> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Summary"),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: const Color(0xffC3B1E1),
      ),
      body:  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection(widget.form!).where('id',isEqualTo: widget.id)
                        .orderBy('timestamp', descending: true).snapshots(),
                    builder: (context,AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        final List<DocumentSnapshot> documents = snapshot.data.docs;
                        return documents.isNotEmpty?ListView(
                            children: documents
                                .map((doc) => Card(
                              child:
                              ListTile(
                                onTap: () {
                                  Navigator.of(context).push(CupertinoPageRoute(
                                      builder: (context) => SummaryDetail(
                                        name: doc['name'].toUpperCase(),
                                        id: doc['id'],
                                        date: doc['date'] ,
                                        docID: doc.id,
                                        userID: widget.docID ?? '',
                                        form: widget.form ?? '',
                                        sign: doc['sig'],
                                        assign: widget.assign ?? '',
                                        region: widget.region ?? '',
                                        dateCleared: widget.dateCleared ?? '',
                                        reason: widget.reason ?? '',
                                        pfn: widget.pfn ?? '',
                                      )));
                                },
                                title: Text(doc['dt'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                ),
                            ))
                                .toList()):
                        const Center(child: Text('Nothing To report'));
                      } else {
                        return const Center(child: Text('Nothing To report'));
                      }

                    })
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryDetail extends StatefulWidget {
  final Map<String,dynamic>? uniform ;
  final Map<String,dynamic>? assets;
  String? name;
  String? id;
  String? docID;
  String? userID;
  String? date;
  String? sign;
  String? form;
  String? region;
  String? assign;
  String? reason;
  String? dateCleared;
  String? pfn;

  SummaryDetail({
    this.uniform,
    this.name,
    this.assets,
    this.id,
    this.docID,
    this.userID,
    this.date,
    this.sign,
    this.form,
    this.region,
    this.assign,
    this.dateCleared,
    this.reason,
    this.pfn,
  });

  @override
  _SummaryDetailState createState() => _SummaryDetailState();
}

class _SummaryDetailState extends State<SummaryDetail> {
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getStringValue();
  }

  final _renderObjectKey = GlobalKey<ScaffoldState>();
  Future<Uint8List> _getWidgetImage() async {
    try {
      RenderRepaintBoundary boundary =
      _renderObjectKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      debugPrint(bs64.length.toString());
      return pngBytes;
    } catch (exception) {
      throw exception;
    }
  }
  Future<void> _printScreen() async {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pdf.Document();
      final image = pdf.MemoryImage(
        base64Decode(widget.sign ?? ''),
      );
      final logoImage = pdf.MemoryImage(
        base64Decode('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'),
      );
      final img = await WidgetWraper.fromKey(
        key: _renderObjectKey,
        pixelRatio: 2.0,
      );
      doc.addPage(pdf.Page(
          pageFormat: format,
          build: (pdf.Context context) {
            return pdf.Column(
              children: [
                pdf.Center(
                  child: pdf.Image(logoImage),
                ),
                pdf.SizedBox(height: 5),
                pdf.Expanded(
                  child: pdf.Image(img),
                ),
                pdf.Row(
                  children: [
                    pdf.Text('Signature: '),
                    pdf.SizedBox(width: 20),
                    pdf.Image(image),
                  ]
                ),
              ]
            );
          }));

      return doc.save();
    });
}


  @override
  Widget build(BuildContext context) {
    final decodedBytes = base64Decode(widget.sign ?? '');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){_printScreen();},
        child: const Icon(Icons.print_rounded,),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Image.asset(
                  'assets/peltLogo.png',
                  fit: BoxFit.contain,
                  height: 60.0,
                  width: 60.0,
                ),
              ),
            ),
            RepaintBoundary(
              key: _renderObjectKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Name: ${widget.name}'
                    ,style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold
                  ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        'ID: ${widget.id}'
                        ,style: const TextStyle(
                          fontSize: 12.0,
                          color:Colors.blueGrey,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w400
                      ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const VerticalDivider(),
                      Text(
                        'PF.NO.: ${widget.pfn}'
                        ,style: const TextStyle(
                          fontSize: 12.0,
                          color:Colors.blueGrey,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w400
                      ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  widget.form != 'cleared' ? const Offstage():Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Assignment: ${widget.assign}'
                          ,style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400
                        ),
                        ),
                        Text(
                          'Reason For discharge: ${widget.reason}'
                          ,style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400
                        ),
                        ),
                        Text(
                          'Clearance date: ${widget.dateCleared}'
                          ,style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400
                        ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:MainAxisSize.min,
                      children: <Widget>[

                        const SizedBox(
                          height: 20,
                        ),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance.collection(widget.form ?? '').doc(widget.docID)
                                .snapshots(),
                            builder: (context,AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                final Map<String,dynamic> items = Map<String, dynamic>.from(snapshot.data["Items"]) ;
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
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Text(
                                                    '$key',
                                                    style: const TextStyle(color: Colors.black, fontSize: 12.0,),
                                                  )
                                                ],
                                              ),
                                              Text(
                                                "${items[key].toString()}",
                                                style: const TextStyle(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5.0,
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
                        const SizedBox(
                          height: 20,
                        ),

                        widget.form != 'cleared' ? const Offstage(): StreamBuilder(
                            stream: FirebaseFirestore.instance.collection("issuance").doc(widget.userID).snapshots(),
                            builder: (context,AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                final Map<String,dynamic> items = Map<String, dynamic>.from(snapshot.data["uniform"]) ;
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Uncleared Items'),
                                    Flexible(
                                      child: ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: items.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          String key = items.keys.elementAt(index);
                                          return Column(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  items[key] <= 0? const Offstage(): Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: <Widget>[
                                                              const SizedBox(
                                                                width: 5.0,
                                                              ),
                                                              Text(
                                                                '$key',
                                                                style: const TextStyle(color: Colors.black, fontSize: 12.0,),
                                                              )
                                                            ],
                                                          ),
                                                          Text(
                                                            "${items[key].toString()}",
                                                            style: const TextStyle(
                                                                fontSize: 10.0,
                                                                fontWeight: FontWeight.w700),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      const Divider(
                                                        height: 2.0,
                                                      ),
                                                    ],
                                                  ),

                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const Text('');
                              }
                            }),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            widget.sign == null ? const Offstage() :Row(
              children: [
                const Text('SIGNATURE:'),
                const SizedBox(
                  width: 20,
                ),
                Container(
                    child: Image.memory(
                      base64Decode(widget.sign ?? ''),
                    )
                ),
              ],
            ),
          ],
        ),


      ),
    );
  }
}
