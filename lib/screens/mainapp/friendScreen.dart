import 'dart:convert';

import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:async/async.dart';
import 'package:azlistview/azlistview.dart';
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/popups.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/services/localData.dart';
import 'package:vibration/vibration.dart';
import 'package:soshi/constants/widgets.dart';

/* Stores information for individual friend/connection */
class Friend {
  String soshiUsername, fullName, photoURL;
  bool isVerified;
  Map<String, dynamic> switches, usernames;
  Map<String, dynamic> enabledUsernames;
  Friend(
      {this.soshiUsername,
      this.fullName,
      this.photoURL,
      this.isVerified,
      this.switches,
      this.usernames,
      this.enabledUsernames // only use when coming from json
      });

  // takes in a single json pertaining to a friend, returns Friend object
  static Friend jsonToFriend(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return Friend(
        soshiUsername: map["u"],
        fullName: map["n"],
        photoURL: map["url"],
        isVerified: map["v"],
        enabledUsernames: jsonDecode(map["s/u"]));
  }

  Map<String, dynamic> _getEnabledPlatformUsernamesMap() {
    Map<String, dynamic> enabledUsernames = {};
    switches.forEach((platform, state) {
      if (state == true) {
        enabledUsernames.addAll({platform: this.usernames[platform]});
      }
    });
    return enabledUsernames;
  }

  // convert friend to map, then map to json
  toJson() {
    Map<String, dynamic> map = {
      "u": soshiUsername,
      "n": fullName,
      "url": photoURL,
      "v": isVerified,
      "s/u": enabledUsernames ?? jsonEncode(_getEnabledPlatformUsernamesMap())
    };
    return jsonEncode(map);
  }
}

/* This widget displays a list of the user's friends. */
class FriendScreen extends StatefulWidget {
  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  List recentFriendsList;
  List friendsList;
  List<Friend> formattedFriendsList = [];
  List<Friend> formattedFriendsListOriginal = [];
  List<Friend> formattedRecentsList = [];
  List<dynamic> friendsListJson;
  List<String> friendsListNames;
  TextEditingController searchController;
  AsyncMemoizer memoizer;
  bool hideRecents;
  bool showKeyboard;
  @override
  void initState() {
    friendsListNames = LocalDataService.getLocalFriendsListNames();
    recentFriendsList = LocalDataService.getRecentlyAddedFriends();
    friendsList = LocalDataService.getLocalFriendsList();
    friendsListJson = LocalDataService.getLocalFriendsList();
    showKeyboard = false;
    hideRecents =
        (friendsList.length < 5); // hide recents if 5 or fewer total friends

    searchController = TextEditingController();
    searchController.addListener(() {
      String text = searchController.text;
      if (text.isNotEmpty) {
        filterList(searchController.text);
      } else {
        // if empty, go back to full list
        setState(() {
          formattedFriendsList = List.from(formattedFriendsListOriginal);
        });
      }
    });
    // double startingBrightness = LocalDataService.getInitialScreenBrightness();
    // DeviceDisplayBrightness.setBrightness(startingBrightness);
    // DeviceDisplayBrightness.resetBrightness();
    // memoizer = new AsyncMemoizer()
    generateFriendsList();
    super.initState();
  }

  // void initializeFriendsList() {
  //   friendsListNames = LocalDataService.getLocalFriendsListNames();
  //   recentFriendsList = LocalDataService.getRecentlyAddedFriends();
  //   friendsList = LocalDataService.getLocalFriendsList();
  //   friendsListJson = LocalDataService.getLocalFriendsList();
  //   generateFriendsList();
  // }

  // narrows down friendsList based on search text
  void filterList(String searchText) {
    List<Friend> filteredFriendsList = [];
    List<String> filteredFriendsListNames = [];
    // convert to lowercase for matching;
    searchText = searchText.toLowerCase();
    String currName;
    String currUsername;
    for (Friend friend in formattedFriendsListOriginal) {
      currName = friend.fullName.toLowerCase();
      currUsername = friend.soshiUsername.toLowerCase();
      if (currName.contains(searchText) || currUsername.contains(searchText)) {
        // check for match
        filteredFriendsList.add(friend); // if match, add to new filtered list
        filteredFriendsListNames
            .add(friend.fullName.toLowerCase()); // add name to names list
      }
    }
    setState(() {
      formattedFriendsList = List.from(filteredFriendsList);
      friendsListNames = List.from(filteredFriendsListNames);
      hideRecents = true;
      showKeyboard = true;
    }); // update friendsList
  }

