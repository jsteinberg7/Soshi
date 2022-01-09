import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'contacts.dart';
import 'localData.dart';

/*
 Includes getters and setters for various fields in the Firebase database
 */
class DatabaseService {
  // soshiUsername of user
  String soshiUsername;

  // Basic constructor
  DatabaseService({String soshiUsernameIn}) {
    soshiUsername = soshiUsernameIn;
  }

  // store reference to all user files
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");

  // store reference to all user files
  CollectionReference emailToUsernameCollection =
      FirebaseFirestore.instance.collection("emailToUsername");
  /*
  Creates file for new user
  */
  Future<void> createUserFile(
      {String username, String email, String first, String last}) async {
    await emailToUsernameCollection
        .doc(email)
        .set(<String, dynamic>{"soshiUsername": username});
    String phoneNumber = await SmsAutoFill().hint;
    return await usersCollection.doc(soshiUsername).set(<String, dynamic>{
      "Name": {"First": first, "Last": last},
      "Friends": <String>[],
      "Bio": "",
      "Usernames": <String, String>{
        "Soshi": username,
        "Phone": phoneNumber,
        "Instagram": null,
        "Snapchat": null,
        "Linkedin": null,
        "Twitter": null,
        "Facebook": null,
        "Reddit": null,
        "Tiktok": null,
        "Discord": null,
        "Email": email,
        "Venmo": null,
        "Spotify": null,
        "Contact": null,
      },
      "Switches": <String, bool>{
        "Phone": (phoneNumber != null),
        "Instagram": false,
        "Snapchat": false,
        "Linkedin": false,
        "Twitter": false,
        "Facebook": false,
        "Reddit": false,
        "Tiktok": false,
        "Discord": false,
        "Email": false,
        "Venmo": false,
        "Spotify": false,
      },
      "Photo URL": "null",
      "Choose Platforms": <String>[
        // "Email",
        "Instagram",
        "Snapchat",
        // "Venmo",
        "Linkedin",
        "Twitter",
        "Tiktok",
        "Spotify",
        "Facebook",
        "Discord",
        "Reddit",
      ],
      "Profile Platforms": <String>["Phone"],
    });
  }

  /*
  METHODS PERTAINING TO UPDATING USER DATA (SETTERS)
  */
  // see following reference: https://pub.dev/packages/cloud_firestore/example

  // updates username for specified social media platform
  Future<void> updateUsernameForPlatform(
      {String platform, String username}) async {
    // get user data
    Map userData = await getUserFile(soshiUsername);
    // get current map of usernames
    Map<String, dynamic> usernamesMap = getUserProfileNames(userData);
    // update local map to reflect change
    usernamesMap[platform] = username;
    // update database to reflect local map change
    await usersCollection
        .doc(soshiUsername)
        .update({"Usernames": usernamesMap});
    // if email or phone is updated, update contact card vcf
    if (platform == "Email" || platform == "Phone") {
      await updateContactCard();
    }
  }

