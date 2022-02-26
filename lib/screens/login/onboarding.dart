import 'package:flutter/material.dart';

import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/screens/login/authenticate.dart';
import 'package:soshi/screens/login/loginscreen.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Constants.backgroundColor,
        appBar: AppBar(
          // This is creating the app bar with the Soshi Logo and text
          elevation: 40,
          title: Image.asset(
            "assets/images/SoshiLogos/soshi_logo.png",
            height: 40,
            // height: Utilities.getHeight(context) / 22,
          ),
          backgroundColor: Constants.appBarColor,
          centerTitle: true,
        ),
        body: Container(
          // height: 400,
          // color: Constants.backgroundColor,
          // color: Colors.red,
          child: IntroductionScreen(
            pages: [
              PageViewModel(
                // title: "Welcome to Soshi",

                titleWidget: Text(
                  "Welcome to Soshi",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                body: "All your social media in 1 place!",
                image: Center(
                    // child: Image.network("https://domaine.com/image.png", height: 175.0),
                    child: Lottie.network("https://assets10.lottiefiles.com/packages/lf20_dyimsq5i.json", height: 300)),
              ),
              PageViewModel(
                titleWidget: Text(
                  "Easily share with QR code",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                body: "Link to a landing page with all your socials to share with others",
                image: Center(
                  // child: Image.network("https://domaine.com/image.png", height: 175.0),
                  child: Lottie.network("https://assets10.lottiefiles.com/private_files/lf30_le9o8vmt.json", height: 300),
                ),
              ),
              PageViewModel(
                titleWidget: Text(
                  "Grow your network!",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                body: "Find and add friends to keep the conversation going...",
                image: Center(
                  child: Lottie.network("https://assets2.lottiefiles.com/packages/lf20_uge1w2vt.json", height: 300),
                ),
              )
            ],
            showDoneButton: true,

            done: Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
            showNextButton: true,
            next: Icon(Icons.arrow_forward),
            onDone: () {
              // When done button is pressed
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Authenticate(); // Returning the ResetPassword screen
              }));
            },
            // showNextButton: true,

            showSkipButton: true,
            skip: const Text("Skip"),
          ),
        ));
  }
}
