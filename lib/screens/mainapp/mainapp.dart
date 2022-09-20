import 'dart:async';

import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:nfc_manager/nfc_manager.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/screens/mainapp/friendsGroupsWrapper.dart';
import 'package:soshi/screens/mainapp/profile.dart';
import 'package:soshi/screens/mainapp/qrCode.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:soshi/services/dynamicLinks.dart';
import '../../constants/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../../services/database.dart';
import 'generalSettings.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  Timer _timerLink;
  List<Widget> screens;

  ValueNotifier controlsQRScreen = new ValueNotifier("CONTROL_QR");
  ValueNotifier controlsProfileScreen = new ValueNotifier("CONTROL_PROFILE");
  ValueNotifier controlsConnections = new ValueNotifier("CONTROL_CONNECTION");

  @override
  void initState() {
    super.initState();
    screens = [
      FractionallySizedBox(
          widthFactor: 1 / pageController.viewportFraction,
          child: ValueListenableBuilder(
              valueListenable: controlsQRScreen,
              builder: (context, value, _) {
                return NewQRScreen();
              })),
      FractionallySizedBox(
          widthFactor: 1 / pageController.viewportFraction,
          child: ValueListenableBuilder(
              valueListenable: controlsProfileScreen,
              builder: (context, value, _) {
                return Profile(
                  importProfileNotifier: this.controlsProfileScreen,
                );
              })),
      FractionallySizedBox(
          widthFactor: 1 / pageController.viewportFraction,
          child: ValueListenableBuilder(
              valueListenable: controlsConnections,
              builder: (context, value, _) {
                return FriendsGroupsWrapper();
              })),
    ]; // list of screens (change through indexing)
    WidgetsBinding.instance.addObserver(this);
    print(">> calling from init");
    DynamicLinkService.retrieveDynamicLink(context);
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
  ValueNotifier controlsBottomNavBar = new ValueNotifier(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      drawer: Container(
        width: Utilities.getWidth(context) * .75,
        child: Drawer(
          child: GeneralSettings(),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        children: screens,
        controller: pageController,
        onPageChanged: (int newPage) {
          controlsBottomNavBar.value = newPage;
        },
      ),
      bottomNavigationBar: ValueListenableBuilder(
          valueListenable: controlsBottomNavBar,
          builder: (context, value, _) {
            return LatestBottomNavBar(
              currScreen: currScreen,
              pageController: pageController,
              importNotifier: controlsBottomNavBar,
            );
          }),
    );
  }
}

class LatestBottomNavBar extends StatelessWidget {
  const LatestBottomNavBar(
      {Key key,
      @required this.currScreen,
      @required this.pageController,
      @required this.importNotifier})
      : super(key: key);

  final int currScreen;
  final PageController pageController;
  final ValueNotifier importNotifier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              //AntDesign.qrcode,
              CupertinoIcons.qrcode,
              size: 35,
            ),
          ),
          CustomNavigationBarItem(
              icon: Icon(
            CupertinoIcons.person,
            size: 35,
          )),
          CustomNavigationBarItem(
            icon: Icon(
              //AntDesign.contacts,
              CupertinoIcons.person_3,
              size: 40,
            ),
          ),
        ],
        currentIndex: importNotifier.value,
        onTap: (index) {
          HapticFeedback.lightImpact();
          pageController.jumpToPage(index);
        },
      ),
    );
  }
}
