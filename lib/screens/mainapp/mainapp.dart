import 'dart:async';
import 'dart:convert';

import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/screens/mainapp/friendsGroupsWrapper.dart';
import 'package:soshi/screens/mainapp/profile.dart';
import 'package:soshi/screens/mainapp/qrCode.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/dynamicLinks.dart';
import 'package:soshi/services/localData.dart';
import '../../constants/popups.dart';
import '../../constants/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'generalSettings.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  Timer _timerLink;
  List<Widget> screens;
  @override
  void initState() {
    super.initState();
    screens = [
      FractionallySizedBox(
          widthFactor: 1 / pageController.viewportFraction,
          child: NewQRScreen()),
      FractionallySizedBox(
          widthFactor: 1 / pageController.viewportFraction, child: Profile()),
      FractionallySizedBox(
          widthFactor: 1 / pageController.viewportFraction,
          child: FriendsGroupsWrapper()),
    ]; // list of screens (change through indexing)
    WidgetsBinding.instance.addObserver(this);
    print(">> calling from init");
    DynamicLinkService.retrieveDynamicLink(context);
    // Check availability

// Start Session

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var link = AsciiCodec()
            .decode(Ndef.from(tag).cachedMessage.records.last.payload);
        String username = link.toString().split("/").last;

        try {
          await Popups.showUserProfilePopupNew(context,
              friendSoshiUsername: username, refreshScreen: () {});
        } catch (e) {
          print(e);
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print(">> calling from lifecycle change");
      DynamicLinkService.retrieveDynamicLink(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  int currScreen = 1;

  PageController pageController =
      new PageController(initialPage: 1, viewportFraction: 1.1);

  @override
  Widget build(BuildContext context) {
    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");
    DatabaseService databaseService =
        new DatabaseService(currSoshiUsernameIn: soshiUsername);

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color.fromARGB(255, 32, 199, 221),
      //   //Floating action button on Scaffold
      //   onPressed: () async {
      //     //code to execute on button press
      //     {
      //       String QRScanResult = await Utilities.scanQR(mounted);
      //       if (QRScanResult.length > 5) {
      //         // vibrate when QR code is successfully scanned
      //         Vibration.vibrate();
      //         try {
      //           String friendSoshiUsername = QRScanResult.split("/").last;
      //           Map friendData =
      //               await databaseService.getUserFile(friendSoshiUsername);
      //           bool isFriendAdded =
      //               await LocalDataService.isFriendAdded(friendSoshiUsername);

      //           Popups.showUserProfilePopupNew(context,
      //               friendSoshiUsername: friendSoshiUsername,
      //               refreshScreen: () {});
      //           if (!isFriendAdded && friendSoshiUsername != soshiUsername) {
      //             // await LocalDataService.addFriend(
      //             //     friendsoshiUsername: friendSoshiUsername);
      //             databaseService.addFriend(
      //                 thisSoshiUsername: databaseService.currSoshiUsername,
      //                 friendSoshiUsername: friendSoshiUsername);
      //           }

      //           // bool friendHasTwoWaySharing = await databaseService.getTwoWaySharing(friendData);
      //           // if (friendHasTwoWaySharing == null || friendHasTwoWaySharing == true) {
      //           //   // if user has two way sharing on, add self to user's friends list
      //           //   databaseService.addFriend(thisSoshiUsername: friendSoshiUsername, friendSoshiUsername: databaseService.currSoshiUsername);
      //           // }
      //           //add friend right here

      //           Analytics.logQRScan(QRScanResult, true, "qrCode.dart");
      //         } catch (e) {
      //           Analytics.logQRScan(QRScanResult, false, "qrCode.dart");
      //           print(e);
      //         }
      //       }
      //     }
      //   },
      //   child: Icon(Icons.camera_alt_rounded), //icon inside button
      // ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // appBar: (currScreen != 1)
      //     ? PreferredSize(
      //         //Create "Beta" icon on left
      //         preferredSize: Size(Utilities.getWidth(context),
      //             Utilities.getHeight(context) / 20),
      //         child: SoshiAppBar())
      //     : PreferredSize(
      //         //Create "Beta" icon on left
      //         preferredSize: Size(Utilities.getWidth(context),
      //             Utilities.getHeight(context) / 20),
      //         child: Container(
      //           color: Colors.transparent,
      //         )),
      drawer: Drawer(
        child: GeneralSettings(),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // backgroundColor: Colors.white,

      // {Changed color}

      body: PageView(
        children: screens,
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            print("changinc current screen information");
            currScreen = index;
          });
        },
      ),
      // bottomNavigationBar: SriCustomBottomNavBar(),
      // bottomNavigationBar: AnimatedBottomNavigationBar(
      //   iconSize: 30,
      //   icons: [
      //     Icons.qr_code,
      //     Icons.person,
      //     Icons.bolt_sharp,
      //     Icons.list,
      //   ],
      //   backgroundColor: Colors.grey[800],
      //   // height: 50,
      //   inactiveColor: Colors.white,
      //   activeColor: Colors.cyan,
      //   activeIndex: currScreen,
      //   gapLocation: GapLocation.center,
      //   notchSmoothness: NotchSmoothness.softEdge,
      //   // onTap: (index) => setState(() => _bottomNavIndex = index),

      //   onTap: (index) {
      //     setState(() {
      //       // _bottomNavIndex = index
      //       currScreen = index;
      //     });
      //   },
      //   //other params
      // ),

      bottomNavigationBar: SizedBox(
        height: Utilities.getHeight(context) / 11,
        child: CustomNavigationBar(
          scaleCurve: Curves.fastLinearToSlowEaseIn,
          scaleFactor: .05,
          elevation: 5,
          iconSize: Utilities.getWidth(context) / 10,
          selectedColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          strokeColor: Colors.transparent,
          unSelectedColor: Colors.grey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: [
            CustomNavigationBarItem(
              icon: Icon(
                AntDesign.qrcode,
                size: 35,
              ),
            ),
            CustomNavigationBarItem(
                icon: ProfilePic(
                    radius: 25,
                    url: LocalDataService.getLocalProfilePictureURL())),
            CustomNavigationBarItem(
              icon: Icon(
                AntDesign.contacts,
                size: 35,
              ),
            ),
          ],
          currentIndex: currScreen,
          onTap: (index) {
            setState(() {
              HapticFeedback.lightImpact();
              pageController.jumpToPage(index);
              currScreen = index;
            });
          },
        ),
      ),
    );
  }
}
