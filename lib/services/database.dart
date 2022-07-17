import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:soshi/screens/mainapp/groupScreen.dart';

import '../screens/mainapp/friendScreen.dart';
import 'contacts.dart';
import 'dynamicLinks.dart';
import 'localData.dart';

/*
 Includes getters and setters for various fields in the Firebase database
 */
class DatabaseService {
  // currSoshiUsername of user
  String currSoshiUsername;

  // Basic constructor
  DatabaseService({String currSoshiUsernameIn}) {
    currSoshiUsername = currSoshiUsernameIn;
  }

  // store reference to all user files
  CollectionReference usersCollection = FirebaseFirestore.instance.collection("users");

  // store reference to all group files
  CollectionReference groupsCollection = FirebaseFirestore.instance.collection("groups");

  // store reference to all email-username link files
  CollectionReference emailToUsernameCollection =
      FirebaseFirestore.instance.collection("emailToUsername");
  /*
  Creates file for new user
  */
  Future<void> createUserFile({String username, String email, String first, String last}) async {
    var links = FirebaseDynamicLinks.instance; // register dynamic link
    // links.buildShortLink(DynamicLinkParameters(link: link, uriPrefix: uriPrefix));
    await emailToUsernameCollection.doc(email).set(<String, dynamic>{"soshiUsername": username});
    String phoneNumber = await SmsAutoFill().hint;
    await usersCollection.doc(currSoshiUsername).set(<String, dynamic>{
      "Name": {"First": first, "Last": last},
      "Friends": <String>["soshi"],
      "Bio": "",
      "Verified": false,
      "Soshi Points": 0,
      "Usernames": <String, String>{
        "Soshi": username,
        "Phone": phoneNumber,
        "Personal": null,
        //"Cryptowallet": null,
        "Instagram": null,
        "Snapchat": null,
        "Linkedin": null,
        "Venmo": null,
        "Twitter": null,
        "Tiktok": null,
        "Spotify": null,
        "Youtube": null,
        "Facebook": null,
        // "Reddit": null,
        "Discord": null,
        "Email": email,
        "Contact": null,
        "AppleMusic": null,
        "CashApp": null,
        "Vsco": null,
        "OnlyFans": null,
        "BeReal": null
      },
      "Two Way Sharing": true,
      "Switches": <String, bool>{
        "Phone": (phoneNumber != null),
        "Instagram": false,
        "Snapchat": false,
        "Linkedin": false,
        "Twitter": false,
        "Facebook": false,
        // "Reddit": false,
        "Tiktok": false,
        "Youtube": false,
        "Discord": false,
        "Email": false,
        "Venmo": false,
        "Spotify": false,
        "Personal": false,
        "AppleMusic": false,
        "CashApp": false,
        "Vsco": false,
        "OnlyFans": false,
        "BeReal": false

        //"Cryptowallet": false
      },
      "Photo URL": "null",
      "Choose Platforms": <String>[
        //"Cryptowallet",
        "Personal",
        "Instagram",
        "Snapchat",
        "Venmo",
        "CashApp",
        "Twitter",
        "Vsco",
        "Tiktok",
        "Linkedin",
        "BeReal",
        "Youtube",
        "Spotify",
        "AppleMusic",
        "OnlyFans",
        "Email",
        "Facebook",
        "Discord",

        // "Reddit",
      ],
      "Profile Platforms": <String>["Phone"],
      "INJECTION Soshi Points Flag": true,
      "INJECTION Profile Pic Flag": false,
      "INJECTION Bio Flag": false,
      "INJECTION Passions Flag": false,
      "Groups": []
    });
    await DynamicLinkService.createDeepLink(username);
  }

  /*
  Convert userData to Friend
  */
  Friend userDataToFriend(Map userData) {
    return new Friend(
        fullName: getFullName(userData),
        soshiUsername: getUsernameForPlatform(userData: userData, platform: "Soshi"),
        photoURL: getPhotoURL(userData),
        isVerified: getVerifiedStatus(userData),
        switches: getUserSwitches(userData),
        usernames: getUserProfileNames(userData));
  }

  /*
  Getting the list of verified users
  */

