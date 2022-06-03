import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import '../constants/popups.dart';

abstract class DynamicLinkService {
  static Future<void> retrieveDynamicLink(BuildContext context) async {
    // try {
    // if (!Popups.popup_live) {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    // print("RECEIVING DEEP LINK: " + deepLink?.toString());
    if (deepLink != null) {
      final String username = deepLink?.pathSegments?.last;
      await Popups.showUserProfilePopupNew(context,
          friendSoshiUsername: username, refreshScreen: () {});
      await Future.delayed(Duration(seconds: 3));
      // reset popup disabler after timer
      Popups.popup_live = false;
      return;
    }
    FirebaseDynamicLinks.instance.onLink
        .listen((PendingDynamicLinkData dynamicLink) async {
      // print(
      //     ">> " + dynamicLink.link.toString().split("/").last.split("/").last);
      print(">> " + dynamicLink.android.toString().split("/").last);
      await Popups.showUserProfilePopupNew(context,
          friendSoshiUsername:
              dynamicLink.link.toString().split("/").last.split("/").last,
          refreshScreen: () {});
      await Future.delayed(Duration(seconds: 3));
      // reset popup disabler after timer
      Popups.popup_live = false;
    });

    // }
    // } catch (e) {
    //   print(e.toString());
    // }
  }

  ///createDynamicLink()
}