  /* refresh screen */
  void refreshFriendScreen() {
    //implement loading icon
    setState(() {
      // initializeFriendsList();
    });

    print('refreshed');
  }

  // convert json friends list to list of Friend(s)
  List<Friend> generateFriendsList() {
    for (String json in friendsList) {
      formattedFriendsList.add(Friend.jsonToFriend(json));
    }
    // get recently added friends list
    String currUsername;
    for (String json in recentFriendsList) {
      // find in friends
      currUsername = jsonDecode(json)["u"];
      for (Friend friend in formattedFriendsList) {
        if (currUsername == friend.soshiUsername) {
          formattedRecentsList.add(friend);
        }
      }
    }

    formattedFriendsListOriginal
        .addAll(formattedFriendsList); // store copy of original
  }

  /* Generates a list of Friend(s) for the user by fetching data for each soshiUsername in their friends list */
  // Future<dynamic> generateFriendsList() async {
  //   return this.memoizer.runOnce(() async {
  //     DatabaseService databaseService = new DatabaseService(
  //         currSoshiUsernameIn: LocalDataService.getLocalUsername());
  //     // store list of friend soshiUsernames
  //     List<Friend> formattedFriendsList = [];
  //     List<Friend> formattedRecentFriends = [];
  //     List<String> recentlyAddedFriends =
  //         LocalDataService.getRecentlyAddedFriends();
  //     List<String> friendsToRemove = [];
  //     Map friendData;
  //     String fullName,
  //         username,
  //         photoURL; // store data of current friend in list
  //     bool isVerified;
  //     String friendUsername;
  //     for (int i = 0; i < friendsListJson.length; i++) {
  //       friendUsername = jsonDecode(friendsListJson[i])["u"];
  //       friendData = await databaseService.getUserFile(friendUsername);
  //       if (friendData != null) {
  //         // ensure friend exists in database
  //         // if friend exists in database
  //         fullName = databaseService.getFullName(friendData);
  //         photoURL = databaseService.getPhotoURL(friendData);
  //         isVerified = databaseService.getVerifiedStatus(friendData);
  //         formattedFriendsList.add(new Friend(
  //             // instantiate new friend and add to list
  //             soshiUsername: friendUsername,
  //             fullName: fullName,
  //             photoURL: photoURL,
  //             isVerified: isVerified));
  //       } else {
  //         // if friend no longer exists, flag friend for removal
  //         friendsToRemove.add(friendUsername);
  //       }
  // // get recently added friends list
  // String currUsername;
  // for (String json in recentlyAddedFriends) {
  //   // find in friends
  //   currUsername = jsonDecode(json)["u"];
  //   for (Friend friend in formattedFriendsList) {
  //     if (currUsername == friend.soshiUsername) {
  //       formattedRecentFriends.add(friend);
  //     }
  //   }
  // }
  //     }
  //     for (String othersoshiUsername in friendsToRemove) {
  //       // remove friends that no longer exist
  //       List<String> newFriendsList = await LocalDataService.removeFriend(
  //           friendsoshiUsername: othersoshiUsername);
  //       // await databaseService.removeFriend(
  //       //     friendSoshiUsername: othersoshiUsername);
  //       databaseService.overwriteFriendsList(
  //           newFriendsList); // overwrite friendsList in cloud
  //     }

  //     return [formattedRecentFriends, formattedFriendsList];
  //   });
  // }

