import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/popups.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/services/localData.dart';
import 'package:vibration/vibration.dart';
import 'package:soshi/constants/widgets.dart';

class BoltScreen extends StatefulWidget {
  @override
  _BoltScreenState createState() => _BoltScreenState();
}

class _BoltScreenState extends State<BoltScreen> {
  int friendsCount;
  int soshiPoints;
  int localSoshiPoints;
  String soshiUsername;
  DatabaseService databaseService = new DatabaseService();

  @override
  Scaffold build(BuildContext context) {
    soshiUsername = LocalDataService.getLocalUsernameForPlatform("Soshi");
    int numFriends = LocalDataService.getFriendsListCount();

// These are used to reset the flag (testing cases)
    // LocalDataService.updateInjectionFlag("Soshi Points", false);

    // databaseService.updateInjectionSwitch(soshiUsername, "Soshi Points", false);

    // LocalDataService.updateInjectionFlag("Profile Pic", false);

    // databaseService.updateInjectionSwitch(soshiUsername, "Profile Pic", false);

    // LocalDataService.updateInjectionFlag("Bio", false);

    // databaseService.updateInjectionSwitch(soshiUsername, "Bio", false);

    bool soshiPointsInjection =
        LocalDataService.getInjectionFlag("Soshi Points");

    if (soshiPointsInjection == false || soshiPointsInjection == null) {
      LocalDataService.updateInjectionFlag("Soshi Points", true);
      databaseService.updateInjectionSwitch(
          soshiUsername, "Soshi Points", true);

      int numFriends = LocalDataService.getFriendsListCount();
      LocalDataService.updateSoshiPoints(numFriends * 8);

      databaseService.updateSoshiPoints(soshiUsername, (numFriends * 8));
    }

    bool profilePicFlagInjection =
        LocalDataService.getInjectionFlag("Profile Pic");
    print(profilePicFlagInjection.toString());

    if (profilePicFlagInjection == false || profilePicFlagInjection == null) {
      if (LocalDataService.getLocalProfilePictureURL() != "null") {
        LocalDataService.updateInjectionFlag("Profile Pic", true);
        databaseService.updateInjectionSwitch(
            soshiUsername, "Profile Pic", true);
        LocalDataService.updateSoshiPoints(10);

        databaseService.updateSoshiPoints(soshiUsername, 10);
      } else {
        LocalDataService.updateInjectionFlag("Profile Pic", false);
        databaseService.updateInjectionSwitch(
            soshiUsername, "Profile Pic", false);
      }
    }

    bool bioFlagInjection = LocalDataService.getInjectionFlag("Bio");
    if (bioFlagInjection == false || bioFlagInjection == null) {
      if (LocalDataService.getBio() != "" ||
          LocalDataService.getBio() == null) {
        LocalDataService.updateInjectionFlag("Bio", true);
        databaseService.updateInjectionSwitch(soshiUsername, "Bio", true);
        LocalDataService.updateSoshiPoints(10);

        databaseService.updateSoshiPoints(soshiUsername, 10);
      } else {
        LocalDataService.updateInjectionFlag("Bio", false);
        databaseService.updateInjectionSwitch(soshiUsername, "Bio", false);
      }
    }

    // For now, just injecting passions flag field
    LocalDataService.updateInjectionFlag("Passions", false);
    databaseService.updateInjectionSwitch(soshiUsername, "Passions", false);

    //       bool passionsFlagInjection =
    //     LocalDataService.getLocalStateForInjectionFlag("Passions");
    // if (passionsFlagInjection == false || passionsFlagInjection == null) {
    //   if (LocalDataService.getPassions() != empty) {
    //     LocalDataService.updateSwitchForInjection(
    //         injection: "Passions", state: true);
    //     databaseService.updateInjectionSwitch(injection: "Passions", state: true);
    //   } else {
    //     LocalDataService.updateSwitchForInjection(
    //         injection: "Passions", state: false);
    //     databaseService.updateInjectionSwitch(injection: "Passions", state: false);
    //   }
    // }

    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    shadowColor: Colors.cyan,
                    elevation: 12,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          width / 10, height / 110, 0, height / 110),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: width / 5,
                            child: Flex(
                                direction: Axis.horizontal,
                                children: <Widget>[
                                  Expanded(
                                      child: Image.asset(
                                    "assets/images/SoshiLogos/soshi_icon_circular.png",
                                  )),
                                ]),
                          ),
                          SizedBox(width: width / 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                LocalDataService.getSoshiPoints().toString() +
                                    " Bolts",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width / 12,
                                    letterSpacing: 1.5),
                              ),
                              // Text(
                              //   "available",
                              //   style: TextStyle(
                              //       fontWeight: FontWeight.bold,
                              //       fontSize: width / 12,
                              //       letterSpacing: 1.5),
                              // ),
                            ],
                          ),
                          // Flexible(
                          //     child: Image.asset(LocalDataService
                          //                 .getLocalProfilePictureURL() ==
                          //             "null"
                          //         ? "assets/images/SoshiLogos/soshi_icon_circular.png"
                          //         : LocalDataService.getLocalProfilePictureURL()))
                        ],
                      ),
                    )),
                Positioned(
                    top: width / 100,
                    right: width / 50,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.info_outline),
                      iconSize: 30,
                      splashRadius: 5,
                    )),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, height / 70, 20, height / 60),
              child: Divider(
                thickness: 1,
                color: Colors.blueGrey,
              ),
            )
          ],
        ),
      ),
    );
  }
}
