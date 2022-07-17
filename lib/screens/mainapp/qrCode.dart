import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:soshi/constants/constants.dart';

import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/screens/mainapp/profile.dart';
import 'package:soshi/screens/mainapp/viewProfilePage.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:soshi/services/localData.dart';

import 'package:vibration/vibration.dart';
import 'package:share/share.dart';
import 'package:device_display_brightness/device_display_brightness.dart';

import 'friendScreen.dart';

// /*
// Screen displaying user's QR code and allowing QR scanning
// */
// class QRScreen extends StatefulWidget {
//   @override
//   _QRScreenState createState() => _QRScreenState();
// }

// class _QRScreenState extends State<QRScreen> {
//   CollectionReference usersCollection =
//       FirebaseFirestore.instance.collection("users");

//   void refresh() {
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     // DeviceDisplayBrightness.setBrightness(0.9);
//   }

//   @override
//   Widget build(BuildContext context) {
//     String soshiUsername =
//         LocalDataService.getLocalUsernameForPlatform("Soshi");
//     bool isVerified = LocalDataService.getVerifiedStatus();
//     DatabaseService databaseService =
//         new DatabaseService(currSoshiUsernameIn: soshiUsername);
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//     String friendsCount = LocalDataService.getFriendsListCount().toString();
//     return SingleChildScrollView(
//       child: Container(
//           decoration:
//               BoxDecoration(border: Border.all(color: Colors.transparent)),
//           child: Center(
//             child: Column(children: [
//               SizedBox(height: Utilities.getHeight(context) / 65),
//               Container(
//                 decoration: BoxDecoration(
//                     border: Border.all(color: Colors.transparent)),
//                 width: Utilities.getWidth(context) / 1.05,
//                 child: Card(
//                   elevation: 8.0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                     // side: BorderSide(color: Colors.cyanAccent, width: .3)
//                   ),
//                   // color: Constants.buttonColorDark,
//                   child: Flex(direction: Axis.horizontal,
//                       //mainAxisAlignment: MainAxisAlignment.start,
//                       //crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                               border: Border.all(color: Colors.transparent)),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       border: Border.all(
//                                           color: Colors.transparent)),
//                                   child: ProfilePic(
//                                     url: LocalDataService
//                                         .getLocalProfilePictureURL(),
//                                     radius: 52.5,
//                                   ),
//                                 ),
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                     border:
//                                         Border.all(color: Colors.transparent)),
//                                 child: Padding(
//                                   padding: EdgeInsets.all(5),
//                                   // height / 80, 0, 0, height / 80),
//                                   child: Row(
//                                     children: <Widget>[
//                                       Text(
//                                         "@" +
//                                             LocalDataService
//                                                 .getLocalUsernameForPlatform(
//                                                     "Soshi"),
//                                         softWrap: false,
//                                         overflow: TextOverflow.fade,
//                                         style: TextStyle(
//                                             // color: Colors.grey[500],
//                                             letterSpacing: .5,
//                                             fontSize: width / 35,
//                                             fontWeight: FontWeight.bold,
//                                             fontStyle: FontStyle.italic),
//                                       ),
//                                       SizedBox(width: width / 100),
//                                       isVerified == null || isVerified == false
//                                           ? Container()
//                                           : Image.asset(
//                                               "assets/images/Verified.png",
//                                               scale: width / 20,
//                                             )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Column(
//                             //mainAxisAlignment: MainAxisAlignment.start,
//                             //crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                     border:
//                                         Border.all(color: Colors.transparent)),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     //SizedBox(width: width / 20),
//                                     Row(
//                                       children: [
//                                         Icon(Icons.emoji_people),
//                                         Text(friendsCount + " Friends")
//                                       ],
//                                     ),
//                                     Padding(
//                                       padding: EdgeInsets.all(width / 50),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                         children: [
//                                           //SizedBox(width: width / 40),
//                                           GestureDetector(
//                                             // onTap: () {
//                                             //   Popups.showUserProfilePage(
//                                             //       context,
//                                             //       friendSoshiUsername:
//                                             //           soshiUsername,
//                                             //       refreshScreen: () {});
//                                             // },
//                                             child: Container(
//                                               decoration: BoxDecoration(
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Theme.of(context)
//                                                                   .brightness ==
//                                                               Brightness.light
//                                                           ? Colors.transparent
//                                                           : Colors.transparent,