  /* Creates a single "friend tile" (an element of the ListView of Friends) */
  Widget createFriendTile(
      {BuildContext context, Friend friend, DatabaseService databaseService}) {
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);

    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 5, 30, 5),
        child: ListTile(
            onTap: () async {
              Popups.showUserProfilePopupNew(context,
                  friendSoshiUsername: friend.soshiUsername,
                  refreshScreen: refreshFriendScreen,
                  friend: friend); // show friend popup when tile is pressed
            },
            leading: ProfilePic(radius: width / 14, url: friend.photoURL),
            title: Column(
              children: <Widget>[
                Text(friend.fullName,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        // color: Colors.cyan[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
                SizedBox(height: height / 170),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "@" + friend.soshiUsername,
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 15,
                          fontStyle: FontStyle.italic),
                    ),
                    SizedBox(
                      width: width / 150,
                    ),
                    friend.isVerified == null || friend.isVerified == false
                        ? Container()
                        : Image.asset(
                            "assets/images/Verified.png",
                            scale: width / 20,
                          )
                  ],
                ),
              ],
            ),
            tileColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[50]
                : Colors.grey[850],

            // selectedTileColor: Constants.buttonColorLight,
            contentPadding: EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              // side: BorderSide(width: .5)
            ),
            trailing: IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 30,
                  // color: Colors.white,
                ),
                // color: Colors.black,
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      constraints: BoxConstraints(
                        minWidth: width / 1.1,
                        maxWidth: width / 1.1,
                      ),
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: height / 2.8,
                          color: Colors.transparent,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ListTile(
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  height / 160,
                                                  0,
                                                  height / 100),
                                              child: ProfilePic(
                                                radius: width / 10,
                                                url: friend.photoURL,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "@" + friend.soshiUsername,
                                                  style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: width / 25,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                                SizedBox(
                                                  width: width / 130,
                                                ),
                                                friend.isVerified == null ||
                                                        friend.isVerified ==
                                                            false
                                                    ? Container()
                                                    : Image.asset(
                                                        "assets/images/Verified.png",
                                                        scale: width / 21,
                                                      )
                                              ],
                                            ),
                                            Divider(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.grey[500]
                                                  : Colors.grey,
                                            ),
                                            ListTile(
                                              title: Center(
                                                child: Text(
                                                  "Remove friend",
                                                  style: TextStyle(
                                                      fontSize: width / 20,
                                                      color: Colors.red),
                                                ),
                                              ),
                                              onTap: () async {
                                                List<String> newFriendsList =
                                                    await LocalDataService
                                                        .removeFriend(
                                                            friendsoshiUsername:
                                                                friend
                                                                    .soshiUsername); // update local list
                                                databaseService
                                                    .overwriteFriendsList(
                                                        newFriendsList); // update cloud list

                                                refreshFriendScreen();
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ListTile(
                                    title: Center(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                            fontSize: width / 20,
                                            color: Colors.blue),
                                      ),
                                    ),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                }
                // showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         shape: RoundedRectangleBorder(
                //             borderRadius:
                //                 BorderRadius.all(Radius.circular(40.0))),
                //         // backgroundColor: Colors.blueGrey[900],
                //         title: Text(
                //           "Remove Friend",
                //           style: TextStyle(
                //               // color: Colors.cyan[600],
                //               fontWeight: FontWeight.bold),
                //         ),
                //         content: Text(
                //           ("Are you sure you want to remove " +
                //               friend.fullName +
                //               " as a friend?"),
                //           style: TextStyle(
                //             fontSize: 20,
                //             // color: Colors.cyan[700],
                //             //fontWeight: FontWeight.bold
                //           ),
                //         ),
                //         actions: <Widget>[
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //             children: <Widget>[
                //               TextButton(
                //                 child: Text(
                //                   'Cancel',
                //                   style: TextStyle(
                //                       fontSize: 20, color: Colors.blue),
                //                 ),
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //               ),
                //               TextButton(
                //                 child: Text(
                //                   'Remove',
                //                   style: TextStyle(
                //                       fontSize: 20, color: Colors.red),
                //                 ),
                // onPressed: () async {
                //   List<String> newFriendsList =
                //       await LocalDataService.removeFriend(
                //           friendsoshiUsername: friend
                //               .soshiUsername); // update local list
                //   databaseService.overwriteFriendsList(
                //       newFriendsList); // update cloud list

                //   refreshFriendScreen();
                //   Navigator.pop(context);
                // },
                //               ),
                //             ],
                //           ),
                //         ],
                //       );
                //     });
                //},
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(60.0)),

                //itemBuilder: (BuildContext context) {
                //return [
                // PopupMenuItem(
                //     child: IconButton(
                //         icon: Icon(Icons.delete),
                //         color: Colors.white,
                //         iconSize: 40,
                //         splashColor: Colors.cyan,
                //         // style: ElevatedButton.styleFrom(
                //         //     primary: Colors.cyan[800]),
                //         // Text(
                //         //   "Remove Friend",
                //         //   style: TextStyle(color: Colors.black),
                //         // ),
                //         onPressed: () async {
                //           Navigator.pop(context);
                //           await LocalDataService.removeFriend(
                //               friendsoshiUsername: friend.soshiUsername);
                //           databaseService.removeFriend(friendsoshiUsername: friend.soshiUsername);
                //           refreshFriendScreen();
                //         }))
                //   ];
                // }
                )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //implement loading icon
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    DatabaseService databaseService = new DatabaseService(
        currSoshiUsernameIn:
            LocalDataService.getLocalUsernameForPlatform("Soshi"));

    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");

    // These are used to reset the flag (testing cases)
    // LocalDataService.updateInjectionFlag("Soshi Points", false);

    // databaseService.updateInjectionSwitch(soshiUsername, "Soshi Points", false);

    // LocalDataService.updateInjectionFlag("Profile Pic", false);

    // databaseService.updateInjectionSwitch(soshiUsername, "Profile Pic", false);

    // LocalDataService.updateInjectionFlag("Bio", false);

    // databaseService.updateInjectionSwitch(soshiUsername, "Bio", false);

    bool soshiPointsInjection =
        LocalDataService.getInjectionFlag("Soshi Points");

    if (soshiPointsInjection == false || soshiPointsInjection == null) {
      LocalDataService.updateInjectionFlag("Soshi Points", true);
      databaseService.updateInjectionSwitch(
          soshiUsername, "Soshi Points", true);

      int numFriends = LocalDataService.getFriendsListCount();
      LocalDataService.updateSoshiPoints(numFriends * 8);

      databaseService.updateSoshiPoints(soshiUsername, (numFriends * 8));
    }

    bool profilePicFlagInjection =
        LocalDataService.getInjectionFlag("Profile Pic");
    print(profilePicFlagInjection.toString());

    if (profilePicFlagInjection == false || profilePicFlagInjection == null) {
      if (LocalDataService.getLocalProfilePictureURL() != "null") {
        LocalDataService.updateInjectionFlag("Profile Pic", true);
        databaseService.updateInjectionSwitch(
            soshiUsername, "Profile Pic", true);
        LocalDataService.updateSoshiPoints(10);

        databaseService.updateSoshiPoints(soshiUsername, 10);
      } else {
        LocalDataService.updateInjectionFlag("Profile Pic", false);
        databaseService.updateInjectionSwitch(
            soshiUsername, "Profile Pic", false);
      }
    }

    bool bioFlagInjection = LocalDataService.getInjectionFlag("Bio");
    if (bioFlagInjection == false || bioFlagInjection == null) {
      if (LocalDataService.getBio() != "" ||
          LocalDataService.getBio() == null) {
        LocalDataService.updateInjectionFlag("Bio", true);
        databaseService.updateInjectionSwitch(soshiUsername, "Bio", true);
        LocalDataService.updateSoshiPoints(10);

        databaseService.updateSoshiPoints(soshiUsername, 10);
      } else {
        LocalDataService.updateInjectionFlag("Bio", false);
        databaseService.updateInjectionSwitch(soshiUsername, "Bio", false);
      }
    }

    // For now, just injecting passions flag field
    LocalDataService.updateInjectionFlag("Passions", false);
    databaseService.updateInjectionSwitch(soshiUsername, "Passions", false);

    //       bool passionsFlagInjection =
    //     LocalDataService.getLocalStateForInjectionFlag("Passions");
    // if (passionsFlagInjection == false || passionsFlagInjection == null) {
    //   if (LocalDataService.getPassions() != empty) {
    //     LocalDataService.updateSwitchForInjection(
    //         injection: "Passions", state: true);
    //     databaseService.updateInjectionSwitch(injection: "Passions", state: true);
    //   } else {
    //     LocalDataService.updateSwitchForInjection(
    //         injection: "Passions", state: false);
    //     databaseService.updateInjectionSwitch(injection: "Passions", state: false);
    //   }
    // }

    // return FutureBuilder(
    //     future: generateFriendsList(),
    //     builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         // check if request is still loading
    //         return Center(
    //             child: CustomThreeInOut(
    //                 color: Theme.of(context).brightness == Brightness.light
    //                     ? Colors.grey[500]
    //                     : Colors.white,
    //                 size: 50.0));
    //       } else if (snapshot.connectionState == ConnectionState.none) {
    //         // check if request is empty
    //         return Text(
    //           "No connection!",
    //           style: TextStyle(
    //               // color: Colors.cyan[300],
    //               fontSize: 20,
    //               fontStyle: FontStyle.italic,
    //               letterSpacing: 1.5),
    //         );
    //       }
    //       // check if request is done
    //       else if (snapshot.connectionState == ConnectionState.done &&
    //           snapshot.hasData) {
    //         recentFriendsList = snapshot.data[0];
    //         friendsList = snapshot.data[1];
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
              Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    // primary: Constants.buttonColorDark,
                    shape: CircleBorder()),
                onPressed: () async {
                  String QRScanResult = await Utilities.scanQR(mounted);
                  if (QRScanResult.length > 5) {
                    // vibrate when QR code is successfully scanned
                    Vibration.vibrate();
                    try {
                      String friendSoshiUsername = QRScanResult.split("/").last;
                      Map friendData = await databaseService
                          .getUserFile(friendSoshiUsername);
                      Friend friend =
                          databaseService.userDataToFriend(friendData);
                      bool isFriendAdded = await LocalDataService.isFriendAdded(
                          friendSoshiUsername);

                      Popups.showUserProfilePopupNew(context,
                          friendSoshiUsername: friendSoshiUsername,
                          refreshScreen: () {});
                      if (!isFriendAdded &&
                          friendSoshiUsername !=
                              databaseService.currSoshiUsername) {
                        List<String> newFriendsList =
                            await LocalDataService.addFriend(friend: friend);

                        databaseService.overwriteFriendsList(newFriendsList);
                        // update local lists

                        refreshFriendScreen();
                        // databaseService.addFriend(
                        //     thisSoshiUsername:
                        //         databaseService.currSoshiUsername,
                        //     friendSoshiUsername: friendSoshiUsername);
                      }

                      // bool friendHasTwoWaySharing = await databaseService.getTwoWaySharing(friendData);
                      // if (friendHasTwoWaySharing == null || friendHasTwoWaySharing == true) {
                      //   // if user has two way sharing on, add self to user's friends list
                      //   databaseService.addFriend(thisSoshiUsername: friendSoshiUsername, friendSoshiUsername: databaseService.currSoshiUsername);
                      // }
                      //add friend right here

                      Analytics.logQRScan(
                          QRScanResult, true, "friendScreen.dart corner icon");
                    } catch (e) {
                      Analytics.logQRScan(
                          QRScanResult, false, "friendScreen.dart corner icon");
                      print(e);
                    }
                  }
                },
                child: Icon(Icons.qr_code_scanner_sharp,
                    // color: Colors.cyan[300],
                    size: width / 20)),
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_people, // or Icons.poeple_round
                      color: Colors.cyan,
                      size: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Text(
                        "Friends: " +
                            LocalDataService.getFriendsListCount().toString(),
                        //textAlign: TextAlign.center,
                        style: TextStyle(
                            // color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                // Padding(
                //   padding: const EdgeInsets.only(top: 3),
                //   child: Text(
                //     "Total: " +
                //         LocalDataService.getFriendsListCount().toString(),
                //     style: TextStyle(
                //         // color: Colors.cyan[300]
                //         ),
                //   ),
                // ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: width / 16,
                      child:
                          Flex(direction: Axis.horizontal, children: <Widget>[
                        Expanded(
                            child: Image.asset(
                          "assets/images/SoshiLogos/soshi_icon_circular.png",
                        )),
                      ]),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        LocalDataService.getSoshiPoints().toString(),
                        style: TextStyle(fontSize: width / 18
                            // color: Colors.cyan[300]
                            ),
                      ),
                    ),
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        splashRadius: 12,
                        onPressed: () {},
                        iconSize: width / 14,
                        icon: Icon(Icons.question_mark_rounded))
                  ],
                )
              ],
            ),
            ShareButton(
              size: width / 20,
              soshiUsername: LocalDataService.getLocalUsername(),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Divider(
              color: Colors.cyan,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Container(
              child: formattedFriendsList.isNotEmpty
                  ? Container(
                      height: height,
                      width: width,
                      child: AlphabetListScrollView(
                        strList: friendsListNames,
                        indexedHeight: (i) {
                          return 102;
                        },
                        itemBuilder: (BuildContext context, int i) {
                          if (i >= formattedFriendsList.length) {
                            return Container();
                          }
                          return Column(
                            children: [
                              createFriendTile(
                                  context: context,
                                  friend: formattedFriendsList[i],
                                  databaseService: databaseService),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 50, 0),
                                child: Divider(
                                  color: Colors.grey[500],
                                ),
                              )
                            ],
                          );
                        },
                        showPreview: true,
                        // keyboardUsage: showKeyboard,
                        headerWidgetList: <AlphabetScrollListHeader>[
                          AlphabetScrollListHeader(
                              widgetList: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextFormField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search "Jason"',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      prefixIcon: Icon(
                                        Icons.search,
                                      ),
                                      labelText: "Search for a friend...",
                                    ),
                                  ),
                                )
                              ],
                              icon: Icon(Icons.search),
                              indexedHeaderHeight: (index) => 80),
                          (formattedRecentsList.isNotEmpty && !hideRecents)
                              ? AlphabetScrollListHeader(
                                  widgetList: [
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16.0, 10.0, 16.0, 0.0),
                                          child: Text("Recently Added")),
                                      ListView.builder(
                                          itemCount:
                                              formattedRecentsList.length,
                                          itemBuilder:
                                              (BuildContext context, int i) {
                                            return Column(
                                              children: [
                                                createFriendTile(
                                                    context: context,
                                                    friend:
                                                        (formattedRecentsList[
                                                            i]),
                                                    databaseService:
                                                        databaseService),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 0, 20, 0),
                                                  child: Divider(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              ],
                                            );
                                          }),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16.0, 10.0, 16.0, 0.0),
                                          child: Text("A-Z")),
                                    ],
                                  icon: Icon(Icons.star),
                                  indexedHeaderHeight: (index) {
                                    if (index == 0) {
                                      return 30;
                                    } else if (index ==
                                        formattedRecentsList.length + 1) {
                                      return 30;
                                    } else {
                                      return 102;
                                    }
                                  })
                              : AlphabetScrollListHeader(
                                  widgetList: [],
                                  icon: Icon(Icons.star),
                                  indexedHeaderHeight: (index) => 0),

                          // AlphabetScrollListHeader(
                          //     widgetList: [Icon(Icons.favorite)],
                          //     icon: Icon(Icons.star),
                          //     indexedHeaderHeight: (index) {
                          //       return 80;
                          //     }),
                        ],
                      ),
                    )

                  // ? ListView.builder(
                  //     shrinkWrap: true,
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     // separatorBuilder: (BuildContext context, int i) {
                  //     // return Padding(padding: EdgeInsets.all(0.0));
                  //     // },
                  //     itemBuilder: (BuildContext context, int i) {
                  //       return Column(
                  //         children: [
                  //           createFriendTile(
                  //               context: context,
                  //               friend: friendsList[i],
                  //               databaseService: databaseService),
                  //           Padding(
                  //             padding: const EdgeInsets.fromLTRB(
                  //                 20, 0, 20, 0),
                  //             child: Divider(
                  //               color: Colors.grey[500],
                  //             ),
                  //           )
                  //         ],
                  //       );
                  //     },
                  //     itemCount: (friendsList == null)
                  //         ? 1
                  //         : friendsList.length,
                  //     padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0.0))
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              "You have no friends :(",
                              style: TextStyle(
                                  color: Colors.cyan[300],
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 2),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
            child: Constants.makeBlueShadowButton(
                "Add new friends", Icons.person_add, () async {
              String QRScanResult = await Utilities.scanQR(mounted);
              if (QRScanResult.length > 5) {
                // vibrate when QR code is successfully scanned
                Vibration.vibrate();
                try {
                  String friendSoshiUsername = QRScanResult.split("/").last;
                  Map friendData =
                      await databaseService.getUserFile(friendSoshiUsername);
                  Friend friend = databaseService.userDataToFriend(friendData);
                  bool isFriendAdded =
                      await LocalDataService.isFriendAdded(friendSoshiUsername);

                  Popups.showUserProfilePopupNew(context,
                      friendSoshiUsername: friendSoshiUsername,
                      refreshScreen: () {});
                  if (!isFriendAdded &&
                      friendSoshiUsername !=
                          databaseService.currSoshiUsername) {
                    List<String> newFriendsList =
                        await LocalDataService.addFriend(friend: friend);
                    refreshFriendScreen();
                    // databaseService.addFriend(
                    //     thisSoshiUsername:
                    //         databaseService.currSoshiUsername,
                    //     friendSoshiUsername: friendSoshiUsername);
                    databaseService.overwriteFriendsList(newFriendsList);
                  }

                  // bool friendHasTwoWaySharing = await databaseService.getTwoWaySharing(friendData);
                  // if (friendHasTwoWaySharing == null || friendHasTwoWaySharing == true) {
                  //   // if user has two way sharing on, add self to user's friends list
                  //   databaseService.addFriend(thisSoshiUsername: friendSoshiUsername, friendSoshiUsername: databaseService.currSoshiUsername);
                  // }
                  //add friend right here

                  Analytics.logQRScan(
                      QRScanResult, true, "friendScreen.dart Add new friends");
                } catch (e) {
                  Analytics.logQRScan(
                      QRScanResult, false, "friendScreen.dart Add new friends");
                  print(e);
                }
              }
            }),
          )
        ],
      ),
    );
    //   }
    //   return Text("Error loading friends :("); // ensure screen is not null
    // });
  }
}

