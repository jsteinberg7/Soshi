// import 'dart:convert';

// /*
//   Used SharedPreferences package for local data storage
//   ** Note: Local Data must be initialized upon login and wiped upon logout
// */
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../screens/mainapp/friendScreen.dart';
// import 'dataEngine.dart';
// import 'database.dart';

// abstract class LocalDataService {
// // store all local data
//   static SharedPreferences preferences;

//   // adds initial preferences upon login
//   // ** must be run after user file is created in database

//   static Future<void> initializeSharedPreferences(
//       {String currSoshiUsername}) async {
//     // initialize SharedPreferences instance
//     preferences = await SharedPreferences.getInstance();

//     await preferences.setBool("firstSwitchTap", true);
//     // double brightness = await DeviceDisplayBrightness.getBrightness();

//     // await preferences.setDouble("screen_brightness", brightness);

//     // initialize DatabaseService to fetch updated values
//     DatabaseService databaseService =
//         new DatabaseService(currSoshiUsernameIn: currSoshiUsername);

//     DatabaseService databaseServiceV =
//         new DatabaseService(currSoshiUsernameIn: "#Verified Users");

//     Map userData = await databaseService.getUserFile(currSoshiUsername);

//     String bioFromDB = await databaseService.getBio(userData);
//     if (bioFromDB == null || bioFromDB == "") {
//       await preferences.setString("Bio", "");
//     } else {
//       await preferences.setString("Bio", bioFromDB);
//     }

//     int soshiPointsFromDB = await databaseService.getSoshiPoints(userData);
//     if (soshiPointsFromDB == null) {
//       await preferences.setInt("Soshi Points", 0);
//     } else {
//       await preferences.setInt("Soshi Points", soshiPointsFromDB);
//     }

//     // store first and last name map (used to set both first and last name)
//     Map<String, dynamic> fullName =
//         await databaseService.getFullNameMap(userData);
//     // set first name
//     await preferences.setString("First Name", fullName["First"]);
//     // set last name
//     await preferences.setString("Last Name", fullName["Last"]);
//     // set username
//     String username = await databaseService.getUsernameForPlatform(
//         userData: userData, platform: "Soshi");
//     await preferences.setString("Username", username);

//     List<dynamic> verifiedUsersDynamic =
//         await databaseServiceV.getVerifiedUsers();
//     List<String> verifiedUsersString = [];
//     for (dynamic verifiedUser in verifiedUsersDynamic) {
//       verifiedUsersString.add(verifiedUser);
//     }

//     print("Verified Users: " + verifiedUsersString.toString());

//     await preferences.setStringList("Verified Users", verifiedUsersString);

//     bool isVerified = verifiedUsersString.contains(currSoshiUsername);

//     await preferences.setBool("Verified Status", isVerified);

//     print("Verified Status: " + isVerified.toString());

//     try {
//       // set profile picture URL
//       await preferences.setString(
//           "Photo URL", await databaseService.getPhotoURL(userData));
//     } catch (e) {
//       await preferences.setString("Photo URL", "null");
//     }
//     // set social media platform usernames
//     // note: maps are not supported by SharedPreferences
//     // we must convert (encode) the map to a json and store it as a String
//     // to access Platform Usernames, we must use json.decode to convert to Map

//     Map<String, dynamic> userProfileNames =
//         await databaseService.getUserProfileNames(userData);

//     await preferences.setString(
//         "Platform Usernames", jsonEncode(userProfileNames));

//     // set social media platform switch states
//     await preferences.setString("Platform Switches",
//         jsonEncode(await databaseService.getUserSwitches(userData)));

//     // set choose platforms list to match cloud copy
//     List<dynamic> choosePlatformsDynamic =
//         await databaseService.getChoosePlatforms();

//     List<String> choosePlatforms = [];
//     for (dynamic platform in choosePlatformsDynamic) {
//       choosePlatforms.add(platform.toString());
//     }

