import 'dart:async';

import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/screens/mainapp/profile.dart';
import 'package:soshi/screens/mainapp/qrCode.dart';
import 'package:soshi/services/dynamicLinks.dart';
import 'package:soshi/services/url.dart';
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
          await DynamicLinkService.retrieveDynamicLink(context);
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
      bottomNavigationBar: SizedBox(
        height: Utilities.getHeight(context) / 12.5,
        child: CustomNavigationBar(
          iconSize: Utilities.getHeight(context) / 35,
          selectedColor: Colors.cyan[300],
          strokeColor: Colors.cyan[800],
          unSelectedColor: Colors.grey[500],
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.grey[900],
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
