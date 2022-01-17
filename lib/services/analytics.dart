import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:async';

import 'package:soshi/services/geo_ip.dart';

abstract class Analytics {
  static FirebaseAnalytics instance = FirebaseAnalytics.instance;

  static Future<void> setUserAttributes(
      {String userId, String username, String email}) async {
    await instance.setUserId(id: userId);
    // await instance.setUserProperty(name: 'username', value: username);
    // await instance.setUserProperty(name: 'email', value: email);
    // await instance.setUserProperty(
    //     name: 'geo_ip', value: SeeipClient().getGeoIP().toString());
  }

  static logAppOpen() async {
    await instance.logAppOpen();
  }

  static logSignIn(String method) async {
    await instance.logLogin(loginMethod: method);
  }

  static logSignUp(String method) async {
    await instance.logSignUp(signUpMethod: method);
  }

  // static logSignOut() async {}

  static Future<void> logQRScan(String qrResult) async {
    await instance.logEvent(name: 'qr_scan', parameters: {
      'qr_result': qrResult,
    });
  }

  static Future<void> logSuccessfulQRScan(String qrResult) async {
    await instance.logEvent(
        name: "successful_qr_scan",
        parameters: {"scanned_username": qrResult.split("/").last});
  }

  static Future<void> logFailedQRScan(String qrResult) async {
    await instance
        .logEvent(name: "failed_qr_scan", parameters: {"qr_result": qrResult});
  }

  static Future<void> logAddFriend(String friendUsername) async {
    await instance.logEvent(
        name: "add_friend", parameters: {"friend_username": friendUsername});
  }

  static Future<void> logRemoveFriend(String friendUsername) async {
    await instance.logEvent(
        name: "remove_friend", parameters: {"friend_username": friendUsername});
  }

  static Future<void> logCopyLinkToClipboard() async {
    await instance.logEvent(name: "copied_link_to_clipboard");
  }

  static Future<void> logUpdateUsernameForPlatform(String platform) async {
    await instance.logEvent(
        name: "update_username_for_platform",
        parameters: {"platform": platform});
  }

  static Future<void> logAccessPlatform(String platform) async {
    await instance
        .logEvent(name: "access_platform", parameters: {"platform": platform});
  }
}
