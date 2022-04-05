import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import '../constants/popups.dart';

abstract class DynamicLinkService {
  static Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      if (!Popups.popup_live) {
        final PendingDynamicLinkData data =
            await FirebaseDynamicLinks.instance.getInitialLink();
        final Uri deepLink = data?.link;
        print("RECEIVING DEEP LINK: " + deepLink?.toString());
        if (deepLink != null) {
          await Popups.showUserProfilePopupNew(context,
              friendSoshiUsername: "jason", refreshScreen: () {});
        }
        FirebaseDynamicLinks.instance.onLink
            .listen((PendingDynamicLinkData dynamicLink) async {
          await Popups.showUserProfilePopupNew(context,
              friendSoshiUsername: "jason", refreshScreen: () {});
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  ///createDynamicLink()
}
