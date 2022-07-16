import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/screens/mainapp/profile.dart';
import 'package:soshi/screens/mainapp/profileSettings.dart';
import 'package:soshi/screens/mainapp/resetPassword.dart';
import 'package:soshi/services/auth.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/utilities.dart';

import '../../constants/popups.dart';
import '../../services/nfc.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../services/url.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({Key key}) : super(key: key);

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");
    DatabaseService dbService =
        new DatabaseService(currSoshiUsernameIn: soshiUsername);

    bool isVerified = LocalDataService.getVerifiedStatus();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(CupertinoIcons.back),
        ),

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
        elevation: 0,
        title: Text(
          "Settings",
          style: TextStyle(
            // color: Colors.cyan[200],
            letterSpacing: 1,
            fontSize: width / 18,
            fontWeight: FontWeight.bold,
            //fontStyle: FontStyle.italic
          ),
        ),
        // backgroundColor: Colors.grey[850],
        centerTitle: true,
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
                  radius: height / 17,
                  url: LocalDataService.getLocalProfilePictureURL()),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start,

                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height / 8,
                  ),
                  Text(
                    LocalDataService.getLocalFirstName() +
                        " " +
                        LocalDataService.getLocalLastName(),
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width / 19,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("@" + LocalDataService.getLocalUsername(),
                          style: TextStyle(
                              letterSpacing: 1.5, fontSize: width / 26)),
                      SizedBox(
                        width: 2,
                      ),
                      isVerified == null || isVerified == false
                          ? Container()
                          : Image.asset(
                              "assets/images/Verified.png",
                              scale: width / 20,
                            )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: height / 100),
                    child: Divider(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Scaffold(
                            body: ProfileSettings(
                          soshiUsername:
                              LocalDataService.getLocalUsernameForPlatform(
                                  "Soshi"),
                        ));
                      }));
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(0, height / 100, 0, height / 80),
                      child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Account",
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
                      padding:
                          EdgeInsets.fromLTRB(0, height / 60, 0, height / 80),
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
                      if (Platform.isIOS) {
                        URL.launchURL(
                            "https://apps.apple.com/us/app/soshi/id1595515750?see-all=reviews");
                      } else {
                        // go to google play Soshi rating link
                      }
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(0, height / 60, 0, height / 80),
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
                      padding:
                          EdgeInsets.fromLTRB(0, height / 60, 0, height / 80),
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
                  // ButtonTheme(
                  //   minWidth: 100.0,
                  //   height: 100.0,
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //     style: ElevatedButton.styleFrom(
                  //         elevation: 5,
                  //         shape: RoundedRectangleBorder(
                  //             //to set border radius to button
                  //             borderRadius: BorderRadius.circular(15)),
                  //         padding: EdgeInsets.fromLTRB(
                  //             50, 0, 50, 0) //content padding inside button

                  //         ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Text(
                  //           "Sign out",
                  //           style: TextStyle(
                  //             fontSize: width / 20,
                  //           ),
                  //         ),
                  //         SizedBox(width: 5),
                  //         Icon(
                  //           Icons.exit_to_app,
                  //           color: Colors.red,
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // )
                  Align(
                    alignment: Alignment.bottomRight,
                    //bottom: ,
                    child: TextButton(
                      onPressed: () {
                        AuthService authService = new AuthService();

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(40.0))),
                                // backgroundColor: Colors.blueGrey[900],
                                title: Text(
                                  "Sign Out",
                                  style: TextStyle(
                                    // color: Colors.cyan[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  ("Are you sure you want to sign out?"),
                                  style: TextStyle(
                                    fontSize: 20,
                                    // color: Colors.cyan[700],
                                    // fontWeight: FontWeight.bold
                                  ),
                                ),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              fontSize: 20, color: Colors.red),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          'Yes',
                                          style: TextStyle(
                                              fontSize: 20, color: Colors.blue),
                                        ),
                                        onPressed: () async {
                                          await authService.signOut();
                                          Navigator.pop(context); // close popup
                                          Navigator.pop(
                                              context); // pop to login screen
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            });
                      },
                      child: Text(
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
