import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soshi/services/dynamicLinks.dart';

class DataEngine {
  // String defaultUsername;
  // DataEngine({@required this.defaultUsername});

  static String soshiUsername;
  static bool initializedStatus = false;

  static initialize(String soshiUsername) async {
    DataEngine.soshiUsername = soshiUsername;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userObject");
    log("[⚙ Data Engine ⚙] successfully initialzed with username: ${soshiUsername} ✅");
  }

  static Map serializeUser(SoshiUser user) {
    List serializePassions = [];

    user.passions.forEach((e) {
      serializePassions.add({'passion_emoji': e.emoji, 'passion_name': e.name});
    });

    Map<String, dynamic> toReturn = {
      'Friends': user.friends,
      'Name': {
        'First': user.firstNameController.text,
        'Last': user.lastNameController.text
      },
      'Photo URL': user.photoURL,
      'Bio': user.bioController.text,
      'Soshi Points': user.soshiPoints,
      'Verified': user.verified,
      'Passions': serializePassions,
      'Choose Platforms':
          user.getAvailablePlatforms().map((e) => e.platformName).toList(),
      'Profile Platforms':
          user.getChosenPlatforms().map((e) => e.platformName).toList(),
      'Dynamic Link': user.dynamicLink,
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
  static getUserObject(
      {@required bool firebaseOverride, String soshiUsernameOverride}) async {
    String currUsername;
    if (soshiUsernameOverride == null) {
      currUsername = soshiUsername; // if no override, use local username
    } else {
      currUsername = soshiUsernameOverride;
      firebaseOverride = true; // force firebase override if other user
    }
    Map fetch;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    log("{userObject Exists?} ==> ${prefs.containsKey("userObject")}");

    if (firebaseOverride || !prefs.containsKey("userObject")) {
      log("[⚙ Data Engine ⚙]  getUserObject() Firebase data burn ⚠ userFetch=> ${currUsername}");
      DocumentSnapshot dSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUsername)
          .get();
      fetch = dSnap.data();
      await prefs.setString("userObject", jsonEncode(fetch));
    } else {
      log("[⚙ Data Engine ⚙]  getUserObject() Using cache 😃");
      fetch = jsonDecode(prefs.getString("userObject"));
    }

    String url = fetch['Photo URL'] ?? Defaults.defaultProfilePic;
    bool hasPhoto = url != null && url.contains("http");
    String photoURL = url;

    bool Verified = fetch['Verified'] ?? false;
    List<Passion> passions = [];

    // //remove socials array
    List<Social> socials = [];
    Map<String, Social> lookupSocial = {};
    int soshiPoints = fetch['Soshi Points'] ?? 0;
    String bio = fetch['Bio'] ?? "";
    List<String> friends = (fetch['Friends'].cast<String>() ?? []);

    String dynamicLink = fetch['Dynamic Link'] ??
        await DynamicLinkService.createDynamicLink(soshiUsername);
    print(dynamicLink);
    log("[⚙ Data Engine ⚙] basic info built ✅");

    if (fetch['Passions'] == null) {
      for (int i = 0; i < 3; i++) {
        passions.add(Defaults.emptyPassion);
      }
    } else {
      List.of(fetch['Passions']).forEach((e) {
        if (e['passion_name'].toString().toUpperCase() == "EMPTY") {
          passions.add(Defaults.emptyPassion);
        } else {
          passions
              .add(Passion(emoji: e['passion_emoji'], name: e['passion_name']));
        }
      });
    }

    // if (fetch['Passions'] != null) {
    //   List.of(fetch['Passions']).forEach((e) {
    //     if (e['passion_name'].toString().toUpperCase() == "EMPTY") {
    //       passions.add(Defaults.emptyPassion);
    //     } else {
    //       passions.add(Passion(emoji: e['passion_emoji'], name: e['passion_name']));
    //     }
    //   });

    //   //add null for where there are empty passions, so there are always 3
    //   for (int i = 0; i < 3 - fetch['Passions'].length; i++) {
    //     passions.add(Defaults.emptyPassion);
    //   }
    // } else {
    //   for (int i = 0; i < 3; i++) {
    //     passions.add(Defaults.emptyPassion);
    //   }
    // }

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
      soshiUsername: currUsername,
      firstName: fetch['Name']['First'],
      firstNameController:
          new TextEditingController(text: fetch['Name']['First']),
      lastNameController:
          new TextEditingController(text: fetch['Name']['Last']),
      lastName: fetch['Name']['Last'],
      photoURL: photoURL,
      hasPhoto: hasPhoto,
      verified: Verified,
      socials: socials,
      passions: passions,
      soshiPoints: soshiPoints,
      bio: bio,
      bioController: new TextEditingController(text: bio),
      friends: friends,
      lookupSocial: lookupSocial,
      dynamicLink: dynamicLink,
    );
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
        // log(afterSerialized.toString());
        prefs.setString("userObject", jsonEncode(afterSerialized));
        log("[⚙ Data Engine ⚙] update Local success! ✅");
      }

