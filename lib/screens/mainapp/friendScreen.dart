import 'dart:convert';

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

  Friend({this.soshiUsername, this.fullName, this.photoURL, this.isVerified});
}

/* This widget displays a list of the user's friends. */
class FriendScreen extends StatefulWidget {
  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // double startingBrightness = LocalDataService.getInitialScreenBrightness();
    // DeviceDisplayBrightness.setBrightness(startingBrightness);
    // DeviceDisplayBrightness.resetBrightness();
  }

  /* refresh screen */
  void refreshFriendScreen() {
    //implement loading icon
    setState(() {});

    print('refreshed');
  }

  /* Generates a list of Friend(s) for the user by fetching data for each soshiUsername in their friends list */
  Future<List<Friend>> generateFriendsList(DatabaseService databaseService) async {
    List<dynamic> friendsListsoshiUsernames;
    friendsListsoshiUsernames = LocalDataService.getLocalFriendsList();
    // store list of friend soshiUsernames
    List<Friend> formattedFriendsList = [];
    List<String> friendsToRemove = [];
    Map friendData;
    String fullName, username, photoURL; // store data of current friend in list
    bool isVerified;
    String othersoshiUsername;
    for (int i = friendsListsoshiUsernames.length - 1; i >= 0; i--) {
      friendData = await databaseService.getUserFile(friendsListsoshiUsernames[i]);
      othersoshiUsername = friendsListsoshiUsernames[i];
      if (friendData != null) {
        // ensure friend exists in database
        // if friend exists in database
        fullName = databaseService.getFullName(friendData);
        photoURL = databaseService.getPhotoURL(friendData);
        isVerified = databaseService.getVerifiedStatus(friendData);
        formattedFriendsList.add(new Friend(
            // instantiate new friend and add to list
            soshiUsername: othersoshiUsername,
            fullName: fullName,
            photoURL: photoURL,
            isVerified: isVerified));
      } else {
        // if friend no longer exists, flag friend for removal
        friendsToRemove.add(othersoshiUsername);
      }
    }
    for (String othersoshiUsername in friendsToRemove) {
      // remove friends that no longer exist
      await LocalDataService.removeFriend(friendsoshiUsername: othersoshiUsername);
      await databaseService.removeFriend(friendSoshiUsername: othersoshiUsername);
    }

    return formattedFriendsList;
  }

  /* Creates a single "friend tile" (an element of the ListView of Friends) */
  Widget createFriendTile({BuildContext context, Friend friend, DatabaseService databaseService}) {
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 5, 10, 5),
      child: ListTile(
          onTap: () async {
            Popups.showUserProfilePopupNew(context,
                friendSoshiUsername: friend.soshiUsername,
                refreshScreen: refreshFriendScreen); // show friend popup when tile is pressed
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
                        color: Colors.grey[500], fontSize: 15, fontStyle: FontStyle.italic),
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
          tileColor:
              Theme.of(context).brightness == Brightness.light ? Colors.grey[50] : Colors.grey[850],

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
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40.0))),
                      // backgroundColor: Colors.blueGrey[900],
                      title: Text(
                        "Remove Friend",
                        style: TextStyle(
                            // color: Colors.cyan[600],
                            fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        ("Are you sure you want to remove " + friend.fullName + " as a friend?"),
                        style: TextStyle(
                          fontSize: 20,
                          // color: Colors.cyan[700],
                          //fontWeight: FontWeight.bold
                        ),
                      ),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            TextButton(
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 20, color: Colors.blue),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text(
                                'Remove',
                                style: TextStyle(fontSize: 20, color: Colors.red),
                              ),
                              onPressed: () {
                                LocalDataService.removeFriend(
                                    friendsoshiUsername: friend.soshiUsername);
                                databaseService.removeFriend(
                                    friendSoshiUsername: friend.soshiUsername);
                                refreshFriendScreen();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  });
            },
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
    );
  }

  List<Friend> friendsList;
  @override
  Widget build(BuildContext context) {
    //implement loading icon
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    DatabaseService databaseService = new DatabaseService(
        currSoshiUsernameIn: LocalDataService.getLocalUsernameForPlatform("Soshi"));
    return FutureBuilder(
        future: generateFriendsList(databaseService),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // check if request is still loading
            return Center(
                child: CustomThreeInOut(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[500]
                        : Colors.white,
                    size: 50.0));
          } else if (snapshot.connectionState == ConnectionState.none) {
            // check if request is empty
            return Text(
              "No connection!",
              style: TextStyle(
                  // color: Colors.cyan[300],
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.5),
            );
          }
          // check if request is done
          else if (snapshot.connectionState == ConnectionState.done) {
            friendsList = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: ElevatedButton(
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
                                Map friendData =
                                    await databaseService.getUserFile(friendSoshiUsername);
                                bool isFriendAdded =
                                    await LocalDataService.isFriendAdded(friendSoshiUsername);

                                Popups.showUserProfilePopupNew(context,
                                    friendSoshiUsername: friendSoshiUsername, refreshScreen: () {});
                                if (!isFriendAdded &&
                                    friendSoshiUsername != databaseService.currSoshiUsername) {
                                  await LocalDataService.addFriend(
                                      friendsoshiUsername: friendSoshiUsername);
                                  refreshFriendScreen();
                                  databaseService.addFriend(
                                      thisSoshiUsername: databaseService.currSoshiUsername,
                                      friendSoshiUsername: friendSoshiUsername);
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
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.emoji_people, // or Icons.poeple_round
                                color: Colors.cyan,
                                size: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  "Friends",
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
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              "Total: " + LocalDataService.getFriendsListCount().toString(),
                              style: TextStyle(
                                  // color: Colors.cyan[300]
                                  ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ShareButton(
                          size: width / 20,
                          soshiUsername: LocalDataService.getLocalUsername(),
                        )
                        // AddedMeButton(
                        //   size: width / 20,
                        //   soshiUsername: LocalDataService.getLocalUsername(),
                        //   databaseService: databaseService,
                        // ),
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
                      child: friendsList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              // separatorBuilder: (BuildContext context, int i) {
                              // return Padding(padding: EdgeInsets.all(0.0));
                              // },
                              itemBuilder: (BuildContext context, int i) {
                                return Column(
                                  children: [
                                    createFriendTile(
                                        context: context,
                                        friend: friendsList[i],
                                        databaseService: databaseService),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      child: Divider(
                                        color: Colors.grey[500],
                                      ),
                                    )
                                  ],
                                );
                              },
                              itemCount: (friendsList == null) ? 1 : friendsList.length,
                              padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0.0))
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
                    child: Constants.makeBlueShadowButton("Add new friends", Icons.person_add,
                        () async {
                      String QRScanResult = await Utilities.scanQR(mounted);
                      if (QRScanResult.length > 5) {
                        // vibrate when QR code is successfully scanned
                        Vibration.vibrate();
                        try {
                          String friendSoshiUsername = QRScanResult.split("/").last;
                          Map friendData = await databaseService.getUserFile(friendSoshiUsername);
                          bool isFriendAdded =
                              await LocalDataService.isFriendAdded(friendSoshiUsername);

                          Popups.showUserProfilePopupNew(context,
                              friendSoshiUsername: friendSoshiUsername, refreshScreen: () {});
                          if (!isFriendAdded &&
                              friendSoshiUsername != databaseService.currSoshiUsername) {
                            await LocalDataService.addFriend(
                                friendsoshiUsername: friendSoshiUsername);
                            refreshFriendScreen();
                            databaseService.addFriend(
                                thisSoshiUsername: databaseService.currSoshiUsername,
                                friendSoshiUsername: friendSoshiUsername);
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
          }
          return Text("null"); // ensure screen is not null
        });
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
