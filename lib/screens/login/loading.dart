import 'package:flutter/material.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan[300],
      child: Center(
        child: CustomThreeInOut(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}

// class LoadingIconToBeUsed extends StatelessWidget {
//   @override
//   Widget build(BuildContext contxt) {
//     return SpinKitFoldingCube(size: 50);
//   }
// }

class DialogBuilder {
  DialogBuilder(this.context);

  BuildContext context;

  void showLoadingIndicator([String text]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        this.context = c;
        return SpinKitChasingDots(color: Colors.cyan, size: 80);
      },
    );
  }

  void hideOpenDialog() {
    Navigator.pop(context);
  }
}

class OnboardingLoader {
  static void showLoadingIndicator(String text, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return SpinKitChasingDots(color: Colors.cyan, size: 50);
        return Container(
          width: 25,
          height: 25,
          child: CircularProgressIndicator.adaptive(),
          // Image.asset("assets/images/animations/rotatingSoshi.gif",
          //     width: 25, height: 25, fit: BoxFit.scaleDown)
        );
      },
    );
  }

  static killLoader(BuildContext context) {
    Navigator.pop(context);
  }
}


// class LoadingIndicator extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SpinKitCubeGrid(color: Colors.white, size: 50);
//   }
// }
