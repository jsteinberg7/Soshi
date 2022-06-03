import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/screens/mainapp/boltScreen.dart';
import 'package:soshi/screens/mainapp/profile.dart';
import 'package:soshi/screens/mainapp/qrCode.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/dynamicLinks.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/services/url.dart';
import 'package:vibration/vibration.dart';
import '../../constants/popups.dart';
import '../../constants/widgets.dart';
import 'friendScreen.dart';
import 'package:soshi/constants/constants.dart';
import 'package:flutter_icons/flutter_icons.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  Timer _timerLink;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(
        const Duration(milliseconds: 1000),
        () async {
          DynamicLinkService.retrieveDynamicLink(context);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink.cancel();
    }
    super.dispose();
  }

  List<Widget> screens = [
    QRScreen(),
    Profile(),
    BoltScreen(),
    FriendScreen(),
  ]; // list of screens (change through indexing)

  int currScreen = 2;

  PageController pageController = new PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");
    DatabaseService databaseService =
        new DatabaseService(currSoshiUsernameIn: soshiUsername);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 32, 199, 221),
        //Floating action button on Scaffold
        onPressed: () async {
          //code to execute on button press
          {
            String QRScanResult = await Utilities.scanQR(mounted);
            if (QRScanResult.length > 5) {
              // vibrate when QR code is successfully scanned
              Vibration.vibrate();
              try {
                String friendSoshiUsername = QRScanResult.split("/").last;
                Map friendData =
                    await databaseService.getUserFile(friendSoshiUsername);
                bool isFriendAdded =
                    await LocalDataService.isFriendAdded(friendSoshiUsername);

                Popups.showUserProfilePopupNew(context,
                    friendSoshiUsername: friendSoshiUsername,
                    refreshScreen: () {});
                if (!isFriendAdded && friendSoshiUsername != soshiUsername) {
                  // await LocalDataService.addFriend(
                  //     friendsoshiUsername: friendSoshiUsername);
                  databaseService.addFriend(
                      thisSoshiUsername: databaseService.currSoshiUsername,
                      friendSoshiUsername: friendSoshiUsername);
                }

                // bool friendHasTwoWaySharing = await databaseService.getTwoWaySharing(friendData);
                // if (friendHasTwoWaySharing == null || friendHasTwoWaySharing == true) {
                //   // if user has two way sharing on, add self to user's friends list
                //   databaseService.addFriend(thisSoshiUsername: friendSoshiUsername, friendSoshiUsername: databaseService.currSoshiUsername);
                // }
                //add friend right here

                Analytics.logQRScan(QRScanResult, true, "qrCode.dart");
              } catch (e) {
                Analytics.logQRScan(QRScanResult, false, "qrCode.dart");
                print(e);
              }
            }
          }
        },
        child: Icon(Icons.camera_alt_rounded), //icon inside button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      appBar: PreferredSize(
          //Create "Beta" icon on left
          preferredSize: Size(
              Utilities.getWidth(context), Utilities.getHeight(context) / 16),
          child: SoshiAppBar()),
      backgroundColor: Theme.of(context).backgroundColor,
      // backgroundColor: Colors.white,

      // {Changed color}
      body: PageView(
        children: screens,
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currScreen = index;
          });
        },
      ),
      // bottomNavigationBar: SriCustomBottomNavBar(),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        iconSize: 30,
        icons: [
          Icons.qr_code,
          Icons.person,
          Icons.bolt_sharp,
          Icons.list,
        ],
        backgroundColor: Colors.grey[800],
        // height: 50,
        inactiveColor: Colors.white,
        activeColor: Colors.cyan,
        activeIndex: currScreen,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        // onTap: (index) => setState(() => _bottomNavIndex = index),

        onTap: (index) {
          setState(() {
            // _bottomNavIndex = index
            currScreen = index;
          });
        },
        //other params
      ),

      // bottomNavigationBar: SizedBox(
      //   height: Utilities.getHeight(context) / 12.5,
      //   child: CustomNavigationBar(
      //     iconSize: Utilities.getHeight(context) / 35,
      //     selectedColor: Colors.cyan[300],
      //     strokeColor: Colors.cyan[800],
      //     unSelectedColor: Colors.grey[500],
      //     backgroundColor:
      //         Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey[900],
      //     items: [
      //       CustomNavigationBarItem(
      //         icon: Icon(AntDesign.qrcode),
      //       ),
      //       CustomNavigationBarItem(
      //         icon: Icon(
      //           AntDesign.home,
      //         ),
      //       ),
      //       CustomNavigationBarItem(
      //         icon: Icon(
      //           AntDesign.contacts,
      //         ),
      //       ),
      //     ],
      //     currentIndex: currScreen,
      //     onTap: (index) {
      //       setState(() {
      //         pageController.jumpToPage(index);
      //         currScreen = index;
      //       });
      //     },
      //   ),
      // ),
    );
  }
}

// class SriCustomBottomNavBar extends StatefulWidget {
//   @override
//   _SriCustomBottomNavBarState createState() => _SriCustomBottomNavBarState();
// }

// class _SriCustomBottomNavBarState extends State<SriCustomBottomNavBar> {
//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       //bottom navigation bar on scaffold
//       color: Colors.redAccent,
//       shape: CircularNotchedRectangle(), //shape of notch
//       notchMargin: 5, //notche margin between floating button and bottom appbar
//       child: Row(
//         //children inside bottom appbar
//         mainAxisSize: MainAxisSize.max,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           IconButton(
//             icon: Icon(AntDesign.qrcode),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: Icon(
//               Feather.award,
//               color: Colors.white,
//             ),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: Icon(
//               FeatherIcons.users,
//               color: Colors.white,
//             ),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FixedCameraIconNav extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       //Floating action button on Scaffold
//       onPressed: () {
//         //code to execute on button press
//       },
//       child: Icon(Icons.send), //icon inside button
//     );
//   }
// }
