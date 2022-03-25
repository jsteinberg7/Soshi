import 'dart:convert';

/*
  Used SharedPreferences package for local data storage
  ** Note: Local Data must be initialized upon login and wiped upon logout
*/
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';

abstract class LocalDataService {
// store all local data
  static SharedPreferences preferences;

  // adds initial preferences upon login
  // ** must be run after user file is created in database

  static Future<void> initializeSharedPreferences(
      {String currSoshiUsername}) async {
    // initialize SharedPreferences instance
    preferences = await SharedPreferences.getInstance();

    await preferences.setBool("firstSwitchTap", true);
    double brightness = await DeviceDisplayBrightness.getBrightness();

    await preferences.setDouble("screen_brightness", brightness);

    // initialize DatabaseService to fetch updated values
    DatabaseService databaseService =
        new DatabaseService(currSoshiUsernameIn: currSoshiUsername);

    Map userData = await databaseService.getUserFile(currSoshiUsername);

    String bioFromDB = await databaseService.getBio(userData);
    if (bioFromDB == null || bioFromDB == "") {
      await preferences.setString("Bio", "");
    } else {
      await preferences.setString("Bio", bioFromDB);
    }

    // store first and last name map (used to set both first and last name)
    Map<String, dynamic> fullName =
        await databaseService.getFullNameMap(userData);
    // set first name
    await preferences.setString("First Name", fullName["First"]);
    // set last name
    await preferences.setString("Last Name", fullName["Last"]);
    // set username
    String username = await databaseService.getUsernameForPlatform(
        userData: userData, platform: "Soshi");
    await preferences.setString("Username", username);

    // set friends list
    List<dynamic> friendsListDynamic =
        await databaseService.getFriends(currSoshiUsername);
    List<String> friendsListString = [];
    for (dynamic friend in friendsListDynamic) {
      friendsListString.add(friend.toString());
    }
    await preferences.setStringList("Friends List", friendsListString);

    try {
      // set profile picture URL
      await preferences.setString(
          "Photo URL", await databaseService.getPhotoURL(userData));
    } catch (e) {
      await preferences.setString("Photo URL", "null");
    }
    // set social media platform usernames
    // note: maps are not supported by SharedPreferences
    // we must convert (encode) the map to a json and store it as a String
    // to access Platform Usernames, we must use json.decode to convert to Map

    Map<String, dynamic> userProfileNames =
        await databaseService.getUserProfileNames(userData);

    await preferences.setString(
        "Platform Usernames", jsonEncode(userProfileNames));

    // set social media platform switch states
    await preferences.setString("Platform Switches",
        jsonEncode(await databaseService.getUserSwitches(userData)));

    // set choose platforms list to match cloud copy
    List<dynamic> choosePlatformsDynamic =
        await databaseService.getChoosePlatforms();

    List<String> choosePlatforms = [];
    for (dynamic platform in choosePlatformsDynamic) {
      choosePlatforms.add(platform.toString());
    }

    await preferences.setStringList("Choose Platforms", choosePlatforms);

    // set profile platforms list to match cloud copy
    List<dynamic> profilePlatformsDynamic =
        await databaseService.getProfilePlatforms();
    List<String> profilePlatforms = [];
    for (dynamic platform in profilePlatformsDynamic) {
      profilePlatforms.add(platform);
    }
    await preferences.setStringList("Profile Platforms", profilePlatforms);

    await preferences.setBool(
        "Two Way Sharing", true); // two way sharing defaults to "on"
  }

  // clear all local data stored in SharedPreferences
  static Future<void> wipeSharedPreferences() async {
    await preferences.clear();
    await preferences.setBool(
        "firstSwitchTap", true); // ensure first_launch is preserved
  }

  /*
  Getters for local data
  ** note: local getters can only be used for the current user (not for friends)
  */

  static getInitialScreenBrightness() {
    return preferences.getBool("screen_brightness");
  }

  static getTwoWaySharing() {
    return preferences.getBool("Two Way Sharing");
  }

  static getLocalUsername() {
    try {
      return preferences.getString("Username");
    } catch (e) {
      return "null";
    }
  }

  static String getLocalFirstName() {
    return preferences.getString("First Name");
  }

  static String getLocalLastName() {
    return preferences.getString("Last Name");
  }

  static List<String> getLocalFriendsList() {
    return preferences.getStringList("Friends List");
  }

  static int getFriendsListCount() {
    List friendsList = getLocalFriendsList();
    int lengthOfFriendsList = friendsList.length;
    return lengthOfFriendsList;
  }

  static String getLocalProfilePictureURL() {
    return preferences.getString("Photo URL");
  }

  static Map<String, dynamic> getUserProfileNames() {
    return jsonDecode(preferences.getString("Platform Usernames"))
        as Map<String, dynamic>;
  }

  static Map<String, dynamic> getUserSwitches() {
    return jsonDecode(preferences.getString("Platform Switches"));
  }

  // return local username for specified social media platform
  static String getLocalUsernameForPlatform(String platform) {
    return getUserProfileNames()["$platform"];
  }

  // return local switch state for specified social media platform
  static bool getLocalStateForPlatform(String platform) {
    return getUserSwitches()["$platform"];
  }

