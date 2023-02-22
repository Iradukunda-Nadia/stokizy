import 'package:flutter/material.dart';

class Dialogs{
  Future<void> showSignatureWarning(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext cxt) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: const Text('You need to add a signature before you can save the form'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(cxt).pop();
              },
            ),
          ],
        );
      },
    );
  }
}