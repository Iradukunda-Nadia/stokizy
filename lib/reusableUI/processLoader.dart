import 'package:flutter/material.dart';

class ProcessLoader extends StatelessWidget {
  const ProcessLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}