//     await preferences.setStringList("Choose Platforms", choosePlatforms);

//     // set profile platforms list to match cloud copy
//     List<dynamic> profilePlatformsDynamic =
//         await databaseService.getProfilePlatforms();
//     List<String> profilePlatforms = [];
//     for (dynamic platform in profilePlatformsDynamic) {
//       profilePlatforms.add(platform);
//     }

//     print("DB from ISP" + profilePlatformsDynamic.toString());
//     print("Local from ISP" + profilePlatforms.toString());
//     await preferences.setStringList("Profile Platforms", profilePlatforms);

//     await preferences.setBool(
//         "Two Way Sharing", true); // two way sharing defaults to "on"

//     // set friends list
//     List<dynamic> friendsListDynamic =
//         await databaseService.getFriends(currSoshiUsername);
//     List<String> friendsListString = [];
//     for (dynamic friend in friendsListDynamic) {
//       friendsListString.add(friend.toString());
//     }
//     await preferences.setStringList("Sorted Friends List", friendsListString);
//     await preferences.setStringList("Recently Added Friends", []);
//     await preferences.setBool(
//         "Friends List Reformatted",
//         userData["Friends List Reformatted"] ??
//             false); // get friends list reformatted from db
//     if (preferences.getBool("Friends List Reformatted") == null ||
//         preferences.getBool("Friends List Reformatted") == false) {
//       // reformat friends list if necessary
//       await reformatFriendsList();
//     }
//   }

//   // clear all local data stored in SharedPreferences
//   static Future<void> wipeSharedPreferences() async {
//     await preferences.clear();
//     await preferences.setBool(
//         "firstSwitchTap", true); // ensure first_launch is preserved
//   }

//   /*
//   Getters for local data
//   ** note: local getters can only be used for the current user (not for friends)
//   */

//   // static List<String> getVerifiedUsers()  {
//   //   return
//   // }

//   static getInitialScreenBrightness() {
//     return preferences.getBool("screen_brightness");
//   }

//   static getTwoWaySharing() {
//     return preferences.getBool("Two Way Sharing");
//   }

//   static getInjectionFlag(String injectionName) {
//     return preferences.getBool("INJECTION $injectionName Flag") ?? false;
//   }

//   static getVerifiedUsersLocal() {
//     return preferences.getStringList("Verified Users") ?? [];
//   }

//   static getVerifiedStatus() {
//     return preferences.getBool("Verified Status") ?? false;
//   }

//   static getLocalUsername() {
//     try {
//       return preferences.getString("Username");
//     } catch (e) {
//       return "null";
//     }
//   }

//   static String getLocalFirstName() {
//     return preferences.getString("First Name");
//   }

//   static String getLocalLastName() {
//     return preferences.getString("Last Name");
//   }

//   static List<String> getLocalFriendsList() {
//     return preferences.getStringList("Sorted Friends List") ?? [];
//   }

//   // returns list of names with first letter capitalized
//   static List<String> getLocalFriendsListNames() {
//     List<String> friendsList = preferences.getStringList("Sorted Friends List");
//     List<String> namesList = [];
//     for (String json in friendsList) {
//       String currName = jsonDecode(json)["n"];
//       currName = currName[0].toUpperCase() +
//           currName.substring(1); // capitalize first letter
//       namesList.add(currName);
//     }
//     return namesList;
//   }

//   static Future<void> reformatFriendsList() async {
//     DatabaseService databaseService = new DatabaseService(
//         currSoshiUsernameIn: LocalDataService.getLocalUsername());
//     List<String> friendsList =
//         preferences.getStringList("Sorted Friends List") ??
//             preferences.getStringList("Friends List");
//     // replace each username w/ json
//     for (int i = 0; i < friendsList.length; i++) {
//       String username = friendsList[i];
//       var userData = await databaseService.getUserFile(username);
//       Friend friend = databaseService.userDataToFriend(userData);

