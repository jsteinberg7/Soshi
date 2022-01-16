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
  }

  @override
  Widget build(BuildContext context) {
    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");
    DatabaseService databaseService =
        new DatabaseService(soshiUsernameIn: soshiUsername);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Container(
          child: Center(
        child: Column(children: [
          SizedBox(height: Utilities.getHeight(context) / 65),
          Container(
            width: Utilities.getWidth(context) / 1.05,
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.cyanAccent, width: .3)),
              color: Constants.buttonColorDark,
              child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: ProfilePic(
                          url: LocalDataService.getLocalProfilePictureURL(),
                          radius: 50.0,
                        ),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          border: new Border.all(
                            color: Colors.cyanAccent,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    Column(children: [
                      GestureDetector(
                        onTap: () {
                          Popups.showUserProfilePopup(context,
                              soshiUsername: soshiUsername,
                              refreshScreen: () {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey[200], width: width / 500),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(width / 100))),
                          child: Row(
                            children: [
                              Icon(Icons.preview, color: Colors.white),
                              SizedBox(width: width / 100),
                              Text("Preview!",
                                  style: TextStyle(
                                      fontSize:
                                          Utilities.getHeight(context) / 50,
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        LocalDataService.getLocalFirstName() +
                            " " +
                            LocalDataService.getLocalLastName(),
                        style: TextStyle(
                          color: Colors.cyan[300],
                          letterSpacing: 2,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: Utilities.getHeight(context) / 100,
                      ),
                      Text(
                        "@" +
                            LocalDataService.getLocalUsernameForPlatform(
                                "Soshi"),
                        style: TextStyle(
                            color: Colors.grey[500],
                            letterSpacing: 2,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                    ]),
                  ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Divider(
              color: Colors.cyan[300],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[900],
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                        offset: Offset(2.0, 2.0))
                  ],
                  color: Colors.cyan[50],
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(
                    text: "https://soshi.app/#/user/" +
                        LocalDataService.getLocalUsernameForPlatform("Soshi")
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
                  data: "https://soshi.app/#/user/" +
                      LocalDataService.getLocalUsernameForPlatform("Soshi")
                          .toString(),
                  size: width / 1.3,
                  padding: EdgeInsets.all(20.0),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(100, 10, 90, 10),
              child: ShareButton(
                  size: 25,
                  soshiUsername: LocalDataService.getLocalUsername())),
          Padding(
            padding: const EdgeInsets.fromLTRB(70, 0, 70, 0),
            child: ElevatedButton(
              child: Container(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    "Scan QR Code",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan[300],
                      letterSpacing: 2.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Icon(Icons.qr_code_scanner_rounded, color: Colors.cyan)
                ]),
              ),
              style: Constants.ButtonStyleDark,
              onPressed: () async {
                String QRScanResult = await Utilities.scanQR(mounted);
                if (QRScanResult.length > 5) {
                  // vibrate when QR code is successfully scanned
                  Vibration.vibrate();
                  try {
                    Popups.showUserProfilePopup(context,
                        soshiUsername: QRScanResult.split("/").last);
                    Analytics.logSuccessfulQRScan(QRScanResult);
                  } catch (e) {
                    Analytics.logFailedQRScan(QRScanResult);
                    print(e);
                  }
                }
              },
            ),
          ),
        ]),
      )),
    );
  }
}
