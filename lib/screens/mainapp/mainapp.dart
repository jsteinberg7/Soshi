import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/screens/mainapp/profile.dart';
import 'package:soshi/screens/mainapp/qrCode.dart';
import 'package:soshi/services/url.dart';
import 'friendScreen.dart';
import 'package:soshi/constants/constants.dart';
import 'package:flutter_icons/flutter_icons.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<Widget> screens = [
    QRScreen(),
    Profile(),
    FriendScreen()
  ]; // list of screens (change through indexing)

  int currScreen = 1;

  PageController pageController = new PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        //Create "Beta" icon on left
        preferredSize: Size(
            Utilities.getWidth(context), Utilities.getHeight(context) / 16),
        child: AppBar(
          leadingWidth: 100,
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: ElevatedButton(
                onPressed: () {
                  URL.launchURL("sms:" + "5713351885");
                },
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    shadowColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)))),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Send",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                        Text("feedback!",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ],
                    ),
                    // Icon(
                    //   Icons.feedback,
                    //   color: Colors.cyan[300],
                    //   size: 10,
                    // ),
                  ],
                ),

                // Icon(Icons.person_rounded,
                //     color: Colors.cyan[300], size: 10.0),
              ),
            ),
          ],
          elevation: 40,
          title: Image.asset(
            "assets/images/SoshiLogos/soshi_logo.png",
            height: Utilities.getHeight(context) / 22,
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          centerTitle: true,
        ),
      ),
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
      bottomNavigationBar: SizedBox(
        height: Utilities.getHeight(context) / 12.5,
        child: CustomNavigationBar(
          iconSize: Utilities.getHeight(context) / 35,
          selectedColor: Colors.cyan[300],
          strokeColor: Colors.cyan[800],
          unSelectedColor: Colors.grey[500],
          backgroundColor: Colors.grey[900],
          items: [
            CustomNavigationBarItem(
              icon: Icon(AntDesign.qrcode),
            ),
            CustomNavigationBarItem(
              icon: Icon(
                AntDesign.home,
              ),
            ),
            CustomNavigationBarItem(
              icon: Icon(
                AntDesign.contacts,
              ),
            ),
          ],
          currentIndex: currScreen,
          onTap: (index) {
            setState(() {
              pageController.jumpToPage(index);
              currScreen = index;
            });
          },
        ),
      ),
    );
  }
}