//       friendsList[i] = friend.serialize();
//     }
//     // sort friendsList based on name
//     friendsList.sort((String json1, String json2) {
//       String name1 = jsonDecode(json1)["n"].toString().toLowerCase();
//       String name2 = jsonDecode(json2)["n"].toString().toLowerCase();
//       return (name1.compareTo(name2));
//     });
//     await preferences.setStringList(
//         "Sorted Friends List", friendsList); // inject sorted friends list
//     await preferences
//         .setStringList("Recently Added Friends", []); // inject recently added
//     await databaseService.overwriteFriendsList(friendsList);
//     await preferences.setBool("Friends List Reformatted", true);
//     databaseService
//         .setFriendsListReformatted(true); // update in db to save if logged out
//   }

//   static int getFriendsListCount() {
//     List friendsList = getLocalFriendsList();
//     int lengthOfFriendsList = friendsList.length;
//     return lengthOfFriendsList;
//   }

//   static String getLocalProfilePictureURL() {
//     return preferences.getString("Photo URL");
//   }

//   static Map<String, dynamic> getUserProfileNames() {
//     return jsonDecode(preferences.getString("Platform Usernames"))
//         as Map<String, dynamic>;
//   }

//   static Map<String, dynamic> getUserSwitches() {
//     return jsonDecode(preferences.getString("Platform Switches"));
//   }

//   // return local username for specified social media platform
//   static String getLocalUsernameForPlatform(String platform) {
//     return getUserProfileNames()["$platform"];
//   }

//   // return local switch state for specified social media platform
//   static bool getLocalStateForPlatform(String platform) {
//     return getUserSwitches()["$platform"];
//   }

//   // returning local list of platforms in choose socials page
//   static List<String> getLocalChoosePlatforms() {
//     return preferences.getStringList("Choose Platforms");
//   }

//   // return local list of profile platforms
//   static List<String> getLocalProfilePlatforms() {
//     return preferences.getStringList("Profile Platforms");
//   }

//   static Future<List<String>> getLocalProfilePlatformsSynced() async {
//     SharedPreferences newPrefs = await SharedPreferences.getInstance();
//     return newPrefs.getStringList("Profile Platforms");
//   }

//   static bool isFriendAdded(String friendUsername) {
//     List<String> friendsList =
//         preferences.getStringList("Sorted Friends List") ?? [];
//     for (int i = 0; i < friendsList.length; i++) {
//       Map<String, dynamic> friend = jsonDecode(friendsList[i]);
//       if (friend["u"] == friendUsername) {
//         // check each friend, check if usernames match
//         return true;
//       }
//     }
//     return false;
//   }

//   static bool friendsListReformatted() {
//     return preferences.getBool("Friends List Reformatted");
//   }

//   static bool hasLaunched() {
//     return preferences.getBool("hasLaunched") ?? false;
//   }

//   static bool getFirstSwitchTap() {
//     return preferences.getBool("firstSwitchTap");
//   }

//   static String getBio() {
//     return preferences.getString("Bio");
//   }

//   static int getSoshiPoints() {
//     return preferences.getInt("Soshi Points") ?? 0;
//   }

//   static bool hasCreatedDynamicLink() {
//     return preferences.getBool("Created Dynamic Link") ?? false;
//   }

//   static List<String> getRecentlyAddedFriends() {
//     return preferences.getStringList("Recently Added Friends") ?? [];
//   }

//   static List<Map> getPassionsListLocal() {
//     // return preferences.getStringList("passions") ?? [];
//     try {
//       return jsonDecode(preferences.getString("passions"));
//     } catch (e) {
//       return [];
//     }
//   }

//   static resetPassionsList() async {
//     // return preferences.getStringList("passions") ?? [];
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await preferences.setString("passions", jsonEncode([]));
//   }

//   /*
//   Setters
//   */

//   static Future<void> updateVerifiedStatus(bool isVerified) async {
//     await preferences.setBool("Verified Status", isVerified);
//   }

