import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import '../constants/popups.dart';
import '../screens/mainapp/viewProfilePage.dart';

abstract class DynamicLinkService {
  // static Future<void> retrieveDynamicLink(BuildContext context) async {
  //   try {
  //     if (!Popups.popup_live) {
  //       final PendingDynamicLinkData data =
  //           await FirebaseDynamicLinks.instance.getInitialLink();
  //       final Uri deepLink = data?.link;

  //       // print("RECEIVING DEEP LINK: " + deepLink?.toString());
  //       if (deepLink != null) {
  //         final String username = deepLink?.pathSegments?.last;
  //         await Popups.showUserProfilePopupNew(context,
  //             friendSoshiUsername: username, refreshScreen: () {});
  //         await Future.delayed(Duration(seconds: 3));
  //         // reset popup disabler after timer
  //         Popups.popup_live = false;
  //         return;
  //       }
  //       FirebaseDynamicLinks.instance.onLink
  //           .listen((PendingDynamicLinkData dynamicLink) async {
  //         // print(
  //         //     ">> " + dynamicLink.link.toString().split("/").last.split("/").last);
  //         print(">> " + dynamicLink.android.toString().split("/").last);
  // await Popups.showUserProfilePopupNew(context,
  //     friendSoshiUsername:
  //         dynamicLink.link.toString().split("/").last.split("/").last,
  //     refreshScreen: () {});
  //         await Future.delayed(Duration(seconds: 3));
  //         // reset popup disabler after timer
  //         Popups.popup_live = false;
  //       });
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // create deep link for user
  static Future<void> createDeepLink(String username) async {
    await FirebaseDynamicLinks.instance.buildShortLink(DynamicLinkParameters(
        // longDynamicLink: Uri.parse("https://soshi.app/deeplink/user/$username"),
        link: Uri.parse(
          "https://soshi.app/$username",
        ),
        uriPrefix: "https://soshi.app/deeplink/user",
        androidParameters: const AndroidParameters(
          packageName: "com.swoledevs.soshi",
          minimumVersion: 30,
        ),
        iosParameters: const IOSParameters(
          bundleId: "com.swoledevs.soshi",
          appStoreId: "1595515750",
          minimumVersion: "11.0.0",
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: "Example of a Dynamic Link",
          imageUrl: Uri.parse(
              "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/4c/d0/83/4cd083e4-ae76-7061-a794-1e0120ddbf93/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/1200x630wa.png"),
        ),
        navigationInfoParameters:
            NavigationInfoParameters(forcedRedirectEnabled: true)));
  }

  static Future<void> retrieveDynamicLink(BuildContext context) async {
    int i = 0;
    // print(">> method call");
    List params;
    Stream stream = FirebaseDynamicLinks.instance.onLink;
    stream.listen((data) async {
      final Uri deepLink = data?.link;

      if (deepLink != null) {
        params = deepLink.toString().split("/");
        // print(">> inside function: params: " + params.toString());
      }
    }, onError: (e) async {
      print("onLinkError");
      print(e);
    });
    await stream.first;
    // print(">> params: " + params.toString());
    if (params == null) {
      return;
    }
    if (params.contains("group")) {
      // handle group deeplink
    } else {
      // handle user deeplink
      String username = params?.last;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ViewProfilePage(
          friendSoshiUsername: username,
          refreshScreen: () {},
        ); // show friend popup when tile is pressed
      }));
      // print(">> returning now. $i");
      i += 1;
      return;
    }
  }

  ///createDynamicLink(
  static Future<void> createGroupDynamicLink(String id) async {
    var links = FirebaseDynamicLinks.instance;
    links.buildShortLink(
      DynamicLinkParameters(
        uriPrefix: "https://soshi.app/group",
        longDynamicLink: Uri.parse("https://soshi.app/group/$id"),
        link: Uri.parse("https://soshi.app/joingroup/$id"),
        androidParameters:
            AndroidParameters(packageName: 'com.swoledevs.soshi'),
        iosParameters: IOSParameters(bundleId: 'com.example.strippedsoshi'),
      ),
    );
  }
}