//                                                       //blurRadius: 2.0,
//                                                       //spreadRadius: 0.0,
//                                                       // offset: Offset(2.0,
//                                                       //     2.0), // shadow direction: bottom right
//                                                     )
//                                                   ],
//                                                   // color: Colors.black12,
//                                                   border: Border.all(
//                                                       color: Theme.of(context)
//                                                                   .brightness ==
//                                                               Brightness.light
//                                                           ? Colors.black
//                                                           : Colors.white,
//                                                       width: width / 500),
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                           Radius.circular(
//                                                               width / 10))),
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.fromLTRB(
//                                                         10.0, 5.0, 10.0, 5.0),
//                                                 child: Row(
//                                                   children: [
//                                                     Icon(Icons.preview_rounded,
//                                                         // color: Colors.grey[300],
//                                                         size: width / 20),
//                                                     SizedBox(
//                                                         width: width / 100),
//                                                     Text("Preview",
//                                                         style: TextStyle(
//                                                             fontSize: Utilities
//                                                                     .getHeight(
//                                                                         context) /
//                                                                 55,
//                                                             // color: Colors.grey[200],

//                                                             fontStyle: FontStyle
//                                                                 .italic)),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               //SizedBox(height: height / 150),
//                               Container(
//                                 height: height / 10,
//                                 width: width / 1.7,
//                                 decoration: BoxDecoration(
//                                     border:
//                                         Border.all(color: Colors.transparent)),
//                                 child: Padding(
//                                   padding: EdgeInsets.all(5),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         LocalDataService.getLocalFirstName(),
//                                         maxLines: 1,
//                                         softWrap: false,
//                                         overflow: TextOverflow.fade,
//                                         style: TextStyle(
//                                           //color: Colors.cyan[300],
//                                           letterSpacing: 2,
//                                           fontSize: width / 15,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         LocalDataService.getLocalLastName(),
//                                         overflow: TextOverflow.fade,
//                                         maxLines: 1,
//                                         softWrap: false,
//                                         style: TextStyle(
//                                           //color: Colors.cyan[300],
//                                           letterSpacing: 2,
//                                           fontSize: width / 15,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: Utilities.getHeight(context) / 100,
//                               ),
//                             ]),
//                       ]),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
//                 child: Divider(
//                     // color: Colors.cyan[300],
//                     ),
//               ),
//               Padding(
//                 padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
//                 child: Container(
//                   alignment: Alignment.center,
//                   height: width / 1.3,
//                   width: width / 1.3,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.cyan[400],

//                         Colors.cyan[500],
//                         Colors.cyan[900],

//                         // Colors.white,
//                       ],
//                       tileMode: TileMode.mirror,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                           // color: Colors.grey[900],
//                           blurRadius: 3.0,
//                           spreadRadius: 0.0,
//                           offset: Offset(3.0, 3.0))
//                     ],
//                   ),
//                   child: Container(
//                     alignment: Alignment.center,
//                     height: width / 1.5,
//                     width: width / 1.5,
//                     decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.all(Radius.circular(10.0))),
//                     child: GestureDetector(
//                       onTap: () {
//                         Clipboard.setData(ClipboardData(
//                           text: "https://soshi.app/" +
//                               LocalDataService.getLocalUsernameForPlatform(
//                                       "Soshi")
//                                   .toString(),
//                         ));
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           content: const Text(
//                             'Copied link to clipboard :)',
//                             textAlign: TextAlign.center,
//                           ),
//                         ));
//                         Analytics.logCopyLinkToClipboard();
//                       },
//                       child: QrImage(
//                         backgroundColor: Colors.white,
//                         errorCorrectionLevel: QrErrorCorrectLevel.H,

//                         embeddedImage: NetworkImage(
//                             LocalDataService.getLocalProfilePictureURL()),
//                         // +
//                         dataModuleStyle: QrDataModuleStyle(
//                           dataModuleShape: QrDataModuleShape.circle,
//                         ),
//                         data: "https://soshi.app/" +
//                             LocalDataService.getLocalUsernameForPlatform(
//                                     "Soshi")
//                                 .toString(),
//                         size: width / 1.35,
//                         padding: EdgeInsets.all(20.0),
//                         // foregroundColor: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                   padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
//                   child: ShareButton(
//                       size: 25,
//                       soshiUsername: LocalDataService.getLocalUsername())),
//               // Padding(
//               //   padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//               //   child: Card(
//               //     shape: RoundedRectangleBorder(
//               //         borderRadius: BorderRadius.all(Radius.circular(15))),
//               //     child: Padding(
//               //       padding: const EdgeInsets.all(5.0),
//               //       child: Row(
//               //         mainAxisAlignment: MainAxisAlignment.center,
//               //         children: [
//               //           Text(
//               //             "Get free bolts",
//               //             style: TextStyle(fontSize: 20),
//               //           ),
//               //           SizedBox(width: 20),
//               //           ClipRRect(
//               //               borderRadius: BorderRadius.all(Radius.circular(30)),
//               //               child: Image.asset(
//               //                 "assets/images/SoshiLogos/soshi_icon.png",
//               //                 height: 40,
//               //               ))
//               //         ],
//               //       ),
//               //     ),
//               //),
//               // ),
//               Constants.makeBlueShadowButton(
//                 "Scan QR Code",
//                 Icons.photo_camera_rounded,
//                 () async {
//                   String QRScanResult = await Utilities.scanQR(mounted);
//                   if (QRScanResult.length > 5) {
//                     // vibrate when QR code is successfully scanned
//                     Vibration.vibrate();
//                     try {
//                       if (QRScanResult.contains("https://soshi.app/group/")) {
//                         String groupId = QRScanResult.split("/").last;
//                         Popups.showJoinGroupPopup(context, groupId);
//                       } else {
//                         String friendSoshiUsername =
//                             QRScanResult.split("/").last;
//                         Map friendData = await databaseService
//                             .getUserFile(friendSoshiUsername);
//                         Friend friend =
//                             databaseService.userDataToFriend(friendData);
//                         bool isFriendAdded =
//                             await LocalDataService.isFriendAdded(
//                                 friendSoshiUsername);

//                         Popups.showUserProfilePopupNew(context,
//                             friendSoshiUsername: friendSoshiUsername,
//                             refreshScreen: () {});
//                         if (!isFriendAdded &&
//                             friendSoshiUsername != soshiUsername) {
//                           List<String> newFriendsList =
//                               await LocalDataService.addFriend(friend: friend);
//                           databaseService.overwriteFriendsList(newFriendsList);
//                         }

//                         // bool friendHasTwoWaySharing = await databaseService.getTwoWaySharing(friendData);
//                         // if (friendHasTwoWaySharing == null || friendHasTwoWaySharing == true) {
//                         //   // if user has two way sharing on, add self to user's friends list
//                         //   databaseService.addFriend(thisSoshiUsername: friendSoshiUsername, friendSoshiUsername: databaseService.currSoshiUsername);
//                         // }
//                         //add friend right here

//                         Analytics.logQRScan(QRScanResult, true, "qrCode.dart");
//                       }
//                     } catch (e) {
//                       Analytics.logQRScan(QRScanResult, false, "qrCode.dart");
//                       print(e);
//                     }
//                   }
//                 },
//               ),
//             ]),
//           )),
//     );
//   }
// }

class NewQRScreen extends StatefulWidget {
  @override
  State<NewQRScreen> createState() => _NewQRScreenState();
}

class _NewQRScreenState extends State<NewQRScreen> {
  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Image.asset(
          "assets/images/SoshiLogos/SoshiBubbleLogo.png",
          // Theme.of(context).brightness == Brightness.light
          //     ? "assets/images/SoshiLogos/soshi_logo_black.png"
          //     : "assets/images/SoshiLogos/soshi_logo.png",

          height: Utilities.getHeight(context) / 18,
        ),
        // backgroundColor: Colors.grey[850],
        centerTitle: true,
      ),
      body: Center(
        child: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //SizedBox(height: height / 20),
                // Image.asset(
                //   "assets/images/SoshiLogos/SoshiBubbleLogo.png",
                //   // Theme.of(context).brightness == Brightness.light
                //   //     ? "assets/images/SoshiLogos/soshi_logo_black.png"
                //   //     : "assets/images/SoshiLogos/soshi_logo.png",

                //   height: Utilities.getHeight(context) / 15,
                // ),
                //SizedBox(height: height / 70),
                Neumorphic(
                  style: NeumorphicStyle(
                      depth: 2,
                      //shadowDarkColor: Colors.cyan,
                      //shadowLightColor: Colors.cyan,
                      shape: NeumorphicShape.concave,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black26,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(25.0),
                      )),
                  child: Container(
                      height: height / 2,
                      width: width / 1.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.ios_share_rounded,
                                      color: Colors.transparent),
                                  onPressed: () => {}),
                              Column(
                                children: [
                                  Text(
                                      LocalDataService.getLocalFirstName() +
                                          " " +
                                          LocalDataService.getLocalLastName(),
                                      style: TextStyle(
                                          fontSize: width / 15,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    "@" + LocalDataService.getLocalUsername(),
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: width / 25,
                                        fontStyle: FontStyle.italic),
                                  )
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.ios_share_rounded),
                                onPressed: () => Share.share(
                                    "https://soshi.app/deeplink/user/${LocalDataService.getLocalUsername()}"),
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
                                        text: "https://soshi.app/" +
                                            LocalDataService
                                                    .getLocalUsernameForPlatform(
                                                        "Soshi")
                                                .toString(),
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
                                      borderRadius: BorderRadius.circular(30.0),
                                      child: QrImage(
                                          size: width / 1.5,
                                          dataModuleStyle: QrDataModuleStyle(
                                              dataModuleShape:
                                                  QrDataModuleShape.circle,
                                              color: Colors.black),
                                          data:
                                              "https://soshi.app/deeplink/user/${LocalDataService.getLocalUsername()}"),
                                    ),
                                  ),
                                  Align(
                                    // bottom: width / 4.5,
                                    // right: width / 20,
                                    child: Container(
                                      height: width / 7,
                                      width: width / 7,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child: ClipOval(
                                        child: Container(
                                          height: width / 10,
                                          width: width / 10,
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: ProfilePic(
                                                radius: width / 10,
                                                url: LocalDataService
                                                    .getLocalProfilePictureURL()),
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
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Image.asset(
                          //     Theme.of(context).brightness == Brightness.light
                          //         ? "assets/images/SoshiLogos/SoshiBubbleLogo.png"
                          //         : "assets/images/SoshiLogos/soshi_logo.png",
                          //     height: Utilities.getHeight(context) / 25,
                          //   ),
                          // ),
                        ],
                      )),
                ),
                //SizedBox(height: height / 11),
                Container(
                  child: NeumorphicButton(
                    onPressed: () async {
                      String username = LocalDataService.getLocalUsername();
                      DatabaseService databaseService =
                          new DatabaseService(currSoshiUsernameIn: username);
                      String QRScanResult = await Utilities.scanQR(mounted);
                      if (QRScanResult.length > 5) {
                        // vibrate when QR code is successfully scanned
                        Vibration.vibrate();
                        try {
                          if (QRScanResult.contains(
                              "https://soshi.app/group/")) {
                            String groupId = QRScanResult.split("/").last;
                            Popups.showJoinGroupPopup(context, groupId);
                          } else {
                            String friendSoshiUsername =
                                QRScanResult.split("/").last;
                            Map friendData = await databaseService
                                .getUserFile(friendSoshiUsername);
                            Friend friend =
                                databaseService.userDataToFriend(friendData);
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
                        height: height / 25,
                        width: width / 2,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Scan",
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ],
                          ),
                        )),
                    style: NeumorphicStyle(
                        shadowLightColor: Colors.cyan,
                        //shadowDarkColor: Colors.cyan,
                        depth: 2,
                        shape: NeumorphicShape.convex,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.black26,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20.0),
                        )),
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
