import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
// import 'package:nfc_manager/nfc_manager.dart';

import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/screens/mainapp/viewProfilePage.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:soshi/services/database.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:soshi/services/localData.dart';

import 'package:vibration/vibration.dart';
import 'package:share/share.dart';
import '../../services/dynamicLinks.dart';
import 'friendScreen.dart';
import 'package:flutter_share/flutter_share.dart';

class NewQRScreen extends StatefulWidget {
  @override
  State<NewQRScreen> createState() => _NewQRScreenState();
}

class _NewQRScreenState extends State<NewQRScreen> {
  SoshiUser user;

  loadDataEngine() async {
    this.user = await DataEngine.getUserObject(firebaseOverride: false);
    print(DataEngine.serializeUser(this.user));
  }

  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {},
        ),
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       // NFCWriter(height, width);
        //     },
        //     child: Image.asset(
        //       "assets/images/misc/NFCLogo.png",
        //       //height: 50,
        //       width: 25,
        //     ),
        //   ),
        //   SizedBox(
        //     width: width / 35,
        //   )
        // ],
        elevation: 0,
        title: Image.asset(
          "assets/images/SoshiLogos/SoshiBubbleLogo.png",
          height: Utilities.getHeight(context) / 18,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: loadDataEngine(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator.adaptive());
            }

            return Center(
              child: SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Neumorphic(
                        style: NeumorphicStyle(
                            depth: 2,
                            //shadowDarkColor: Colors.cyan,
                            //shadowLightColor: Colors.cyan,
                            shape: NeumorphicShape.concave,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.black26,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(25.0),
                            )),
                        child: Container(
                            height: height / 1.9,
                            width: width / 1.2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.ios_share_rounded,
                                            color: Colors.transparent),
                                        onPressed: () => {}),
                                    Column(
                                      children: [
                                        Container(
                                          width: width / 2,
                                          child: Center(
                                            child: AutoSizeText(
                                              user.firstName +
                                                  " " +
                                                  user.lastName,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: width / 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        SoshiUsernameText(user.soshiUsername,
                                            fontSize: width / 23,
                                            isVerified: user.verified)
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.ios_share_rounded),
                                      onPressed: () async {
                                        FlutterShare.share(
                                            title: "Share your Soshi link!",
                                            linkUrl: user.shortDynamicLink);
                                      },
                                    )
                                  ],
                                ),
                                PhysicalModel(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25.0),
                                  // elevation: 5,
                                  child: Container(
                                    height: width / 1.6,
                                    width: width / 1.6,
                                    child: Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        // Container(
                                        //     height: height,
                                        //     width: width,
                                        //     child: Image.asset(
                                        //       "assets/images/misc/qr_lines.png",
                                        //     )),
                                        GestureDetector(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                text: user
                                                    .shortDynamicLink // user.lookupSocial["Soddddshi"].toString()
                                                ));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: const Text(
                                                'Copied link to clipboard :)',
                                                textAlign: TextAlign.center,
                                              ),
                                            ));
                                            Analytics.logCopyLinkToClipboard();
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            child: QrImage(
                                                size: width / 1.5,
                                                dataModuleStyle:
                                                    QrDataModuleStyle(
                                                        dataModuleShape:
                                                            QrDataModuleShape
                                                                .circle,
                                                        color: Colors.black),
                                                data: user.longDynamicLink),
                                          ),
                                        ),
                                        Align(
                                          // bottom: width / 4.5,
                                          // right: width / 20,
                                          child: Container(
                                            height: width / 10.5,
                                            width: width / 10.5,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle),
                                            child: ClipOval(
                                              child: Container(
                                                height: width / 10,
                                                width: width / 10,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(1.5),
                                                  child: ProfilePic(
                                                      radius: width / 20,
                                                      url: user.photoURL),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text("Share with others to instantly connect.",
                                    style: TextStyle(fontSize: width / 27)),
                              ],
                            )),
                      ),
                      //SizedBox(height: height / 11),
                      Container(
                          child: GestureDetector(
                        onTap: () {
                          CustomAlertDialogDoubleChoiceWithAsset
                              .showCustomAlertDialogDoubleChoiceWithAsset(
                                  "Soshi Portal",
                                  "assets/images/misc/NFCTemp.png", // To be replaced with NFC activating gif
                                  "Activate!",
                                  "Done", () {
                            Navigator.pop(context);
                            print("NFC writer pops up");
                            // Call NFC writer and write user.shortDynamicLink
                          }, () {
                            Navigator.pop(context);
                          }, context, height, width);
                        },
                        child: Container(
                            height: height / 15,
                            width: width / 2.1,
                            child: Card(
                              // color: Colors.grey.shade800,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Activate Soshi Portal",
                                      style: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          fontSize: width / 30),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      CupertinoIcons.info_circle,
                                      size: width / 20,
                                    )
                                  ],
                                ),
                              ),
                            )),
                      )),

                      Container(
                        child: GestureDetector(
                          onTap: () async {
                            String username = user.soshiUsername;
                            DatabaseService databaseService =
                                new DatabaseService(
                                    currSoshiUsernameIn: username);
                            String QRScanResult =
                                await Utilities.scanQR(mounted);
                            if (QRScanResult.length > 5) {
                              // vibrate when QR code is successfully scanned
                              Vibration.vibrate();
                              try {
                                if (QRScanResult.contains(
                                    "https://soshi.app/group/")) {
                                  String groupId = QRScanResult.split("/").last;
                                  Popups.showJoinGroupPopup(context, groupId);
                                } else if (QRScanResult.contains(
                                    "https://soshi.app/")) {
                                  // This is to account for if a version 3.0 scans a version 2.5
                                  String friendSoshiUsername =
                                      QRScanResult.split("/").last;

                                  Map friendData = await databaseService
                                      .getUserFile(friendSoshiUsername);
                                  Friend friend = databaseService
                                      .userDataToFriend(friendData);
                                  bool isFriendAdded =
                                      await LocalDataService.isFriendAdded(
                                          friendSoshiUsername);

                                  if (!isFriendAdded &&
                                      friendSoshiUsername != username) {
                                    // add new friend if necessary
                                    List<String> newFriendsList =
                                        await LocalDataService.addFriend(
                                            friend: friend);
                                    databaseService
                                        .overwriteFriendsList(newFriendsList);
                                  }

                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ViewProfilePage(
                                      friendSoshiUsername: friend.soshiUsername,
                                      refreshScreen: () {},
                                    );
                                  }));
                                } else {
                                  String friendSoshiUsername =
                                      DynamicLinkService
                                          .extractUsernameFromDynamicLink(
                                              QRScanResult);
                                  Map friendData = await databaseService
                                      .getUserFile(friendSoshiUsername);
                                  Friend friend = databaseService
                                      .userDataToFriend(friendData);
                                  bool isFriendAdded =
                                      await LocalDataService.isFriendAdded(
                                          friendSoshiUsername);

                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ViewProfilePage(
                                      friendSoshiUsername: friend.soshiUsername,
                                      refreshScreen: () {},
                                    ); // show friend popup when tile is pressed
                                  }));

                                  if (!isFriendAdded &&
                                      friendSoshiUsername != username) {
                                    // add new friend if necessary
                                    List<String> newFriendsList =
                                        await LocalDataService.addFriend(
                                            friend: friend);
                                    databaseService
                                        .overwriteFriendsList(newFriendsList);
                                  }

                                  // bool friendHasTwoWaySharing = await databaseService.getTwoWaySharing(friendData);
                                  // if (friendHasTwoWaySharing == null || friendHasTwoWaySharing == true) {
                                  //   // if user has two way sharing on, add self to user's friends list
                                  //   databaseService.addFriend(thisSoshiUsername: friendSoshiUsername, friendSoshiUsername: databaseService.currSoshiUsername);
                                  // }
                                  //add friend right here

                                  Analytics.logQRScan(
                                      QRScanResult, true, "qrCode.dart");
                                }
                              } catch (e) {
                                Analytics.logQRScan(
                                    QRScanResult, false, "qrCode.dart");
                                print(e);
                              }
                            }
                          },
                          child: Container(
                              height: height / 13,
                              width: width / 1.8,
                              child: Card(
                                // color: Colors.grey.shade800,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Scan Code",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(Icons.camera_alt_rounded)
                                    ],
                                  ),
                                ),
                              )),

                          // style: NeumorphicStyle(
                          //     // shadowLightColor: Colors.cyan,
                          //     // shadowDarkColor: Colors.cyan,
                          //     depth: 2,
                          //     shape: NeumorphicShape.convex,
                          //     color: Theme.of(context).brightness == Brightness.light
                          //         ? Colors.white
                          //         : Colors.black26,
                          //     boxShape: NeumorphicBoxShape.roundRect(
                          //       BorderRadius.circular(20.0),
                          //     )),
                        ),
                      ),
                      // Text(
                      //   user.longDynamicLink,
                      //   style: TextStyle(fontSize: 10),
                      // ),

                      // Text(user.shortDynamicLink),
                      // Text(DynamicLinkService.extractUsernameFromDynamicLink(
                      //     user.longDynamicLink))
                      // Container(
                      //     child: GestureDetector(
                      //   onTap: () {
                      //     CustomAlertDialogDoubleChoiceWithAsset
                      //         .showCustomAlertDialogDoubleChoiceWithAsset(
                      //             "Soshi Portal",
                      //             "assets/images/onboarding/mockup3.png",
                      //             "Activate!",
                      //             "Done",
                      //             () {}, () {
                      //       Navigator.pop(context);
                      //     }, context, height, width);
                      //   },
                      //   child: Container(
                      //       height: height / 15,
                      //       width: width / 2.1,
                      //       child: Card(
                      //         // color: Colors.grey.shade800,
                      //         shape: RoundedRectangleBorder(
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(10))),
                      //         child: Center(
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               Text(
                      //                 "Activate Soshi Portal",
                      //                 style: TextStyle(
                      //                     fontWeight: FontWeight.bold,
                      //                     fontSize: width / 33),
                      //               ),
                      //               SizedBox(width: 5),
                      //               Icon(
                      //                 CupertinoIcons.info_circle,
                      //                 size: width / 20,
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //       )),
                      // )),
                    ]),
              ),
            );
          }),
    );
  }
}