// class AddedMeButton extends StatelessWidget {
//   double size;
//   String soshiUsername;
//   DatabaseService databaseService;

//   AddedMeButton({this.size = 30.0, this.soshiUsername, this.databaseService});

//   Future<List<Friend>> generateAddedMeList(
//       DatabaseService databaseService) async {
//     List<dynamic> addedMeList;
//     try {
//       addedMeList = await databaseService.getAddedMeList(soshiUsername);
//     } catch (e) {
//       addedMeList = [];
//       print(e);
//     }
//     List<Friend> addedMeListFriend = [];

//     for (String user in addedMeList) {
//       Map userData = await databaseService.getUserFile(user);
//       Friend friend = new Friend(
//           fullName: userData["Name"]["First"] + " " + userData["Name"]["Last"],
//           soshiUsername: userData["Usernames"]["Soshi"],
//           photoURL: userData["Photo URL"]);
//       addedMeListFriend.add(friend);
//     }
//     print(addedMeListFriend.toString());
//     return addedMeListFriend;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//           primary: Constants.buttonColorDark, shape: CircleBorder()),
//       onPressed: () {
//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                   insetPadding: EdgeInsets.all(0.0),
//                   backgroundColor: Colors.grey[900],
//                   contentPadding:
//                       EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                   ),
//                   content: Container(
//                     height: 300,
//                     width: 200,
//                     child: FutureBuilder(
//                         future: generateAddedMeList(databaseService),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.done) {
//                             List<Friend> addedMeList = snapshot.data;
//                             Friend friend;
//                             return Container(
//                               height: 200,
//                               width: 150,
//                               child: addedMeList.isNotEmpty
//                                   ? ListView.builder(
//                                       shrinkWrap: true,
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       // separatorBuilder: (BuildContext context, int i) {
//                                       // return Padding(padding: EdgeInsets.all(0.0));
//                                       // },
//                                       itemBuilder:
//                                           (BuildContext context, int i) {
//                                         friend = addedMeList[i];
//                                         return Padding(
//                                           padding: const EdgeInsets.fromLTRB(
//                                               10.0, 5, 10, 10),
//                                           child: ListTile(
//                                               onTap: () async {
//                                                 Popups.showUserProfilePopup(
//                                                     context,
//                                                     soshiUsername:
//                                                         friend.soshiUsername,
//                                                     refreshScreen:
//                                                         () {}); // show friend popup when tile is pressed
//                                               },
//                                               leading: ProfilePic(
//                                                   radius: 30,
//                                                   url: friend.photoURL),