  Future<List<dynamic>> getVerifiedUsers() async {
    List<dynamic> verifiedUsers;
    await usersCollection.doc("#Verified Users").get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      verifiedUsers = data["Verified Users"];
    });

    return verifiedUsers;
  }

  /*
  METHODS PERTAINING TO UPDATING USER DATA (SETTERS)
  */
  // see following reference: https://pub.dev/packages/cloud_firestore/example

  // updates username for specified social media platform
  Future<void> updateUsernameForPlatform({String platform, String username}) async {
    // get user data
    Map userData = await getUserFile(currSoshiUsername);
    // get current map of usernames
    Map<String, dynamic> usernamesMap = getUserProfileNames(userData);
    // update local map to reflect change
    usernamesMap[platform] = username;
    // update database to reflect local map change
    await usersCollection.doc(currSoshiUsername).update({"Usernames": usernamesMap});
    // if email or phone is updated, update contact card vcf
    if (platform == "Email" || platform == "Phone") {
      await updateContactCard();
    }
  }

  // updates switch for given platform
  Future<void> updatePlatformSwitch({String platform, bool state}) async {
    Map<String, dynamic> switches;
    await usersCollection.doc(currSoshiUsername).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      switches = data["Switches"];
    });
    // update map locally
    switches["$platform"] = state;
    // upload change to database
    return await usersCollection.doc(currSoshiUsername).update({"Switches": switches});
  }

  // upload selected image to Firebse Storage, return URL
  Future<String> uploadProfilePicture(File image, {groupId = null}) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    // upload image
    File file = new File(image.path);
    if (groupId != null) {
      await firebaseStorage.ref().child("Profile Pictures/" + groupId).putFile(file);
      return await FirebaseStorage.instance
          .ref()
          .child("Profile Pictures/" + groupId)
          .getDownloadURL();
    } else {
      await firebaseStorage.ref().child("Profile Pictures/" + currSoshiUsername).putFile(file);
      return await FirebaseStorage.instance
          .ref()
          .child("Profile Pictures/" + currSoshiUsername)
          .getDownloadURL();
    }
  }

  // update profile picture URL (necessary on first profile pic change)
  Future<void> updateUserProfilePictureURL(String URL) async {
    await usersCollection.doc(currSoshiUsername).update({"Photo URL": URL});
  }

  // upload selected image to Firebase Storage, return URL
  Future<String> uploadContactCard(VCard vCard) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    File file = await vCard.generateVcf(currSoshiUsername);
    dynamic child = firebaseStorage.ref().child("VCards/$currSoshiUsername Contact Card.vcf");
    await child.putFile(file); // upload vCard to Firebase Storage
    return await child.getDownloadURL();
  }

  Future<void> updateContactCard() async {
    // {?} Putting the soshi username into the contact card
    // create new VCard
    VCard vCard = new VCard(
        soshiUsernameIn: currSoshiUsername,
        firstNameIn: LocalDataService.getLocalFirstName(),
        lastNameIn: LocalDataService.getLocalLastName(),
        emailIn: LocalDataService.getLocalUsernameForPlatform("Email"),
        phoneIn: LocalDataService.getLocalUsernameForPlatform("Phone"));
    // upload contact card to firebase storage
    String vcfLink = await uploadContactCard(vCard);
    // set link in database to point toward storage
    LocalDataService.updateUsernameForPlatform(platform: "Contact", username: vcfLink);

    updateUsernameForPlatform(platform: "Contact", username: vcfLink);
  }

  /*
  METHODS PERTAINING TO FRIENDS LIST
  */
  // add new friend to current user's friend list
  Future<void> addFriend(
      {@required String thisSoshiUsername, @required String friendSoshiUsername}) async {
    // get copy of current friends list
    List<dynamic> friendsList = await getFriends(thisSoshiUsername);

    // check to see if list already exists
    if (friendsList == null) {
      // create new list
      friendsList = [friendSoshiUsername];
    } else {
      // add new friend to list
      if (!friendsList.contains(friendSoshiUsername)) {
        // ensure friend isn't already added
        friendsList.add(friendSoshiUsername);
      }
    }

    await usersCollection.doc(thisSoshiUsername).update({"Friends": friendsList});

    // usersCollection.doc(friendSoshiUsername).update({"Added Me": addedMeList})
  }

  Future<void> overwriteFriendsList(List<String> newFriendsList) async {
    await usersCollection.doc(currSoshiUsername).update({"Friends": newFriendsList});
  }

  Future<void> setFriendsListReformatted(bool hasReformatted) async {
    await usersCollection
        .doc(this.currSoshiUsername)
        .update({"Friends List Reformatted": hasReformatted});
  }

  // remove friend from current user's friend list
  Future<void> removeFriend({String friendSoshiUsername}) async {
    List<dynamic> friendsList;
    // get current friends list from database
    friendsList = await getFriends(currSoshiUsername);
    // remove friend from local list
    friendsList.remove(friendSoshiUsername);
    // update database to reflect change
    await usersCollection.doc(currSoshiUsername).update({"Friends": friendsList});
  }

  // return list of friends for current user (for use with friends screen)
  Future<List<dynamic>> getFriends(String currSoshiUsernameParam) async {
    List<dynamic> friendsList;
    await usersCollection.doc(currSoshiUsernameParam).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      friendsList = data["Friends"];
    });
    return friendsList;
  }

  // checks if friend is already in user's friend list
  Future<bool> isFriendAdded(String otherSoshiUsername) async {
    List<dynamic> friendsList = await getFriends(currSoshiUsername);
    return friendsList.contains(otherSoshiUsername);
  }

  // return list of friends for current user (for use with friends screen)
  Future<List<dynamic>> getAddedMeList(String othercurrSoshiUsername) async {
    List<dynamic> addedMeList;
    await usersCollection.doc(othercurrSoshiUsername).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      addedMeList = data["Added Me"];
    });
    print("data in db + " + addedMeList.toString());
    return addedMeList;
  }

  // add new friend to current user's Added ME list
  Future<void> addToAddedMeList({String othercurrSoshiUsername}) async {
    // get copy of current Added Me list
    List<dynamic> addedMeList = await getAddedMeList(othercurrSoshiUsername);

    // check to see if list already exists
    if (addedMeList == null) {
      // create new list
      addedMeList = [othercurrSoshiUsername];
    } else {
      // add new user to list
      addedMeList.add(othercurrSoshiUsername);
    }

    return await usersCollection.doc(currSoshiUsername).update({"Added Me": addedMeList});
  }

  // remove friend from current user's friend list
  Future<void> removeFromAddedMeList(String friendcurrSoshiUsername) async {
    List<dynamic> addedMeList;
    // get current friends list from database
    addedMeList = await getAddedMeList(friendcurrSoshiUsername);
    // remove friend from local list
    addedMeList.remove(friendcurrSoshiUsername);
    // update database to reflect change
    await usersCollection.doc(currSoshiUsername).update({"Added Me": addedMeList});
  }

  /*
  Methods pertaining to getting user data
  */

  Future<Map> getUserFile(String username) async {
    dynamic data;
    await usersCollection.doc(username).get().then((DocumentSnapshot ds) {
      data = ds.data();
    });
    return data;
  }

  // pass in currSoshiUsername, return map of user switches (platform visibility)
  Map<String, dynamic> getUserSwitches(Map userData) {
    return userData["Switches"];
  }

  List<String> getPassions(Map userData) {
    return userData["Passions"] ?? [];
  }

  // return list of enabled user switches
  List<String> getEnabledPlatformsList(Map userData) {
    Map<String, dynamic> platformsMap = getUserSwitches(userData);

    List<String> enabledPlatformsList = [];
    // add all enabled platforms to platformsList
    platformsMap.forEach((platform, state) {
      if (state == true) {
        enabledPlatformsList.add(platform);
      }
    });

    return enabledPlatformsList;
  }

  // pass in currSoshiUsername, return (Map) of user profile names
  Map<String, dynamic> getUserProfileNames(Map userData) {
    return userData["Usernames"];
  }

  // return username for specified platform
  String getUsernameForPlatform({@required Map userData, @required String platform}) {
    String username;
    Map<String, dynamic> profileNamesMap = getUserProfileNames(userData);
    username = profileNamesMap[platform];
    return username;
  }

  // pass in currSoshiUsername, return (Map) of full name of user
  Map<String, dynamic> getFullNameMap(Map userData) {
    return userData["Name"];
  }

  // get state of two way sharing of user
  bool getTwoWaySharing(Map userData) {
    return userData["Two Way Sharing"];
  }

  // pass in soshiUsername, return (String) full name of user
  String getFullName(Map userData) {
    Map fullNameMap = getFullNameMap(userData);
    // convert to String
    String fullName = fullNameMap["First"] + " " + fullNameMap["Last"];
    return fullName;
  }

  String getPhotoURL(Map userData) {
    return userData["Photo URL"];
  }

  Future<List<dynamic>> getProfilePlatforms() async {
    dynamic data;
    await usersCollection.doc(currSoshiUsername).get().then((DocumentSnapshot ds) {
      data = ds.data();
    });
    return data["Profile Platforms"];
  }

  Future<List<dynamic>> getChoosePlatforms() async {
    dynamic data;
    await usersCollection.doc(currSoshiUsername).get().then((DocumentSnapshot ds) {
      data = ds.data();
    });
    return data["Choose Platforms"];
  }

  Future<void> addPlatformsToProfile(List<String> platformsQueue) async {
    // get current list
    List<dynamic> profilePlatforms = await getProfilePlatforms();
    // add new platforms to list
    profilePlatforms += platformsQueue;
    // update database list to reflect changes
    return await usersCollection
        .doc(currSoshiUsername)
        .update({"Profile Platforms": profilePlatforms});
  }

  //When a user takes out platform(s) from CHOOSESOCIALS, it gets popped from chooseSocials
  Future<void> removeFromChoosePlatforms(List<String> platformsQueue) async {
    List<dynamic> choosePlatformsList = await getChoosePlatforms();
    // remove all items in platformsQueue from chooseSocials
    for (int i = 0; i < platformsQueue.length; i++) {
      choosePlatformsList.remove(platformsQueue[i]);
    }
    return await usersCollection
        .doc(currSoshiUsername)
        .update({"Choose Platforms": choosePlatformsList});
  }

  // Remove single platform from the profile platforms list
  Future<void> removePlatformFromProfile(String platform) async {
    List<dynamic> profilePlatforms = await getProfilePlatforms();
    profilePlatforms.remove(platform);
    return await usersCollection
        .doc(currSoshiUsername)
        .update({"Profile Platforms": profilePlatforms});
  }

  //When a user takes out a platform from their PROFILE, it gets put back in chooseSocials
  Future<void> addToChoosePlatforms(String platform) async {
    // The parameter is a string not a list b/c the user individually removes the platform(s) from their profile
    List<dynamic> choosePlatformsList = await getChoosePlatforms();
    if (!choosePlatformsList.contains(platform)) {
      choosePlatformsList.add(platform);
    }

    return await usersCollection
        .doc(currSoshiUsername)
        .update({"Choose Platforms": choosePlatformsList});
  }