//   static Future<void> updateLocalPhotoURL(String URL) async {
//     await preferences.setString("Photo URL", URL);
//   }

//   static Future<void> updateTwoWaySharing(bool state) async {
//     await preferences.setBool("Two Way Sharing", state);
//   }

//   static Future<void> updateInjectionFlag(
//       String injectionName, bool state) async {
//     await preferences.setBool("INJECTION $injectionName Flag", state);
//   }

//   static Future<void> updateUsernameForPlatform(
//       {String platform, String username}) async {
//     // get copy of current usernames
//     String oldUsernamesJSON = preferences.getString("Platform Usernames");
//     // decode usernames json into map
//     Map<String, dynamic> usernamesDecoded = jsonDecode(oldUsernamesJSON);
//     // update map to reflect change
//     usernamesDecoded.update(platform, (value) => username,
//         ifAbsent: () => usernamesDecoded.addAll({platform: username}));
//     // update preferences to reflect new map
//     await preferences.setString(
//         "Platform Usernames", jsonEncode(usernamesDecoded));
//   }

//   static Future<void> updateSwitchForPlatform(
//       {String platform, bool state}) async {
//     // get copy of current usernames
//     String oldSwitchesJSON = preferences.getString("Platform Switches");
//     // decode usernames json into map
//     Map<String, dynamic> switchesDecoded = jsonDecode(oldSwitchesJSON);
//     // update map to reflect change
//     switchesDecoded.update(platform, (value) => state,
//         ifAbsent: () => switchesDecoded.addAll({platform: state}));

//     // update preferences to reflect new map
//     await preferences.setString(
//         "Platform Switches", jsonEncode(switchesDecoded));
//   }

//   static Future<List<String>> addFriend({@required Friend friend}) async {
//     // 2 parts:
//     // - add to recents
//     // - insert into sorted list
//     print(">> adding friend");

//     await addToRecentFriends(friend: friend);
//     List<String> sortedFriendsList =
//         await getLocalFriendsList(); // assume list is already sorted

//     String json = friend.serialize();
//     if (sortedFriendsList.isEmpty) {
//       // if empty, simply add to beginning
//       sortedFriendsList.add(json);
//     } else {
//       friend.fullName = friend.fullName
//           .toUpperCase(); // convert fullName to uppercase for comparison
//       // find correct place for new friend
//       int insertIndex = sortedFriendsList.length;
//       print(">> in else");
//       for (int i = 0; i < sortedFriendsList.length; i++) {
//         // find index to insert to element
//         Map currFriend = jsonDecode(sortedFriendsList[i]);
//         String currFullName = currFriend["n"].toString().toUpperCase();
//         print(">> comparing ${friend.fullName} to $currFullName");
//         if (friend.fullName.compareTo(currFullName) <= 0) {
//           insertIndex = i;
//           break;
//         }
//       }
//       print(">> INSERTING " + friend.soshiUsername);
//       sortedFriendsList.insert(insertIndex, json); // insert new friend
//     }
//     await preferences.setStringList("Sorted Friends List", sortedFriendsList);
//     return sortedFriendsList;
//   }


//   static Future<void> addToRecentFriends({@required Friend friend}) async {
//     List<String> recentlyAddedFriends = getRecentlyAddedFriends();
//     String json = friend.serialize();
//     int len = recentlyAddedFriends.length;
//     if (len < 5) {
//       // if space, simply add to beginning of list
//       recentlyAddedFriends.insert(0, json);
//     } else {
//       // if list is full (length 5), add to beginning and remove last element from end
//       recentlyAddedFriends.insert(0, json);
//       recentlyAddedFriends.removeAt(5);
//     }
//     await preferences.setStringList(
//         "Recently Added Friends", recentlyAddedFriends);
//   }

