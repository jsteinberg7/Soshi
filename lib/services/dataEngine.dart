import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataEngine {
  // String defaultUsername;
  // DataEngine({@required this.defaultUsername});

  static String soshiUsername;
  static bool initializedStatus = false;

  static initialize(String soshiUsername) {
    DataEngine.soshiUsername = soshiUsername;

    log("[⚙ Data Engine ⚙] successfully initialzed with username: ${soshiUsername} ✅");
  }

  static Map serializeUser(SoshiUser user) {
    List serializePassions = [];

    user.passions.forEach((e) {
      serializePassions
          .add({'passions_emoji': e.emoji, 'passions_name': e.name});
    });

    Map<String, dynamic> toReturn = {
      'Friends': [],
      'Name': {'First': user.firstName, 'Last': user.lastName},
      'Photo URL': user.photoURL,
      'Bio': user.bio,
      'Soshi Points': user.soshiPoints,
      'Verified': user.verified,
      'Passions': serializePassions,
      'Choose Platforms':
          user.getAvailablePlatforms().map((e) => e.platformName).toList(),
      'Profile Platforms':
          user.getChosenPlatforms().map((e) => e.platformName).toList()
    };

    Map switches = {};
    Map usernames = {};

    user.lookupSocial.values.forEach((Social e) {
      switches[e.platformName] = e.switchStatus;
      usernames[e.platformName] = e.usernameController.text;
    });

    toReturn['Switches'] = switches;
    toReturn['Usernames'] = usernames;

    log("[⚙ Data Engine ⚙] User successfully serialized");
    return toReturn;
  }

  //{NOTE} If firebaseOverride is true, will fetch latest data again from firestore
  static getUserObject({@required bool firebaseOverride}) async {
    Map fetch;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    log("{userObject Exists?} ==> ${prefs.containsKey("userObject")}");

    if (firebaseOverride || !prefs.containsKey("userObject")) {
      log("[⚙ Data Engine ⚙]  getUserObject() Firebase data burn ⚠ userFetch=> ${soshiUsername}");
      DocumentSnapshot dSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(soshiUsername)
          .get();
      fetch = dSnap.data();
      await prefs.setString("userObject", jsonEncode(fetch));
    } else {
      log("[⚙ Data Engine ⚙]  getUserObject() Using cache ✅");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      fetch = jsonDecode(prefs.getString("userObject"));
    }

    bool hasPhoto =
        fetch['Photo URL'] != null && fetch['Photo URL'].contains("http");
    String photoURL = fetch['Photo URL'] ??
        "https://img.freepik.com/free-photo/abstract-luxury-plain-blur-grey-black-gradient-used-as-background-studio-wall-display-your-products_1258-58170.jpg?w=2000";
    bool Verified = fetch['Verified'] ?? false;
    List<Passion> passions = [];

    // //remove socials array
    List<Social> socials = [];
    Map<String, Social> lookupSocial = {};
    int soshiPoints = fetch['Soshi Points'] ?? 0;
    String bio = fetch['Bio'] ?? "";
    List friends = fetch['Friends'] ?? [];
    log("[⚙ Data Engine ⚙] basic info built ✅");

    if (fetch['Passions'] != null) {
      List.of(fetch['Passions']).forEach((e) {
        passions
            .add(Passion(emoji: e['passion_emoji'], name: e['passion_name']));
      });
    }

    log("[⚙ Data Engine ⚙] passions info built ✅");

    if (fetch['Usernames'] != null &&
        fetch['Switches'] != null &&
        fetch['Choose Platforms'] != null) {
      Map.of(fetch['Usernames']).keys.forEach((key) {
        bool switchStatus = Map.of(fetch['Switches'])[key];
        bool isChosen = List.of(fetch['Profile Platforms']).contains(key);
        // log("[⚙ Data Engine ⚙] adding ${key} ${switchStatus} ${isChosen} ✅");

        Social makeSocial = Social(
            username: fetch['Usernames'][key],
            platformName: key.toString(),
            switchStatus: switchStatus,
            isChosen: isChosen,
            usernameController:
                TextEditingController(text: fetch['Usernames'][key]));

        socials.add(makeSocial);
        lookupSocial[key] = makeSocial;
      });

      log("[⚙ Data Engine ⚙] SoshiUser Object built ✅");
    }

    return SoshiUser(
        soshiUsername: soshiUsername,
        firstName: fetch['Name']['First'],
        lastName: fetch['Name']['Last'],
        photoURL: photoURL,
        hasPhoto: hasPhoto,
        verified: Verified,
        socials: socials,
        passions: passions,
        soshiPoints: soshiPoints,
        bio: bio,
        friends: friends,
        lookupSocial: lookupSocial);
  }

  // static overrideWithTextControllerData(){

  // }

  static applyUserChanges(
      {@required SoshiUser user,
      @required bool cloud,
      @required bool local}) async {
    // {!} These tasks can happen asynchronously to save time!
    if (cloud || local) {
      Map afterSerialized = serializeUser(user);

      if (local) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        log(afterSerialized.toString());
        prefs.setString("userObject", jsonEncode(afterSerialized));
        log("[⚙ Data Engine ⚙] update Local success! ✅");
      }

      if (cloud) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(soshiUsername)
            .set(afterSerialized);
        log("[⚙ Data Engine ⚙] update Cloud {Firestore} success! ✅");
      }
    }
  }