//                                               // CircleAvatar(
//                                               //   radius: 35.0,
//                                               //   backgroundImage: NetworkImage(friend.photoURL),
//                                               // ),
//                                               title: Column(
//                                                 children: <Widget>[
//                                                   Text(friend.fullName,
//                                                       style: TextStyle(
//                                                           color:
//                                                               Colors.cyan[600],
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontSize: 20)),
//                                                   Text(
//                                                     "@" + friend.soshiUsername,
//                                                     style: TextStyle(
//                                                         color: Colors.grey[500],
//                                                         fontSize: 15,
//                                                         fontStyle:
//                                                             FontStyle.italic),
//                                                   ),
//                                                 ],
//                                               ),
//                                               tileColor: Colors.grey[900],
//                                               selectedTileColor:
//                                                   Constants.buttonColorLight,
//                                               contentPadding:
//                                                   EdgeInsets.all(10),
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(15),
//                                                   side: BorderSide(
//                                                       width: 2,
//                                                       color: Colors.blueGrey)),
//                                               trailing: Row(
//                                                 children: [
//                                                   IconButton(
//                                                       icon: Icon(
//                                                           Icons.check_circle),
//                                                       color: Colors.green),
//                                                   IconButton(
//                                                     icon: Icon(
//                                                       Icons.delete,
//                                                       size: 30,
//                                                       color: Colors.white,
//                                                     ),
//                                                     color: Colors.black,
//                                                     onPressed: () {
//                                                       showDialog(
//                                                           context: context,
//                                                           builder: (BuildContext
//                                                               context) {
//                                                             return AlertDialog(
//                                                               shape: RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.all(
//                                                                           Radius.circular(
//                                                                               40.0))),
//                                                               backgroundColor:
//                                                                   Colors.blueGrey[
//                                                                       900],
//                                                               title: Text(
//                                                                 "Remove Friend",
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                             .cyan[
//                                                                         600],
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold),
//                                                               ),
//                                                               content: Text(
//                                                                 ("Are you sure you want to decline " +
//                                                                     friend
//                                                                         .fullName +
//                                                                     " as a friend?"),
//                                                                 style: TextStyle(
//                                                                     fontSize:
//                                                                         20,
//                                                                     color: Colors
//                                                                             .cyan[
//                                                                         700],
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold),
//                                                               ),
//                                                               actions: <Widget>[
//                                                                 Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .spaceEvenly,
//                                                                   children: <
//                                                                       Widget>[
//                                                                     TextButton(
//                                                                       child:
//                                                                           Text(
//                                                                         'No',
//                                                                         style: TextStyle(
//                                                                             fontSize:
//                                                                                 20),
//                                                                       ),
//                                                                       onPressed:
//                                                                           () {
//                                                                         Navigator.pop(
//                                                                             context);
//                                                                       },
//                                                                     ),
//                                                                     TextButton(
//                                                                       child:
//                                                                           Text(
//                                                                         'Yes',
//                                                                         style: TextStyle(
//                                                                             fontSize:
//                                                                                 20,
//                                                                             color:
//                                                                                 Colors.red),
//                                                                       ),
//                                                                       onPressed:
//                                                                           () {
//                                                                         // remove from added me list
//                                                                         databaseService
//                                                                             .removeFromAddedMeList(friend.soshiUsername);
//                                                                         Navigator.pop(
//                                                                             context);
//                                                                       },
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ],
//                                                             );
//                                                           });
//                                                     },
//                                                     // shape: RoundedRectangleBorder(
//                                                     //     borderRadius: BorderRadius.circular(60.0)),