//   // remove friend with username
//   // return updated friends list
//   static Future<List<String>> removeFriend({String friendsoshiUsername}) async {
//     List<String> friendsList =
//         preferences.getStringList("Sorted Friends List") ?? [];
//     for (int i = 0; i < friendsList.length; i++) {
//       Map friend = jsonDecode(friendsList[i]);
//       if (friend["u"] == friendsoshiUsername) {
//         // if usernames match, remove friend
//         friendsList.removeAt(i);
//         await preferences.setStringList("Sorted Friends List", friendsList);
//         break;
//       }
//     }
//     // also remove from recents
//     List<String> recentsList = getRecentlyAddedFriends();
//     for (int i = 0; i < recentsList.length; i++) {
//       Map friend = jsonDecode(recentsList[i]);
//       if (friend["u"] == friendsoshiUsername) {
//         // if usernames match, remove friend
//         recentsList.removeAt(i);
//         await preferences.setStringList("Recently Added Friends", recentsList);
//         break;
//       }
//     }
//     return friendsList;
//   }

//   static Future<void> updateFirstName(String firstName) async {
//     await preferences.setString("First Name", firstName);
//   }

//   static Future<void> updateLastName(String lastName) async {
//     await preferences.setString("Last Name", lastName);
//   }

//   static Future<void> addPlatformsToProfile(List<String> platformsQueue) async {
//     // get current copy of profile platforms
//     List<String> profilePlatforms = getLocalProfilePlatforms();
//     // add platforms in queue to profile platforms
//     profilePlatforms += platformsQueue;
//     // update shared preferences to reflect change
//     preferences.setStringList("Profile Platforms", profilePlatforms);
//   }

//   // removes Queue from choosePlatforms **goes hand-in-hand with addPlatformsToProfile
//   static Future<void> removeFromChoosePlatforms(
//       List<String> platformsQueue) async {
//     // getting the local list of choose platforms
//     List<String> choosePlatforms = getLocalChoosePlatforms();
//     // iterated through the queue and removes the "platforms" in the local list 1 by 1
//     for (int i = 0; i < platformsQueue.length; i++) {
//       choosePlatforms.remove(platformsQueue[i]);
//     }
//     // update local Choose Platforms to shared preferences to reflect changes visually
//     preferences.setStringList("Choose Platforms", choosePlatforms);
//   }

//   // removes single platform from local "Profile Platforms" list
//   static Future<void> removePlatformsFromProfile(String platform) async {
//     List<String> profilePlatforms = getLocalProfilePlatforms();
//     profilePlatforms.remove(platform);
//     preferences.setStringList("Profile Platforms", profilePlatforms);
//   }

//   // adds a single platform to the local "Choose Platforms" list
//   static Future<void> addToChoosePlatforms(String platform) async {
//     // get current copy of choose platforms
//     List<String> choosePlatforms = getLocalChoosePlatforms();
//     // add platforms in queue to choose platforms (don't add again if already added)
//     if (!choosePlatforms.contains(platform)) {
//       choosePlatforms.add(platform);
//     }
//     // update shared preferences to reflect change
//     preferences.setStringList("Choose Platforms", choosePlatforms);
//   }

//   static Future<void> updateFirstSwitchTap(bool newValue) async {
//     await preferences.setBool("firstSwitchTap", newValue);
//   }

//   static Future<void> updateFirstLaunch(bool newValue) async {
//     await preferences.setBool("hasLaunched", newValue);
//   }

//   static Future<void> updateBio(String newBio) async {
//     await preferences.setString("Bio", newBio);
//   }

//   static Future<void> updateSoshiPoints(int addedPoints) async {
//     int newSoshiPoints = LocalDataService.getSoshiPoints() + addedPoints;
//     await preferences.setInt("Soshi Points", newSoshiPoints);
//   }

// // SRI : update local preferences with string list of passions (must also sync with firebase)
//   static Future<void> updatePassions(List overridePassionList) async {
//     await preferences.setString("passions", jsonEncode(overridePassionList));
//     // await preferences.setStringList("passions", overridePassionList);
//   }
// }