//{NOTE} just use "applyUserChanges" and change boolean values

}

class SoshiUser {
  String soshiUsername, firstName, lastName, photoURL, bio;
  bool hasPhoto;
  bool verified;
  List<Social> socials;
  List<Passion> passions;
  int soshiPoints;
  List friends;
  Map<String, Social> lookupSocial;
  // List<Friend> friends;

  SoshiUser(
      {@required this.soshiUsername,
      @required this.firstName,
      @required this.lastName,
      @required this.photoURL,
      @required this.hasPhoto,
      @required this.verified,
      @required this.socials,
      @required this.passions,
      @required this.soshiPoints,
      @required this.bio,
      @required this.friends,
      @required this.lookupSocial});

  //Will ignore case in input platform String
  getUsernameGivenPlatform({@required String platform}) {
    if (this.lookupSocial[platform] == null) {
      return "MISSING_USERNAME";
    }
    return this.lookupSocial[platform].username;
  }

  List<Social> getChosenPlatforms() {
    List<Social> toReturn = [];
    this.lookupSocial.values.forEach((element) {
      if (element.isChosen) {
        toReturn.add(element);
      }
    });
    return toReturn;
  }

  List<Social> getAvailablePlatforms() {
    List<Social> toReturn = [];
    this.lookupSocial.values.forEach((element) {
      if (!element.isChosen) {
        toReturn.add(element);
      }
    });
    return toReturn;
  }

  removeFromAvailablePlatforms({@required List listToRemove}) {
    listToRemove.forEach((platformName) {
      // this.socials.removeWhere((element) => element.platformName == platformName);
      log("[⚙ Data Engine ⚙] Attempt to delete social ${platformName} ❓");
      Social removed = this.lookupSocial.remove(platformName);
      if (removed == null) {
        log("[⚙ Data Engine ⚙] ❌ Unable to remove platform ${platformName}, Doesn't exist ❌");
      }
    });
  }

  removeFromProfile({@required String platformName}) {
    // this.lookupSocial.remove(platformName);
    this.lookupSocial[platformName].isChosen = false;
    log("after remove:" + lookupSocial.toString());
  }

  addNewPlatforms() {}

  getSocialFromPlatform() {}
}

class Social {
  String username, platformName;
  bool switchStatus, isChosen;
  TextEditingController usernameController;

  Social(
      {@required this.username,
      @required this.platformName,
      @required this.switchStatus,
      @required this.isChosen,
      @required this.usernameController});
}

class Passion {
  String emoji, name;
  Passion({
    @required this.emoji,
    @required this.name,
  });
}

/* Stores information for individual friend/connection */
class Friend {
  String soshiUsername, fullName, photoURL;
  bool isVerified;

  Friend({
    this.soshiUsername,
    this.fullName,
    this.photoURL,
    this.isVerified, // only use when coming from json
  });

  // takes in a single json pertaining to a friend, returns Friend object
  static Friend decodeFriend(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return Friend(
      soshiUsername: map["Username"],
      fullName: map["Name"],
      photoURL: map["Url"],
      isVerified: map["Verified"],
    );
  }

  static List<String> convertToStringList(List<Friend> friendsList) {
    List<String> list = [];
    for (Friend friend in friendsList) {
      list.add(friend.soshiUsername);
    }
    return list;
  }

  static List<Friend> convertToFriendList(List<String> usernameList) async {
    List<Friend> list = [];
    for (String username in usernameList) {

      
      list.add(friend);
    }
  }

  // convert friend to map, then map to json
  String serialize() {
    Map<String, dynamic> map = {
      "Username": soshiUsername,
      "Name": fullName,
      "Url": photoURL,
      "Verified": isVerified,
    };
    return jsonEncode(map);
  }
}

class Defaults {
  static String defaultProfilePic =
      "https://img.freepik.com/free-photo/abstract-luxury-plain-blur-grey-black-gradient-used-as-background-studio-wall-display-your-products_1258-58170.jpg?w=2000";
}
