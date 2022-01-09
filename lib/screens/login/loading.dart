import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan[300],
      child: Center(
        child: SpinKitThreeInOut(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}
