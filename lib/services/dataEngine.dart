import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/dynamicLinks.dart';
import 'package:soshi/services/pointManager.dart';

class DataEngine {
  // String defaultUsername;
  // DataEngine({@required this.defaultUsername});
  static String soshiUsername;
  static bool initializedStatus = false;
  static bool hasLaunched = false;
  static SoshiUser globalUser;

  //Used when user logs in or creates accont
  static freshSetup({@required soshiUsername}) async {
    // Force clearing all cache!
    await SharedPreferences.getInstance().then((value) => value.clear());
    await SharedPreferences.getInstance()
        .then((value) => value.setString("Username", soshiUsername));
    DataEngine.soshiUsername = soshiUsername;
    log("[⚙ Data Engine ⚙] Fresh Setup successful with username ${soshiUsername}");
  }

  //Used after user logs out (Little uncessary as we clear on login)
  static forceClear() async {
    log("[⚙ Data Engine ⚙] All user cache data cleared!");
    await SharedPreferences.getInstance().then((value) => value.clear());
  }

  static usernameFailSafe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // sharedPrefeerences prefs arent loading --> giving null values, unable to load app
    DataEngine.soshiUsername = prefs.getString("Username");
    log("[⚙ Data Engine ⚙] successfully initialzed with username: ${soshiUsername} ✅");
  }

  static initialize() async {
    DataEngine.globalUser =
        await DataEngine.getUserObject(firebaseOverride: true);
  }

  static Future<Map> serializeUser(SoshiUser user) async {
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
      'Short Dynamic Link': user.shortDynamicLink,
      'Long Dynamic Link': user.longDynamicLink,
      'Point Manager': user.pointManager.serializeDictionary(),
    };

    Map switches = {};
    Map usernames = {};

    log("[⚙ Data Engine ⚙] Updating .vcf Contact file");
    String url = await DatabaseService.updateContactCard(user: user);

    user.lookupSocial.values.forEach((Social e) {
      switches[e.platformName] = e.switchStatus;
      if (e.platformName == "Contact") {
        usernames[e.platformName] = url;
      } else {
        usernames[e.platformName] = e.usernameController.text;
      }
    });

    toReturn['Switches'] = switches;
    toReturn['Usernames'] = usernames;

    log("[⚙ Data Engine ⚙] User successfully serialized");
    return toReturn;
  }

  //{NOTE} If firebaseOverride is true, will fetch latest data again from firestore
  static getUserObject(
      {@required bool firebaseOverride, String friendOverride}) async {
    //failsafe [kinda necessary]

    await usernameFailSafe();

    String currUsername = DataEngine.soshiUsername;
    if (friendOverride != null && friendOverride != "") {
      currUsername = friendOverride;
      firebaseOverride = true; // force firebase override if other user
    }

    Map fetch;

// Only change userObject sharedPref when soshiUsernameOverride is null

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (firebaseOverride ||
        !prefs.containsKey("userObject") ||
        prefs.getString("userObject") == "null") {
      log("[⚙ Data Engine ⚙]  getUserObject() Firebase data burn ⚠ userFetch=> ${currUsername}");
      DocumentSnapshot dSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUsername)
          .get();
      fetch = dSnap.data() as Map<String, dynamic>;

      if (friendOverride == null) {
        await prefs.setString("userObject", jsonEncode(fetch));
      }
    } else {
      log("[⚙ Data Engine ⚙]  getUserObject() Using cache 😃");
      fetch = jsonDecode(prefs.getString("userObject"));
    }

    bool hasPhoto = fetch['Photo URL'] != null && fetch['Photo URL'] != "";
    String photoURL =
        hasPhoto ? fetch['Photo URL'] : Defaults.defaultProfilePic;
    bool Verified = fetch['Verified'] ?? false;
    List<Passion> passions = [];

    List<Social> socials = [];
    Map<String, Social> lookupSocial = {};
    int soshiPoints = fetch['Soshi Points'] ?? 0;
    String bio = fetch['Bio'] ?? "";
    List<String> friends = (fetch['Friends'].cast<String>() ?? []);

    String shortDynamicLink = fetch['Short Dynamic Link'] ??
        await DynamicLinkService.createShortDynamicLink(soshiUsername);
    String longDynamicLink = fetch['Long Dynamic Link'] ??
        await DynamicLinkService.createLongDynamicLink(soshiUsername);

    //print(dynamicLink);
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

    log("[⚙ Data Engine ⚙] passions info built ✅");

    if (fetch['Usernames'] != null &&
        fetch['Switches'] != null &&
        fetch['Choose Platforms'] != null) {
      List masterList = Defaults.allPlatforms;

      // List<String> firebaseUsernames = fetch['Usernames'].keys;

      masterList.forEach((key) {
        Social makeSocial = null;
        if (fetch['Usernames'][key] != null) {
          bool switchStatus = Map.of(fetch['Switches'])[key];
          bool isChosen = List.of(fetch['Profile Platforms']).contains(key);
          makeSocial = Social(
              username: fetch['Usernames'][key],
              platformName: key.toString(),
              switchStatus: switchStatus,
              isChosen: isChosen,
              usernameController:
                  TextEditingController(text: fetch['Usernames'][key]));
        } else {
          makeSocial = Social(
              username: "",
              platformName: key.toString(),
              switchStatus: false,
              isChosen: false,
              usernameController: TextEditingController(text: ""));
        }

        socials.add(makeSocial);
        lookupSocial[key] = makeSocial;
      });

      log("[⚙ Data Engine ⚙] SoshiUser Object built ✅");
    }

    //Building POINT_MANAGER_OBJECT
    PointManager pointManager = new PointManager(fetch);

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
        shortDynamicLink: shortDynamicLink,
        longDynamicLink: longDynamicLink,
        pointManager: pointManager);
  }

  static applyUserChanges(
      {@required SoshiUser user,
      @required bool cloud,
      @required bool local}) async {
    // {!} These tasks can happen asynchronously to save time!

    //Syncing controllers
    user.bio = user.bioController.text;
    user.firstName = user.firstNameController.text;
    user.lastName = user.lastNameController.text;

    globalUser = user;

    if (cloud || local) {
      Map afterSerialized = await serializeUser(user);

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
  String soshiUsername,
      firstName,
      lastName,
      photoURL,
      bio,
      shortDynamicLink,
      longDynamicLink;
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

  PointManager pointManager;

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
      @required this.shortDynamicLink,
      @required this.longDynamicLink,
      @required this.pointManager});

  //Will ignore case in input platform String
  getUsernameGivenPlatform({@required String platform}) {
    if (this.lookupSocial[platform] == null ||
        this.lookupSocial[platform] == "") {
      return Defaults.NO_USERNAME;
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
    this.lookupSocial.remove('Soshi');
    this.lookupSocial.values.forEach((element) {
      if (!element.isChosen) {
        toReturn.add(element);
      }
    });
    return toReturn;
  }

  List<Social> getSwitchedOnPlatforms() {
    List<Social> toReturn = [];
    this.lookupSocial.remove('Soshi');
    this.lookupSocial.values.forEach((element) {
      if (element.switchStatus == null || element.switchStatus) {
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
    this.lookupSocial[platformName].switchStatus = false;
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
          firebaseOverride: true, friendOverride: username);
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

  @override
  String toString() {
    return platformName;
  }
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
          soshiUsername: entry["Username"],
          fullName: entry["Name"],
          photoURL: entry["Url"],
          isVerified: entry["Verified"]));
    }
    print(data);
    return friends;
  }

  // convert friend to map, then map to json
  String serialize() {
    return jsonEncode(this.toJson());
  }
}

class Defaults {
  static String defaultProfilePic =
      "https://firebasestorage.googleapis.com/v0/b/soshi-bc9ec.appspot.com/o/DefaultAssets%2Fdefault_pic.png?alt=media&token=fe028bf9-449b-4ee5-a674-12e8d6e4f575";
  static Passion emptyPassion = Passion(emoji: "❌", name: "Empty");

  static const String NO_USERNAME = "NO_USERNAME";

  static List<String> allPlatforms = [
    "Phone",
    "Instagram",
    "Snapchat",
    "Linkedin",
    "Twitter",
    "Facebook",
    "Reddit",
    "Tiktok",
    "Discord",
    "Email",
    "Venmo",
    "Spotify",
    "Contact",
    "Personal",
    "Youtube",
    "Vsco",
    "AppleMusic",
    "CashApp",
    // "Soundcloud"
    "BeReal",
    "OnlyFans",
    //"Cryptowallet"
  ];
}
