import 'package:flutter/material.dart';

import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/screens/login/authenticate.dart';
import 'package:soshi/screens/login/loginscreen.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();

  Function refreshApp;

  Onboarding({@required Function refresh}) {
    this.refreshApp = refresh;
  }
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        // appBar: AppBar(
        //   // This is creating the app bar with the Soshi Logo and text
        //   elevation: 40,
        //   title: Image.asset(
        //     "assets/images/SoshiLogos/soshi_logo.png",
        //     height: 40,
        //     // height: Utilities.getHeight(context) / 22,
        //   ),
        //   backgroundColor: Constants.appBarColor,
        //   centerTitle: true,
        // ),
        body: Container(
      // height: 400,
      // color: Constants.backgroundColor,
      // color: Colors.red,
      child: IntroductionScreen(
        pages: [
          PageViewModel(
            // title: "Welcome to Soshi",

            titleWidget: Text(
              "Welcome to Soshi!",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            body: "All your social media in 1 place!",
            image: Center(
                // child: Image.network("https://domaine.com/image.png", height: 175.0),
                child: Lottie.network(
                    "https://assets4.lottiefiles.com/packages/lf20_hwcplx4x.json",
                    height: 300)),
          ),
          PageViewModel(
            titleWidget: Text(
              "Easily share with QR code",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            body: "All your socials in a single QR code",
            image: Center(
              // child: Image.network("https://domaine.com/image.png", height: 175.0),
              child: Lottie.network(
                  "https://assets4.lottiefiles.com/packages/lf20_ksovfkm5.json",
                  height: 300),
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "Make new friends!",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            body: "Meet new people and keep the conversation going online...",
            image: Center(
              child: Lottie.network(
                  "https://assets2.lottiefiles.com/packages/lf20_uge1w2vt.json",
                  height: 300),
            ),
          )
        ],
        showDoneButton: true,

        done: Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        showNextButton: true,
        next: Icon(Icons.arrow_forward),
        onDone: () {
          // When done button is pressed
          widget.refreshApp();
        },
        // showNextButton: true,

        showSkipButton: true,
        skip: const Text("Skip"),
      ),
    ));
  }
}