  // updates switch for given platform
  Future<void> updatePlatformSwitch({String platform, bool state}) async {
    Map<String, dynamic> switches;
    await usersCollection.doc(soshiUsername).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      switches = data["Switches"];
    });
    // update map locally
    switches["$platform"] = state;
    // upload change to database
    return await usersCollection
        .doc(soshiUsername)
        .update({"Switches": switches});
  }

  // upload selected image to Firebse Storage, return URL
  Future<void> uploadProfilePicture(File image) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    // upload image
    File file = new File(image.path);
    await firebaseStorage
        .ref()
        .child("Profile Pictures/" + soshiUsername)
        .putFile(file);
  }

  // update profile picture URL (necessary on first profile pic change)
  Future<void> updateUserProfilePictureURL(String URL) async {
    await usersCollection.doc(soshiUsername).update({"Photo URL": URL});
  }

  // upload selected image to Firebase Storage, return URL
  Future<String> uploadContactCard(VCard vCard) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    File file = await vCard.generateVcf(soshiUsername);
    dynamic child =
        firebaseStorage.ref().child("VCards/$soshiUsername Contact Card.vcf");
    await child.putFile(file); // upload vCard to Firebase Storage
    return await child.getDownloadURL();
  }

  Future<void> updateContactCard() async {
    // create new VCard
    VCard vCard = new VCard(
        soshiUsernameIn: soshiUsername,
        firstNameIn: LocalDataService.getLocalFirstName(),
        lastNameIn: LocalDataService.getLocalLastName(),
        emailIn: LocalDataService.getLocalUsernameForPlatform("Email"),
        phoneIn: LocalDataService.getLocalUsernameForPlatform("Phone"));
    // upload contact card to firebase storage
    String vcfLink = await uploadContactCard(vCard);
    // set link in database to point toward storage
    LocalDataService.updateUsernameForPlatform(
        platform: "Contact", username: vcfLink);
    updateUsernameForPlatform(platform: "Contact", username: vcfLink);
  }

  /*
  METHODS PERTAINING TO FRIENDS LIST
  */
  // add new friend to current user's friend list
  Future<void> addFriend({String friendsoshiUsername}) async {
    // get copy of current friends list
    List<dynamic> friendsList = await getFriends();

    // check to see if list already exists
    if (friendsList == null) {
      // create new list
      friendsList = [friendsoshiUsername];
    } else {
      // add new friend to list
      friendsList.add(friendsoshiUsername);
    }

    return await usersCollection
        .doc(soshiUsername)
        .update({"Friends": friendsList});
  }

  // remove friend from current user's friend list
  Future<void> removeFriend({String friendsoshiUsername}) async {
    List<dynamic> friendsList;
    // get current friends list from database
    friendsList = await getFriends();
    // remove friend from local list
    friendsList.remove(friendsoshiUsername);
    // update database to reflect change
    await usersCollection.doc(soshiUsername).update({"Friends": friendsList});
  }

  // return list of friends for current user (for use with friends screen)
  Future<List<dynamic>> getFriends() async {
    List<dynamic> friendsList;
    await usersCollection.doc(soshiUsername).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      friendsList = data["Friends"];
    });
    return friendsList;
  }

  // checks if friend is already in user's friend list
  Future<bool> isFriendAdded(String othersoshiUsername) async {
    List<dynamic> friendsList = await getFriends();
    return friendsList.contains(othersoshiUsername);
  }

  // return list of friends for current user (for use with friends screen)
  Future<List<dynamic>> getAddedMeList(String othersoshiUsername) async {
    List<dynamic> addedMeList;
    await usersCollection
        .doc(othersoshiUsername)
        .get()
        .then((DocumentSnapshot ds) {
      Map data = ds.data();
      addedMeList = data["Added Me"];
    });
    print("data in db + " + addedMeList.toString());
    return addedMeList;
  }

  // add new friend to current user's Added ME list
  Future<void> addToAddedMeList({String othersoshiUsername}) async {
    // get copy of current Added Me list
    List<dynamic> addedMeList = await getAddedMeList(othersoshiUsername);

    // check to see if list already exists
    if (addedMeList == null) {
      // create new list
      addedMeList = [othersoshiUsername];
    } else {
      // add new user to list
      addedMeList.add(othersoshiUsername);
    }

    return await usersCollection
        .doc(soshiUsername)
        .update({"Added Me": addedMeList});
  }

  // remove friend from current user's friend list
  Future<void> removeFromAddedMeList(String friendsoshiUsername) async {
    List<dynamic> addedMeList;
    // get current friends list from database
    addedMeList = await getAddedMeList(friendsoshiUsername);
    // remove friend from local list
    addedMeList.remove(friendsoshiUsername);
    // update database to reflect change
    await usersCollection.doc(soshiUsername).update({"Added Me": addedMeList});
  }

  /*
  Methods pertaining to getting user data
  */

  Future<Map> getUserFile(String soshiUsername) {
    return usersCollection.doc(soshiUsername).get().then((DocumentSnapshot ds) {
      Map data = ds.data();
      return data;
    });
  }

  // pass in soshiUsername, return map of user switches (platform visibility)
  Map<String, dynamic> getUserSwitches(Map userData) {
    return userData["Switches"];
  }

  // return list of enabled user switches
  Future<List<String>> getEnabledPlatformsList(Map userData) async {
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

  // pass in soshiUsername, return (Map) of user profile names
  Map<String, dynamic> getUserProfileNames(Map userData) {
    return userData["Usernames"];
  }

  // return username for specified platform
  Future<String> getUsernameForPlatform({@required Map userData, @required String platform}) async {
    String username;
    Map<String, dynamic> profileNamesMap = getUserProfileNames(userData);
    username = profileNamesMap[platform];
    return username;
  }

  // pass in soshiUsername, return (Map) of full name of user
  Map<String, dynamic> getFullNameMap(Map userData) {
    return userData["Name"];
  }

  // pass in soshiUsername, return (String) full name of user
  Future<String> getFullName(Map userData) async {
    Map fullNameMap = getFullNameMap(userData);
    // convert to String
    String fullName = fullNameMap["First"] + " " + fullNameMap["Last"];
    return fullName;
  }

  Future<String> getPhotoURL(Map userData) async {
    return userData["Photo URL"];
  }

  Future<List<dynamic>> getProfilePlatforms() async {
    dynamic data;
    await usersCollection.doc(soshiUsername).get().then((DocumentSnapshot ds) {
      data = ds.data();
    });
    return data["Profile Platforms"];
  }

// UV functions

  Future<List<dynamic>> getChoosePlatforms() async {
    dynamic data;
    await usersCollection.doc(soshiUsername).get().then((DocumentSnapshot ds) {
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
        .doc(soshiUsername)
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
        .doc(soshiUsername)
        .update({"Choose Platforms": choosePlatformsList});
  }

  // Remove single platform from the profile platforms list
  Future<void> removePlatformFromProfile(String platform) async {
    List<dynamic> profilePlatforms = await getProfilePlatforms();
    profilePlatforms.remove(platform);
    return await usersCollection
        .doc(soshiUsername)
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
        .doc(soshiUsername)
        .update({"Choose Platforms": choosePlatformsList});
  }

//get first name of Display Name
  Future<String> getFirstDisplayName(Map userData) async {
    String firstName;
    Map<String, dynamic> fullNameMap = getFullNameMap(userData);
    firstName = fullNameMap["First"];
    return firstName;
  }

  Future<void> updateDisplayName(
      {String firstNameParam, String lastNameParam}) async {
    Map userData = await getUserFile(soshiUsername);
    //get current map of display name
    Map<String, dynamic> displayNameMap = getFullNameMap(userData);
    //update local map to reflect change
    displayNameMap["First"] = firstNameParam;
    displayNameMap["Last"] = lastNameParam;
    //update to databse to reflect local map changes
    await usersCollection.doc(soshiUsername).update({"Name": displayNameMap});
    // update contact card vcf in database if name is changed
    await updateContactCard();
  }

  String getLastDisplayName(Map userData) {
    String lastName;
    Map<String, dynamic> fullName = getFullNameMap(userData);
    lastName = fullName["Last"];

    // await usersCollection.doc(soshiUsername).get().then(
    //     (DocumentSnapshot ds) => lastDisplayName = ds.data()["Name"]["Last"]);
    return lastName;
  }

  Future<int> getFriendsCount() async {
    List<dynamic> friendsList = await getFriends();
    int friendsCount = friendsList.length;
    return friendsCount;
  }

  String getEmail(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return user.email;
  }

  // pass in soshiUsername, return (Map) of full name of user
  Future<String> getSoshiUsernameForLogin({String email}) async {
    String soshiUsername;
    await emailToUsernameCollection
        .doc(email)
        .get()
        .then((DocumentSnapshot ds) {
      Map data = ds.data();
      soshiUsername = data["soshiUsername"];
    });
    return soshiUsername;
  }

  Future<void> cropAndUploadImage(PickedFile passedInImage) async {
    if (passedInImage != null) {
      File croppedImage = (await ImageCropper.cropImage(
          cropStyle: CropStyle.circle,
          sourcePath: passedInImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          maxHeight: 700,
          maxWidth: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.cyan, toolbarTitle: "Crop Image"),
          iosUiSettings: IOSUiSettings(
            title: "Crop Image",
          )));

      String soshiUsername =
          LocalDataService.getLocalUsernameForPlatform("Soshi");
      DatabaseService databaseService =
          new DatabaseService(soshiUsernameIn: soshiUsername);
      await databaseService.uploadProfilePicture(croppedImage);
      String url = await FirebaseStorage.instance
          .ref()
          .child("Profile Pictures/" + soshiUsername)
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
      await FirebaseStorage.instance
          .ref()
          .child("Profile Pictures/" + soshiUsername)
          .delete();
    } catch (e) {}

    await emailToUsernameCollection.doc(email).delete();
    await usersCollection.doc(soshiUsername).delete();
  }

  Future<String> getBio(Map userData) async {
    return userData["Bio"];
  }

  Future<void> updateBio(String soshiUser, String newBio) async {
    await usersCollection.doc(soshiUser).update({"Bio": newBio});
  }

  // bool isFirstTime() {
  //    (await IsFirstRun.isFirstRun()) ? return true : return false;
  //   // bool check = await IsFirstRun.isFirstRun();
  //   // return check;
  // }
}