//get first name of Display Name
  Future<String> getFirstDisplayName(Map userData) async {
    String firstName;
    Map<String, dynamic> fullNameMap = getFullNameMap(userData);
    firstName = fullNameMap["First"];
    return firstName;
  }

  Future<void> updateDisplayName({String firstNameParam, String lastNameParam}) async {
    Map userData = await getUserFile(currSoshiUsername);
    //get current map of display name
    Map<String, dynamic> displayNameMap = getFullNameMap(userData);
    //update local map to reflect change
    displayNameMap["First"] = firstNameParam;
    displayNameMap["Last"] = lastNameParam;
    //update to databse to reflect local map changes
    await usersCollection.doc(currSoshiUsername).update({"Name": displayNameMap});
    // update contact card vcf in database if name is changed
    await updateContactCard();
  }

  String getLastDisplayName(Map userData) {
    String lastName;
    Map<String, dynamic> fullName = getFullNameMap(userData);
    lastName = fullName["Last"];

    // await usersCollection.doc(currSoshiUsername).get().then(
    //     (DocumentSnapshot ds) => lastDisplayName = ds.data()["Name"]["Last"]);
    return lastName;
  }

  Future<int> getFriendsCount(String soshiUsernameParam) async {
    List<dynamic> friendsList = await getFriends(soshiUsernameParam);
    int friendsCount = friendsList.length;
    return friendsCount;
  }

  String getEmail(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return user.email;
  }

  // pass in currSoshiUsername, return (Map) of full name of user
  Future<String> getSoshiUsernameForLogin({String email}) async {
    String currSoshiUsername;
    await emailToUsernameCollection.doc(email).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      currSoshiUsername = data["soshiUsername"];
    });
    return currSoshiUsername;
  }

  Future<File> cropImage(String path, {CropStyle cropStyle = CropStyle.circle}) async {
    return (await ImageCropper().cropImage(
        cropStyle: cropStyle,
        sourcePath: path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxHeight: 700,
        maxWidth: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(toolbarColor: Colors.cyan, toolbarTitle: "Crop Image"),
        iosUiSettings: IOSUiSettings(
          title: "Crop Image",
        )));
  }

  // for use with profile (not groups)
  Future<void> cropAndUploadImage(
    PickedFile passedInImage,
  ) async {
    if (passedInImage != null) {
      File croppedImage = await cropImage(passedInImage.path);

      String currSoshiUsername = LocalDataService.getLocalUsernameForPlatform("Soshi");
      DatabaseService databaseService = new DatabaseService(currSoshiUsernameIn: currSoshiUsername);
      await databaseService.uploadProfilePicture(croppedImage);
      String url = await FirebaseStorage.instance
          .ref()
          .child("Profile Pictures/" + currSoshiUsername)
          .getDownloadURL();
      await LocalDataService.updateLocalPhotoURL(url);
      databaseService.updateUserProfilePictureURL(url);
    } else {
      print("No image picked");
      return;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    dynamic usernameCheck;
    await usersCollection.doc(username).get().then((DocumentSnapshot ds) {
      usernameCheck = ds.data();
    });
    return (usernameCheck != null);
  }

  Future<void> deleteProfileData() async {
    String email = LocalDataService.getLocalUsernameForPlatform("Email");
    String photoURL = LocalDataService.getLocalUsernameForPlatform("Photo URL");
    // delete profile picture (if N/A, skip by catching error)
    try {
      await FirebaseStorage.instance.ref().child("Profile Pictures/" + currSoshiUsername).delete();
    } catch (e) {}

    await emailToUsernameCollection.doc(email).delete();
    await usersCollection.doc(currSoshiUsername).delete();
  }

  String getBio(Map userData) {
    return userData["Bio"];
  }

  Future<void> updateBio(String soshiUser, String newBio) async {
    await usersCollection.doc(soshiUser).update({"Bio": newBio});
  }

  bool getVerifiedStatus(Map userData) {
    return userData["Verified"];
    // if (isVerified == null) {
    //   isVerified == false;
    // }
  }

  Future<void> updateVerifiedStatus(String soshiUser, bool isVerified) async {
    await usersCollection.doc(soshiUser).update({"Verified": isVerified});
  }

  Future<void> updateUserPassions(String soshiUser, List newPassions) async {
    await usersCollection.doc(soshiUser).update({"passions": newPassions});
  }
  // bool isFirstTime() {
  //    (await IsFirstRun.isFirstRun()) ? return true : return false;
  //   // bool check = await IsFirstRun.isFirstRun();
  //   // return check;
  // }

  Future<void> updateTwoWaySharing(bool state) async {
    await usersCollection.doc(currSoshiUsername).update({"Two Way Sharing": state});
  }

  int getSoshiPoints(Map userData) {
    return userData["Soshi Points"];
  }

  Future<void> updateSoshiPoints(String soshiUsername, int addedPoints) async {
    int newSoshiPoints = LocalDataService.getSoshiPoints() + addedPoints;
    await usersCollection.doc(soshiUsername).update({"Soshi Points": newSoshiPoints});
  }

  Future<bool> getInjectionFlagStatus(String injectionName, Map userData) async {
    return userData["INJECTION $injectionName Flag"];
  }

  Future<void> updateInjectionSwitch(String soshiUsername, String injectionName, bool state) async {
    await usersCollection.doc(soshiUsername).update({"INJECTION $injectionName Flag": state});
  }

  /*
  Create group file, add pointer to file in user file 
  */
  Future<void> createGroup({@required String id, @required String name, String photoURL}) async {
    await groupsCollection.doc(id).set(<String, dynamic>{
      "Name": name,
      "Description": "",
      "Admin": [
        "${this.currSoshiUsername}"
      ], // store separate list of members w/ elevated privileges
      "Members": [], // do not include owner/admin in members
      "Photo URL": photoURL ?? "null"
    });

    await _addGroupToUserFile(id); // add ref to user doc
  }

  /* Get list of groups for user */
  Future<List<dynamic>> getGroups() async {
    List<dynamic> groupsList;
    await usersCollection.doc(currSoshiUsername).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      groupsList = data["Groups"];
    });
    return groupsList;
  }

  /*
  Return list of members in group
  ** note ** Excludes admin
  */
  Future<List<dynamic>> getGroupMembers(String id) async {
    List<dynamic> membersList;
    await groupsCollection.doc(id).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      membersList = data["Members"];
    });
    return membersList;
  }

  /*
  Return list of admin in group
  */
  Future<List<dynamic>> getGroupAdmin(String id) async {
    List<dynamic> adminList;
    await groupsCollection.doc(id).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      adminList = data["Admin"];
    });
    return adminList;
  }

  /*
  Promote member to admin
  */
  Future<void> promoteToAdmin(String id, String username) async {
    List<String> newAdmin, newMembers;
    Group groupData = await getGroupData(id);

    newAdmin = await groupData.admin;
    newMembers = await groupData.members;
    newAdmin.add(username);
    newMembers.remove(username);
    await groupsCollection.doc(id).update({"Admin": newAdmin, "Members": newMembers});
  }

  Future<void> joinGroup(String id) async {
    await _addUserToGroupFile(id); // add username to group members list (in group doc)
    await _addGroupToUserFile(id); // add group to user doc
  }

  /*
  Removes {username} from group {id}
  */
  Future<void> leaveGroup(String id, String username, {bool isAdmin = false}) async {
    await _removeUserFromGroupFile(
        id, username, isAdmin); // remove user from members (or admin) in group
    await _removeGroupFromUserFile(id, username); // remove group id from group list in user file
  }

  /*
  Removes group {id} from groups list in user file
  */
  Future<void> _removeGroupFromUserFile(String id, String username) async {
    // get copy of current groups list
    List<dynamic> groupsList = await getGroups();
    // remove from group from list
    groupsList.remove(id);
    return await usersCollection.doc(username).update({"Groups": groupsList});
  }

  Future<void> _removeUserFromGroupFile(String id, String username, bool isAdmin) async {
    // remove username from members (or admin) list
    if (!isAdmin) {
      List<dynamic> groupMembers = await getGroupMembers(id); // get current group members
      await groupMembers.remove(username);
      return await groupsCollection.doc(id).update({"Members": groupMembers});
    } else {
      // remove from admin
      List<dynamic> groupAdmin = await getGroupAdmin(id); // get current group members
      await groupAdmin.remove(username);
      return await groupsCollection.doc(id).update({"Admin": groupAdmin});
    }
  }

  Future<void> _addGroupToUserFile(String id) async {
    // get copy of current groups list
    List<dynamic> groupsList = await getGroups();

    // check to see if list already exists
    if (groupsList == null) {
      // create new list
      groupsList = [id];
    } else {
      // add new group to list
      if (!groupsList.contains(id)) {
        // ensure group isn't already added
        groupsList.add(id);
      }
    }

    await usersCollection.doc(currSoshiUsername).update({"Groups": groupsList});
  }

  Future<void> _addUserToGroupFile(id) async {
    List<dynamic> groupMembers = await getGroupMembers(id); // get current group members

    // add new member to list (if not already in group)
    if (!groupMembers.contains(currSoshiUsername)) {
      // ensure friend isn't already added
      groupMembers.add(currSoshiUsername);
    }

    await groupsCollection.doc(id).update({"Members": groupMembers});
  }

  Future<List<Group>> getGroupObjects() async {
    List<dynamic> groupIds = await getGroups();
    List<Group> groupObjList = [];
    // iterate through ids (backwards to preserve chronological order), create Group object for each id
    for (int i = groupIds.length - 1; i >= 0; i--) {
      groupObjList.add(await getGroupData(groupIds[i]));
    }
    return groupObjList;
  }

  Future<Group> getGroupData(String id) async {
    var groupData;
    await groupsCollection.doc(id).get().then((DocumentSnapshot ds) {
      groupData = ds.data();
    });
    return Group(
        id: id,
        name: groupData["Name"],
        description: groupData["Description"],
        photoURL: groupData["Photo URL"],
        admin: groupData["Admin"],
        members: groupData["Members"]);
  }

  /* Takes string list param, returns List of Friend objects from group members */
  Future<List<Friend>> membersToFriends(List<dynamic> members) async {
    List<Friend> membersAsFriends = [];
    Friend currFriend;
    for (String username in members) {
      // iterate through members, convert to Friend(s)
      currFriend = userDataToFriend(await getUserFile(username));
      membersAsFriends.add(currFriend);
    }
    return membersAsFriends;
  }

  /* Takes string list param, returns List of Friend objects from group members */
  Future<List<Friend>> adminToFriends(List<dynamic> admin) async {
    List<Friend> adminAsFriends = [];
    Friend currFriend;
    for (String username in admin) {
      // iterate through members, convert to Friend(s)
      currFriend = userDataToFriend(await getUserFile(username));
      adminAsFriends.add(currFriend);
    }
    return adminAsFriends;
  }
}