      if (cloud) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(soshiUsername)
            .update(afterSerialized);
        log("[⚙ Data Engine ⚙] update Cloud {Firestore} success! ✅");
      }
    }
  }

  static updateCachedFriendsList({@required List<Friend> friends}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("cachedFriendsList", jsonEncode(friends));
    log("[⚙ Data Engine ⚙] update friends Local success! ✅");
  }

  static Future<List<Friend>> getCachedFriendsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Friend> friends;
    if (!prefs.containsKey("cachedFriendsList")) {
      log("[⚙ Data Engine ⚙]  getCachedFriendsList() Firebase data burn ⚠ userFetch=> ${soshiUsername}");
      SoshiUser user = await getUserObject(firebaseOverride: false);
      friends = await SoshiUser.convertStrToFriendList(user.friends);
      await prefs.setString("cachedFriendsList", jsonEncode(friends));
    } else {
      log("[⚙ Data Engine ⚙]  getCachedFriends() Using cache 😃");
      friends = Friend.decodeFriendsList(prefs.getString("cachedFriendsList"));
    }
    return friends;
  }

//{NOTE} just use "applyUserChanges" and change boolean values

  static Future<List<Passion>> getAvailablePassions(
      {@required bool firebaseOverride}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map allPassionData = {};

    if (!prefs.containsKey("available_passions") || firebaseOverride) {
      log("[⚙ Data Engine ⚙] Firebase burn for available passions❌");

      DocumentSnapshot dsnap = await FirebaseFirestore.instance
          .collection('metadata')
          .doc('passionData')
          .get();
      allPassionData = dsnap.get('all_passions_list');
      await prefs.setString("available_passions", jsonEncode(allPassionData));
    } else {
      log("[⚙ Data Engine ⚙] using smart cache for available passions 😃");

      allPassionData = jsonDecode(prefs.getString("available_passions"));
    }

    List<Passion> pList = allPassionData.keys
        .map((key) => Passion(emoji: allPassionData[key], name: key))
        .toList();

    pList.add(Defaults.emptyPassion);
    log("[⚙ Data Engine ⚙] Successfully fetched latest available passions ✅");
    return pList;
  }
}

class SoshiUser {
  String soshiUsername, firstName, lastName, photoURL, bio, dynamicLink;
  bool hasPhoto;
  bool verified;
  List<Social> socials;
  List<Passion> passions;
  int soshiPoints;
  List<String> friends;
  Map<String, Social> lookupSocial;

  TextEditingController bioController;
  TextEditingController firstNameController;
  TextEditingController lastNameController;

  SoshiUser(
      {@required this.soshiUsername,
      @required this.firstName,
      @required this.firstNameController,
      @required this.lastNameController,
      @required this.lastName,
      @required this.photoURL,
      @required this.hasPhoto,
      @required this.verified,
      @required this.socials,
      @required this.passions,
      @required this.soshiPoints,
      @required this.bio,
      @required this.bioController,
      @required this.friends,
      @required this.lookupSocial,
      @required this.dynamicLink});

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

// checks if user profile in profile settings has been updated to discard/save changes
  bool userUpdated(SoshiUser other) {
    return this.firstName == other.firstName &&
        this.lastName == other.lastName &&
        this.bio == other.bio &&
        this.photoURL == other.photoURL &&
        this.passions == other.passions;
  }

  // takes string list, converts to friends list
  static Future<List<Friend>> convertStrToFriendList(
      List<String> usernameList) async {
    List<Friend> list = [];
    for (String username in usernameList) {
      SoshiUser currUser = await DataEngine.getUserObject(
          firebaseOverride: true, soshiUsernameOverride: username);
      list.add(Friend(
          soshiUsername: username,
          fullName: currUser.firstName + ' ' + currUser.lastName,
          photoURL: currUser.photoURL,
          isVerified: currUser.verified));
    }
    return list;
  }
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

  @override
  bool operator ==(other) {
    return (other is Passion) && other.name == name && other.emoji == emoji;
  }
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

  Map toJson() => {
        "Username": soshiUsername,
        "Name": fullName,
        "Url": photoURL,
        "Verified": isVerified,
      };

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

  static List<Friend> decodeFriendsList(String json) {
    var data = jsonDecode(json);
    List<Friend> friends = [];
    for (var entry in data) {
      friends.add(Friend(
          fullName: entry["Name"],
          soshiUsername: entry["Username"],
          photoURL: entry["Url"],
          isVerified: entry["Verified"]));
    }
    print(data);
    return friends;
  }

  // static List<String> convertToStringList(List<Friend> friendsList) {
  //   List<String> list = [];
  //   for (Friend friend in friendsList) {
  //     list.add(friend.soshiUsername);
  //   }
  //   return list;
  // }

  // convert friend to map, then map to json
  String serialize() {
    return jsonEncode(this.toJson());
  }
}

class Defaults {
  static String defaultProfilePic =
      "https://img.freepik.com/free-photo/abstract-luxury-plain-blur-grey-black-gradient-used-as-background-studio-wall-display-your-products_1258-58170.jpg?w=2000";
  static Passion emptyPassion = Passion(emoji: "❌", name: "Empty");
}
