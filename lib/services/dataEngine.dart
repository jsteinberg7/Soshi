import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataEngine {
  // String defaultUsername;
  // DataEngine({@required this.defaultUsername});

  static String soshiUsername;

  static initialize(String soshiUsername) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userObject", jsonEncode({}));

    soshiUsername = soshiUsername;
    log("✅ Data Engine initialized! successfully with username: ${soshiUsername}");
  }

  static Map serializeUser(SoshiUser user) {
    List serializePassions = [];

    user.passsions.forEach((e) {
      serializePassions.add({'passions_emoji': e.emoji, 'passions_name': e.name});
    });

    Map<String, dynamic> toReturn = {
      'Friends': [],
      'Name': {'First': user.firstName, 'Last': user.lastName},
      'Photo URL': user.photoURL,
      'Bio': user.bio,
      'Soshi Points': user.soshiPoints,
      'Verified': user.verified,
      'Passions': user.passsions
    };

    Map switches, usernames = {};

    user.socials.forEach((Social e) {
      switches[e.platformName] = e.switchStatus;
      usernames[e.platformName] = e.username;
    });

    toReturn['Switches'] = switches;
    toReturn['Usernames'] = usernames;

    log("✅ User successfullySerialized");
    return toReturn;
  }

  static getUserObject(bool firebaseOverride) async {
    Map fetch;

    if (firebaseOverride) {
      print("⚠ ⚠ Get User Object () [Warning Firebase dataBurn] ⚠ ⚠");
      DocumentSnapshot dSnap =
          await FirebaseFirestore.instance.collection("Users").doc(soshiUsername).get();
      fetch = dSnap.data();
    } else {
      print("✅ ✅ Get User Object () [Using user cache!] ✅ ✅");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      fetch = jsonDecode(prefs.getString("userObject"));
    }

    bool hasPhoto = fetch['Photo URL'] != null && fetch['Photo URL'].contains("http");
    String photoURL = fetch['Photo URL'] ?? "NO_PHOTO";
    bool Verified = fetch['Verified'] ?? false;
    List<Passion> passions = [];
    List<Social> socials = [];
    int soshiPoints = fetch['Soshi Points'] ?? 0;
    String bio = fetch['Bio'] ?? "";
    List<String> friends = fetch['Friends'] ?? [];

    if (fetch['Passions'] != null) {
      List.of(fetch['Passions']).forEach((e) {
        passions.add(Passion(emoji: e['passion_emoji'], name: e['passion_name']));
      });
    }
    if (fetch['Usernames'] != null &&
        fetch['Switches'] != null &&
        fetch['Choose Platforms'] != null) {
      Map.of(fetch['Usernames']).keys.forEach((key) {
        bool switchStatus = Map.of(fetch['Switches'])[key];
        bool isChosen = List.of(fetch['Choose Platforms']).contains(key);

        socials.add(Social(
            username: fetch['Usernames'][key],
            platformName: key.toString(),
            switchStatus: switchStatus,
            isChosen: isChosen));
      });

      log("✅ getUserObject successfully created!");
    }

    return SoshiUser(
        soshiUsername: soshiUsername,
        firstName: fetch['Name']['First'],
        lastName: fetch['Name']['Last'],
        photoURL: photoURL,
        hasPhoto: hasPhoto,
        verified: Verified,
        socials: socials,
        passsions: passions,
        soshiPoints: soshiPoints,
        bio: bio,
        friends: friends);
  }

  static applyUserChanges(SoshiUser user) async {
    Map afterSerialized = serializeUser(user);
    // {!} These tasks can happen asynchronously to save time!
    updateLocal(afterSerialized);
    updateCloud(afterSerialized);
  }

  static updateLocal(Map input) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userObject", jsonEncode(input));
    log("✅ update Local success!");
  }

  static updateCloud(Map input) async {
    await FirebaseFirestore.instance.collection("Users").doc(soshiUsername).set(input);
    log("✅ update Cloud success!");
  }
}

class SoshiUser {
  String soshiUsername, firstName, lastName, photoURL, bio;
  bool hasPhoto;
  bool verified;
  List<Social> socials;
  List<Passion> passsions;
  int soshiPoints;
  List<String> friends;

  SoshiUser(
      {@required this.soshiUsername,
      @required this.firstName,
      @required this.lastName,
      @required this.photoURL,
      @required this.hasPhoto,
      @required this.verified,
      @required this.socials,
      @required this.passsions,
      @required this.soshiPoints,
      @required this.bio,
      @required this.friends});

  getChosenPlatforms() {
    List<String> toReturn;
    this.socials.forEach((element) {
      if (element.isChosen) {
        toReturn.add(element.platformName);
      }
    });
  }

  getAvailablePlatforms() {
    List<String> toReturn;
    this.socials.forEach((element) {
      if (!element.isChosen) {
        toReturn.add(element.platformName);
      }
    });
  }
}

class Social {
  String username, platformName;
  bool switchStatus, isChosen;
  Social(
      {@required this.username,
      @required this.platformName,
      @required this.switchStatus,
      @required this.isChosen});
}

class Passion {
  String emoji, name;

  Passion({
    @required this.emoji,
    @required this.name,
  });
}