//                                                     //itemBuilder: (BuildContext context) {
//                                                     //return [
//                                                     // PopupMenuItem(
//                                                     //     child: IconButton(
//                                                     //         icon: Icon(Icons.delete),
//                                                     //         color: Colors.white,
//                                                     //         iconSize: 40,
//                                                     //         splashColor: Colors.cyan,
//                                                     //         // style: ElevatedButton.styleFrom(
//                                                     //         //     primary: Colors.cyan[800]),
//                                                     //         // Text(
//                                                     //         //   "Remove Friend",
//                                                     //         //   style: TextStyle(color: Colors.black),
//                                                     //         // ),
//                                                     //         onPressed: () async {
//                                                     //           Navigator.pop(context);
//                                                     //           await LocalDataService.removeFriend(
//                                                     //               friendsoshiUsername: friend.soshiUsername);
//                                                     //           databaseService.removeFriend(friendsoshiUsername: friend.soshiUsername);
//                                                     //           refreshFriendScreen();
//                                                     //         }))
//                                                     //   ];
//                                                     // }
//                                                   ),
//                                                 ],
//                                               )),
//                                         );
//                                       },
//                                       itemCount: (addedMeList == null)
//                                           ? 1
//                                           : addedMeList.length,
//                                       padding:
//                                           EdgeInsets.fromLTRB(5.0, 0, 5.0, 5.0))
//                                   : Padding(
//                                       padding: const EdgeInsets.fromLTRB(
//                                           0, 20, 0, 15),
//                                       child: Center(
//                                         child: Column(
//                                           children: <Widget>[
//                                             Text(
//                                               "You're up to date! No one new has added you.",
//                                               style: TextStyle(
//                                                   color: Colors.cyan[300],
//                                                   fontSize: 20,
//                                                   fontStyle: FontStyle.italic,
//                                                   letterSpacing: 2),
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: ElevatedButton(
//                                                 child: Container(
//                                                   child: Row(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                   ),
//                                                 ),
//                                                 style:
//                                                     Constants.ButtonStyleDark,
//                                                 onPressed: () async {},
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                             );
//                           } else {
//                             return Center(
//                                 child: CircularProgressIndicator.adaptive());
//                           }
//                         }),
//                   ));
//             });
//       },
//       child: Icon(Icons.person_add, color: Colors.cyan[300], size: size),
//     );
//   }
// }
