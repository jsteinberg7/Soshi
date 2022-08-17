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

import 'friendScreen.dart';

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
        actions: [
          GestureDetector(
            onTap: () {
              // NFCWriter(height, width);
            },
            child: Image.asset(
              "assets/images/misc/NFCLogo.png",
              //height: 50,
              width: 25,
            ),
          ),
          SizedBox(
            width: width / 35,
          )
        ],
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
              return Text("loading QR page");
            }
            return Center(
              child: SafeArea(
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Neumorphic(
                    style: NeumorphicStyle(
                        depth: 2,
                        //shadowDarkColor: Colors.cyan,
                        //shadowLightColor: Colors.cyan,
                        shape: NeumorphicShape.concave,
                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black26,
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
                                    icon: Icon(Icons.ios_share_rounded, color: Colors.transparent),
                                    onPressed: () => {}),
                                Column(
                                  children: [
                                    Text(user.firstName + " " + user.lastName,
                                        style: TextStyle(fontSize: width / 15, fontWeight: FontWeight.bold)),
                                    SoshiUsernameText(user.soshiUsername,
                                        fontSize: width / 22, isVerified: user.verified)
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.ios_share_rounded),
                                  onPressed: () => Share.share("https://soshi.app/deeplink/user/${user.soshiUsername}"),
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
                                          text: "https://soshi.app/" + user.getUsernameGivenPlatform(platform: "Soshi"),
                                          // user.lookupSocial["Soddddshi"].toString()
                                        ));
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                                                dataModuleShape: QrDataModuleShape.circle, color: Colors.black),
                                            data: "https://soshi.app/deeplink/user/${user.soshiUsername}"),
                                      ),
                                    ),
                                    Align(
                                      // bottom: width / 4.5,
                                      // right: width / 20,
                                      child: Container(
                                        height: width / 7,
                                        width: width / 7,
                                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: ClipOval(
                                          child: Container(
                                            height: width / 10,
                                            width: width / 10,
                                            child: Padding(
                                              padding: const EdgeInsets.all(3.0),
                                              child: ProfilePic(radius: width / 10, url: user.photoURL),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text("Share with others to instantly connect.", style: TextStyle(fontSize: width / 27)),
                          ],
                        )),
                  ),
                  //SizedBox(height: height / 11),
                  Container(
                    child: GestureDetector(
                      onTap: () async {
                        String username = LocalDataService.getLocalUsername();
                        DatabaseService databaseService = new DatabaseService(currSoshiUsernameIn: username);
                        String QRScanResult = await Utilities.scanQR(mounted);
                        if (QRScanResult.length > 5) {
                          // vibrate when QR code is successfully scanned
                          Vibration.vibrate();
                          try {
                            if (QRScanResult.contains("https://soshi.app/group/")) {
                              String groupId = QRScanResult.split("/").last;
                              Popups.showJoinGroupPopup(context, groupId);
                            } else {
                              String friendSoshiUsername = QRScanResult.split("/").last;
                              Map friendData = await databaseService.getUserFile(friendSoshiUsername);
                              Friend friend = databaseService.userDataToFriend(friendData);
                              bool isFriendAdded = await LocalDataService.isFriendAdded(friendSoshiUsername);

                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return ViewProfilePage(
                                  friendSoshiUsername: friend.soshiUsername,
                                  refreshScreen: () {},
                                ); // show friend popup when tile is pressed
                              }));

                              if (!isFriendAdded && friendSoshiUsername != username) {
                                // add new friend if necessary
                                List<String> newFriendsList = await LocalDataService.addFriend(friend: friend);
                                databaseService.overwriteFriendsList(newFriendsList);
                              }

                              // bool friendHasTwoWaySharing = await databaseService.getTwoWaySharing(friendData);
                              // if (friendHasTwoWaySharing == null || friendHasTwoWaySharing == true) {
                              //   // if user has two way sharing on, add self to user's friends list
                              //   databaseService.addFriend(thisSoshiUsername: friendSoshiUsername, friendSoshiUsername: databaseService.currSoshiUsername);
                              // }
                              //add friend right here

                              Analytics.logQRScan(QRScanResult, true, "qrCode.dart");
                            }
                          } catch (e) {
                            Analytics.logQRScan(QRScanResult, false, "qrCode.dart");
                            print(e);
                          }
                        }
                      },
                      child: Container(
                          height: height / 13,
                          width: width / 1.8,
                          child: Card(
                            // color: Colors.grey.shade800,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Scan QR Code",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                  )
                ]),
              ),
            );
          }),
    );
  }
}
