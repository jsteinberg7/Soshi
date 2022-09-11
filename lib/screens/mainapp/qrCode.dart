import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
// import 'package:nfc_manager/nfc_manager.dart';

import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/screens/mainapp/viewProfilePage.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:vibration/vibration.dart';
import 'package:share/share.dart';

class NewQRScreen extends StatefulWidget {
  @override
  State<NewQRScreen> createState() => _NewQRScreenState();
}

class _NewQRScreenState extends State<NewQRScreen> {
  SoshiUser user;

  loadDataEngine() async {
    // this.user = await DataEngine.getUserObject(firebaseOverride: false);
    this.user = DataEngine.globalUser;
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
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Neumorphic(
                    style: NeumorphicStyle(
                        depth: 2,
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
                                    Container(
                                      width: width / 2,
                                      child: Center(
                                        child: AutoSizeText(
                                          user.firstName + " " + user.lastName,
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
                                        fontSize: width / 23, isVerified: user.verified)
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.ios_share_rounded),
                                  onPressed: () => Share.share(user.dynamicLink),
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
                                            data: user.dynamicLink),
                                      ),
                                    ),
                                    Align(
                                      // bottom: width / 4.5,
                                      // right: width / 20,
                                      child: Container(
                                        height: width / 10.5,
                                        width: width / 10.5,
                                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: ClipOval(
                                          child: Container(
                                            height: width / 10,
                                            width: width / 10,
                                            child: Padding(
                                              padding: const EdgeInsets.all(1.5),
                                              child: ProfilePic(radius: width / 20, url: user.photoURL),
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

                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return ViewProfilePage(
                                  friendUsername: friendSoshiUsername,
                                  refreshScreen: () {},
                                ); // show friend popup when tile is pressed
                              }));

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
                                    "Scan Code",
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
