//import 'dart:html';
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:soshi/screens/login/newIntroFlowSri.dart';
import 'package:soshi/screens/mainapp/profileSettings.dart';
import 'package:soshi/screens/mainapp/resetPassword.dart';
import 'package:soshi/services/auth.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/utilities.dart';

import '../../services/nfc.dart';
import '../../services/url.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({Key key}) : super(key: key);

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    print(DataEngine.globalUser);

    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 0,
        title: Container(
          width: width / 2,
          child: Text(
            "Settings",
            style: TextStyle(
              // color: Colors.cyan[200],
              letterSpacing: 1,
              fontSize: width / 18,
              fontWeight: FontWeight.bold,
              //fontStyle: FontStyle.italic
            ),
          ),
        ),
        automaticallyImplyLeading: false,

        actions: [
          Padding(
            padding: EdgeInsets.only(right: width / 150),
            child: TextButton(
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent)),
              child: Text(
                "Done",
                style: TextStyle(color: Colors.blue, fontSize: width / 23),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
        elevation: .5,

        // backgroundColor: Colors.grey[850],
        centerTitle: false,
      ),
      body: Scaffold(
          body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(width / 25, height / 60, width / 25, 0),
          child: Stack(children: [
            Positioned(
              //top: 20,
              //left: 30,
              child: ProfilePic(
                  radius: height / 17, url: DataEngine.globalUser.photoURL),
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: height / 8,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          DataEngine.globalUser.firstName +
                              " " +
                              DataEngine.globalUser.lastName,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: width / 19,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: 5),
                      SoshiUsernameText(DataEngine.globalUser.soshiUsername,
                          fontSize: width / 26,
                          isVerified: DataEngine.globalUser.verified),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, height / 100, 0, 0),
                        child: Divider(
                            indent: 0,
                            endIndent: 0,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white),
                      ),
                      // GestureDetector(
                      //   behavior: HitTestBehavior.opaque,
                      //   onTap: () {
                      //     Navigator.push(context,
                      //         MaterialPageRoute(builder: (context) {
                      //       return Scaffold(body: ProfileSettings());
                      //     }));
                      //   },
                      //   child: Padding(
                      //     padding: EdgeInsets.fromLTRB(
                      //         0, height / 100, 0, height / 80),
                      //     child: Row(
                      //         //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //         children: [
                      //           Text(
                      //             "Account",
                      //             style: TextStyle(fontSize: width / 23),
                      //           ),
                      //           Spacer(),
                      //           Icon(CupertinoIcons.forward)
                      //         ]),
                      //   ),
                      // ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          print("NFC writer pops up");
                          Navigator.of(context).pop();

                          if (Platform.isIOS) {
                            showModalBottomSheet(
                                constraints: BoxConstraints(
                                    minWidth: width / 1.1,
                                    maxWidth: width / 1.1),
                                backgroundColor: Colors.green,
                                context: context,
                                builder: (BuildContext context) {
                                  return NFCWriterIOS(height, width,
                                      "https://soshi.app/nfc_portal/${DataEngine.globalUser.soshiUsername}");
                                });

                            // bool isAvailable =
                            //     await NfcManager.instance.isAvailable();

                            // NfcManager.instance.startSession(
                            //   onDiscovered: (NfcTag tag) async {
                            //     // Do something with an NfcTag instance.
                            //   },
                            // );

                            // print("Hellooo");
                            // final completer = Completer<void>();
                            // NfcManager.instance.startSession(
                            //   onDiscovered: (tag) async {
                            //     final ndef = Ndef.from(tag);
                            //     final formattable = NdefFormatable.from(tag);
                            //     final message = NdefMessage([
                            //       NdefRecord.createText(
                            //           "https://soshi.app/nfc_portal/${DataEngine.globalUser.soshiUsername}")
                            //     ]);
                            //     if (ndef != null) {
                            //       await ndef.write(message);
                            //     } else if (formattable != null) {
                            //       await formattable.format(message);
                            //     }
                            //     await NfcManager.instance.stopSession();
                            //     completer.complete();
                            //   },
                            //   onError: (error) async =>
                            //       completer.completeError(error),
                            // );
                          } else {
                            return showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                // constraints: BoxConstraints(
                                //     minWidth: , maxWidth: 500),
                                backgroundColor: Colors.white,
                                context: context,
                                builder: (BuildContext context) {
                                  // return Container(
                                  //   color: Colors.green,
                                  //   child: Text("Hello"),
                                  // );
                                  return NFCWriterAndroid(height, width,
                                      "https://soshi.app/nfc_portal/${DataEngine.globalUser.soshiUsername}");
                                });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, height / 60, 0, height / 80),
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Activate Soshi Portal",
                                  style: TextStyle(fontSize: width / 23),
                                ),
                                Spacer(),
                                Icon(CupertinoIcons.forward)
                              ]),
                        ),
                      ),

                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          URL.launchURL("sms:" + "5713351885");
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, height / 60, 0, height / 80),
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Send Feedback",
                                  style: TextStyle(fontSize: width / 23),
                                ),
                                Spacer(),
                                Icon(CupertinoIcons.forward)
                              ]),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final InAppReview inAppReview = InAppReview.instance;

                          inAppReview.openStoreListing(
                              appStoreId: '1595515750');
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, height / 60, 0, height / 80),
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Rate Soshi",
                                  style: TextStyle(fontSize: width / 23),
                                ),
                                Spacer(),
                                Icon(CupertinoIcons.forward)
                              ]),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Scaffold(body: ResetPassword());
                          }));
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, height / 60, 0, height / 80),
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Reset Password",
                                  style: TextStyle(fontSize: width / 23),
                                ),
                                Spacer(),
                                Icon(CupertinoIcons.forward)
                              ]),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          URL.launchURL(
                              "https://app.termly.io/document/terms-of-use-for-saas/8b7e6781-e03e-45a3-88e9-d0a8de547d12");
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, height / 60, 0, height / 80),
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Terms and Conditions",
                                  style: TextStyle(fontSize: width / 23),
                                ),
                                Spacer(),
                                Icon(CupertinoIcons.forward)
                              ]),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    //bottom: ,
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        AuthService authService = new AuthService();

                        CustomAlertDialogDoubleChoice
                            .showCustomAlertDialogDoubleChoice(
                                "Sign Out",
                                "Are you sure you want to sign out?",
                                "Yes",
                                "No", () async {
                          await DataEngine.forceClear();
                          await authService.signOut();
                          Navigator.pop(context); // close popup
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => NewIntroFlow())));
                        }, () {
                          Navigator.pop(context);
                        }, context, height, width);

                        // CustomAlertDialogDoubleChoice
                        //     .showCustomAlertDialogDoubleChoice(
                        //         "Sign out",
                        //         "Are you sure you want to sign out?",
                        //         "",
                        //         "Yes",
                        //         "No",
                        //         () async {
                        //   await DataEngine.forceClear();
                        //   await authService.signOut();
                        //   Navigator.pop(context); // close popup
                        //   Navigator.pushReplacement(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: ((context) => NewIntroFlow())));
                        // }, () {
                        //   Navigator.pop(context);
                        // }, context, height, width);
                      },
                      label: Text(
                        "Sign out",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                ]),
          ]),
        ),
      )),
    );
  }
}
