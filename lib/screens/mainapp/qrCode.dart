import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soshi/constants/constants.dart';

import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:soshi/services/localData.dart';

import 'package:vibration/vibration.dart';
import 'package:share/share.dart';
import 'package:device_display_brightness/device_display_brightness.dart';

/*
Screen displaying user's QR code and allowing QR scanning
*/
class QRScreen extends StatefulWidget {
  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    DeviceDisplayBrightness.setBrightness(0.9);
  }

  @override
  Widget build(BuildContext context) {
    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");
    DatabaseService databaseService =
        new DatabaseService(currSoshiUsernameIn: soshiUsername);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String friendsCount = LocalDataService.getFriendsListCount().toString();
    return SingleChildScrollView(
      child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.transparent)),
          child: Center(
            child: Column(children: [
              SizedBox(height: Utilities.getHeight(context) / 65),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent)),
                width: Utilities.getWidth(context) / 1.05,
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    // side: BorderSide(color: Colors.cyanAccent, width: .3)
                  ),
                  // color: Constants.buttonColorDark,
                  child: Flex(direction: Axis.horizontal,
                      //mainAxisAlignment: MainAxisAlignment.start,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.transparent)),
                                  child: ProfilePic(
                                    url: LocalDataService
                                        .getLocalProfilePictureURL(),
                                    radius: 52.5,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.transparent)),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  // height / 80, 0, 0, height / 80),
                                  child: Text(
                                    "@" +
                                        LocalDataService
                                            .getLocalUsernameForPlatform(
                                                "Soshi"),
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        // color: Colors.grey[500],
                                        letterSpacing: .5,
                                        fontSize: width / 35,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.transparent)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //SizedBox(width: width / 20),
                                    Row(
                                      children: [
                                        Icon(Icons.emoji_people),
                                        Text(friendsCount + " Friends")
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(width / 50),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          //SizedBox(width: width / 40),
                                          GestureDetector(
                                            onTap: () {
                                              Popups.showUserProfilePopupNew(
                                                  context,
                                                  friendSoshiUsername:
                                                      soshiUsername,
                                                  refreshScreen: () {});
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    // BoxShadow(
                                                    //   // color: Colors.black26,
                                                    //   blurRadius: 2.0,
                                                    //   spreadRadius: 0.0,
                                                    //   offset: Offset(2.0,
                                                    //       2.0), // shadow direction: bottom right
                                                    // )
                                                  ],
                                                  // color: Colors.black12,
                                                  border: Border.all(
                                                      // color: Colors.grey[700],
                                                      width: width / 500),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              width / 10))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10.0, 5.0, 10.0, 5.0),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.preview_rounded,
                                                        // color: Colors.grey[300],
                                                        size: width / 20),
                                                    SizedBox(
                                                        width: width / 100),
                                                    Text("Preview",
                                                        style: TextStyle(
                                                            fontSize: Utilities
                                                                    .getHeight(
                                                                        context) /
                                                                55,
                                                            // color: Colors.grey[200],

                                                            fontStyle: FontStyle
                                                                .italic)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //SizedBox(height: height / 150),
                              Container(
                                height: height / 10,
                                width: width / 1.7,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.transparent)),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        LocalDataService.getLocalFirstName(),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                          //color: Colors.cyan[300],
                                          letterSpacing: 2,
                                          fontSize: width / 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        LocalDataService.getLocalLastName(),
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: TextStyle(
                                          //color: Colors.cyan[300],
                                          letterSpacing: 2,
                                          fontSize: width / 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Utilities.getHeight(context) / 100,
                              ),
                            ]),
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Divider(
                    // color: Colors.cyan[300],
                    ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: Container(
                  alignment: Alignment.center,
                  height: width / 1.3,
                  width: width / 1.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan[400],

                        Colors.cyan[500],
                        Colors.cyan[900],

                        // Colors.white,
                      ],
                      tileMode: TileMode.mirror,
                    ),
                    boxShadow: [
                      BoxShadow(
                          // color: Colors.grey[900],
                          blurRadius: 3.0,
                          spreadRadius: 0.0,
                          offset: Offset(3.0, 3.0))
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    height: width / 1.5,
                    width: width / 1.5,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                          text: "https://soshi.app/" +
                              LocalDataService.getLocalUsernameForPlatform(
                                      "Soshi")
                                  .toString(),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                            'Copied link to clipboard :)',
                            textAlign: TextAlign.center,
                          ),
                        ));
                        Analytics.logCopyLinkToClipboard();
                      },
                      child: QrImage(
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        // +
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                        ),
                        data: "https://soshi.app/" +
                            LocalDataService.getLocalUsernameForPlatform(
                                    "Soshi")
                                .toString(),
                        size: width / 1.35,
                        padding: EdgeInsets.all(20.0),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(100, 10, 90, 10),
                  child: ShareButton(
                      size: 25,
                      soshiUsername: LocalDataService.getLocalUsername())),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 15,
                    shadowColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)))),
                child: Container(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      "Scan QR Code",
                      style: TextStyle(
                        fontSize: width / 25,
                        fontWeight: FontWeight.bold,
                        //color: Colors.cyan[300],
                        letterSpacing: 2.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                    ),
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      // color: Colors.cyan
                    )
                  ]),
                ),
                // style: Constants.ButtonStyleDark,
                onPressed: () async {
                  String QRScanResult = await Utilities.scanQR(mounted);
                  if (QRScanResult.length > 5) {
                    // vibrate when QR code is successfully scanned
                    Vibration.vibrate();
                    try {
                      Popups.showUserProfilePopupNew(context,
                          friendSoshiUsername: QRScanResult.split("/").last,
                          refreshScreen: () {});
                      Analytics.logQRScan(QRScanResult, true, "qrCode.dart");
                    } catch (e) {
                      Analytics.logQRScan(QRScanResult, false, "qrCode.dart");
                      print(e);
                    }
                  }
                },
              ),
            ]),
          )),
    );
  }
}