  // returning local list of platforms in choose socials page
  static List<String> getLocalChoosePlatforms() {
    return preferences.getStringList("Choose Platforms");
  }

  // return local list of profile platforms
  static List<String> getLocalProfilePlatforms() {
    return preferences.getStringList("Profile Platforms");
  }

  static bool isFriendAdded(String friendUsername) {
    return getLocalFriendsList().contains(friendUsername);
  }

  static bool hasLaunched() {
    return preferences.getBool("hasLaunched") ?? false;
  }

  static bool getFirstSwitchTap() {
    return preferences.getBool("firstSwitchTap");
  }

  static String getBio() {
    return preferences.getString("Bio");
  }

  static bool hasCreatedDynamicLink() {
    return preferences.getBool("Created Dynamic Link");
  }

  /*
  Setters
  */
  static Future<void> updateLocalPhotoURL(String URL) async {
    await preferences.setString("Photo URL", URL);
  }

  static Future<void> updateTwoWaySharing(bool state) async {
    await preferences.setBool("Two Way Sharing", state);
  }

  static Future<void> updateUsernameForPlatform(
      {String platform, String username}) async {
    // get copy of current usernames
    String oldUsernamesJSON = preferences.getString("Platform Usernames");
    // decode usernames json into map
    Map<String, dynamic> usernamesDecoded = jsonDecode(oldUsernamesJSON);
    // update map to reflect change
    usernamesDecoded.update(platform, (value) => username,
        ifAbsent: () => usernamesDecoded.addAll({platform: username}));
    // update preferences to reflect new map
    await preferences.setString(
        "Platform Usernames", jsonEncode(usernamesDecoded));
  }

  static Future<void> updateSwitchForPlatform(
      {String platform, bool state}) async {
    // get copy of current usernames
    String oldSwitchesJSON = preferences.getString("Platform Switches");
    // decode usernames json into map
    Map<String, dynamic> switchesDecoded = jsonDecode(oldSwitchesJSON);
    // update map to reflect change
    switchesDecoded.update(platform, (value) => state,
        ifAbsent: () => switchesDecoded.addAll({platform: state}));

    // update preferences to reflect new map
    await preferences.setString(
        "Platform Switches", jsonEncode(switchesDecoded));
  }

  static Future<void> addFriend({String friendsoshiUsername}) async {
    List<String> friendsList = preferences.getStringList("Friends List");
    friendsList.add(friendsoshiUsername);
    await preferences.setStringList("Friends List", friendsList);
  }

  static Future<void> removeFriend({String friendsoshiUsername}) async {
    List<String> friendsList = preferences.getStringList("Friends List");
    friendsList.remove(friendsoshiUsername);
    await preferences.setStringList("Friends List", friendsList);
  }

  static Future<void> updateFirstName(String firstName) async {
    await preferences.setString("First Name", firstName);
  }

  static Future<void> updateLastName(String lastName) async {
    await preferences.setString("Last Name", lastName);
  }

  static Future<void> addPlatformsToProfile(List<String> platformsQueue) async {
    // get current copy of profile platforms
    List<String> profilePlatforms = getLocalProfilePlatforms();
    // add platforms in queue to profile platforms
    profilePlatforms += platformsQueue;
    // update shared preferences to reflect change
    preferences.setStringList("Profile Platforms", profilePlatforms);
  }

  // removes Queue from choosePlatforms **goes hand-in-hand with addPlatformsToProfile
  static Future<void> removeFromChoosePlatforms(
      List<String> platformsQueue) async {
    // getting the local list of choose platforms
    List<String> choosePlatforms = getLocalChoosePlatforms();
    // iterated through the queue and removes the "platforms" in the local list 1 by 1
    for (int i = 0; i < platformsQueue.length; i++) {
      choosePlatforms.remove(platformsQueue[i]);
    }
    // update local Choose Platforms to shared preferences to reflect changes visually
    preferences.setStringList("Choose Platforms", choosePlatforms);
  }

  // removes single platform from local "Profile Platforms" list
  static Future<void> removePlatformsFromProfile(String platform) async {
    List<String> profilePlatforms = getLocalProfilePlatforms();
    profilePlatforms.remove(platform);
    preferences.setStringList("Profile Platforms", profilePlatforms);
  }

  // adds a single platform to the local "Choose Platforms" list
  static Future<void> addToChoosePlatforms(String platform) async {
    // get current copy of choose platforms
    List<String> choosePlatforms = getLocalChoosePlatforms();
    // add platforms in queue to choose platforms (don't add again if already added)
    if (!choosePlatforms.contains(platform)) {
      choosePlatforms.add(platform);
    }
    // update shared preferences to reflect change
    preferences.setStringList("Choose Platforms", choosePlatforms);
  }

  static Future<void> updateFirstSwitchTap(bool newValue) async {
    await preferences.setBool("firstSwitchTap", newValue);
  }

  static Future<void> updateFirstLaunch(bool newValue) async {
    await preferences.setBool("hasLaunched", newValue);
  }

  static Future<void> updateBio(String newBio) async {
    await preferences.setString("Bio", newBio);
  }
}
