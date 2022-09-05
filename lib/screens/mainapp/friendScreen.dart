import 'dart:convert';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/popups.dart';
import 'package:soshi/screens/mainapp/viewProfilePage.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';

import '../../services/dataEngine.dart';

/* This widget displays a list of the user's friends. */
class FriendScreen extends StatefulWidget {
  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen>
    with TickerProviderStateMixin {
  SoshiUser user;
  List recentFriendsList;
  List friendsList;
  List<Friend> formattedFriendsList = [];
  List<Friend> formattedFriendsListOriginal = [];
  List<Friend> formattedRecentsList = [];
  List<String> friendsListNames;
  TextEditingController searchController;
  AsyncMemoizer memoizer;
  bool hideRecents, isSearching = false;
  bool showKeyboard;

  @override
  void initState() {
    // friendsListNames = LocalDataService.getLocalFriendsListNames();
    // recentFriendsList = LocalDataService.getRecentlyAddedFriends();
    // friendsList = LocalDataService.getLocalFriendsList();

    // showKeyboard = isSearching = false;
    // hideRecents =
    //     (friendsList.length < 5); // hide recents if 5 or fewer total friends

    // searchController = TextEditingController();
    // searchController.addListener(() {
    //   String text = searchController.text;
    //   if (text.isNotEmpty) {
    //     filterList(searchController.text);
    //   } else {
    //     // if empty, go back to full list
    //     setState(() {
    //       isSearching = true;
    //       formattedFriendsList = List.from(formattedFriendsListOriginal);
    //     });
    //   }
    // });
    // double startingBrightness = LocalDataService.getInitialScreenBrightness();
    // DeviceDisplayBrightness.setBrightness(startingBrightness);
    // DeviceDisplayBrightness.resetBrightness();
    // memoizer = new AsyncMemoizer()
    // generateFriendsList();
    super.initState();
  }

  loadDataEngine() async {
    this.user = await DataEngine.getUserObject(firebaseOverride: false);

    print(DataEngine.serializeUser(this.user));
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
      print("HELLO" + formattedFriendsList.toString());

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
    log('refreshed friends screen');
  }

  // convert json friends list to list of Friend(s)
  // void generateFriendsList() {
  //   for (String json in friendsList) {
  //     formattedFriendsList.add(Friend.decodeFriend(json));
  //   }
  //   // get recently added friends list
  //   String currUsername;
  //   for (String json in recentFriendsList) {
  //     // find in friends
  //     currUsername = jsonDecode(json)["u"];
  //     for (Friend friend in formattedFriendsList) {
  //       if (currUsername == friend.soshiUsername) {
  //         formattedRecentsList.add(friend);
  //       }
  //     }
  //   }

  //   formattedFriendsListOriginal
  //       .addAll(formattedFriendsList); // store copy of original
  // }

  @override
  Widget build(BuildContext context) {
    //implement loading icon
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    DatabaseService databaseService = new DatabaseService(
        currSoshiUsernameIn:
            LocalDataService.getLocalUsernameForPlatform("Soshi"));

    String soshiUsername = LocalDataService.getLocalUsername();

    // bool soshiPointsInjection =
    //     LocalDataService.getInjectionFlag("Soshi Points");

    // if (soshiPointsInjection == false || soshiPointsInjection == null) {
    //   LocalDataService.updateInjectionFlag("Soshi Points", true);
    //   databaseService.updateInjectionSwitch(
    //       soshiUsername, "Soshi Points", true);

    //   int numFriends = LocalDataService.getFriendsListCount();
    //   LocalDataService.updateSoshiPoints(numFriends * 8);

    //   databaseService.updateSoshiPoints(soshiUsername, (numFriends * 8));
    // }

    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Container(
              child: Container(
            // height: height,
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //   padding:
                //       const EdgeInsets.fromLTRB(25.0, 0, 25.0, 10.0),
                //   child: Container(
                //     height: height / 18,
                //     child: CupertinoSearchTextField(
                //       controller: searchController,
                //       placeholder:
                //           "Search ${formattedFriendsList.length} " +
                //               ((formattedFriendsList.length > 1)
                //                   ? "friends..."
                //                   : "friend..."),
                //       // placeholder: 'Search \"${[
                //       //   "Jason S",
                //       //   "Yuvan",
                //       //   "Kallie",
                //       //   "Michelle",
                //       //   "Sid Jagtap",
                //       //   "Sri"
                //       // ][Random().nextInt(5)]}\"',

                //       //     ),
                //     ),
                //   ),
                // ),
                // Visibility(
                //   visible: formattedRecentsList.isNotEmpty,
                //   child: Padding(
                //       padding: const EdgeInsets.fromLTRB(
                //           16.0, 10.0, 16.0, 0.0),
                //       child: Text("Recently Added")),
                // ),
                // Visibility(
                //   visible: formattedRecentsList.isNotEmpty,
                //   child: Container(
                //     height: width / 3.5,
                //     child: Center(
                //       child: SizedBox(
                //         width: width / 1.2,
                //         child: Row(
                //             mainAxisAlignment:
                //                 MainAxisAlignment.spaceEvenly,
                //             children: List.generate(
                //                 formattedRecentsList.length, (i) {
                //               return Padding(
                //                 padding: EdgeInsets.all(width / 30),
                //                 child: GestureDetector(
                //                   onTap: () {
                //                     Navigator.push(context,
                //                         MaterialPageRoute(
                //                             builder: (context) {
                //                       Friend friend =
                //                           formattedRecentsList[i];
                //                       return ViewProfilePage(
                //                           friendSoshiUsername:
                //                               friend.soshiUsername,
                //                           refreshScreen:
                //                               refreshFriendScreen,
                //                           friend:
                //                               friend); // show friend popup when tile is pressed
                //                     }));
                //                   },
                //                   child: Column(
                //                     children: [
                //                       Padding(
                //                         padding:
                //                             const EdgeInsets.all(4.0),
                //                         child: ProfilePic(
                //                             radius: width / 14,
                //                             url: formattedRecentsList[i]
                //                                 .photoURL),
                //                       ),
                //                       SoshiUsernameText(
                //                           formattedRecentsList[i]
                //                               .soshiUsername,
                //                           fontSize: 14,
                //                           isVerified:
                //                               formattedFriendsList[i]
                //                                   .isVerified),
                //                     ],
                //                   ),
                //                 ),
                //               );
                //             })),
                //       ),
                //     ),
                //   ),
                // ),
                // Padding(
                //     padding: EdgeInsets.fromLTRB(16.0, 3.0, 16.0, 0),
                //     child: Text("A-Z")),
                FutureBuilder(
                    future: loadDataEngine(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        {
                          formattedFriendsList = user.friends.cast<Friend>();
                          if (formattedFriendsList.isNotEmpty) {
                            return Column(
                              children: List.generate(
                                formattedFriendsList.length,
                                (i) {
                                  // print(formattedFriendsList.toString());
                                  if (i >= formattedFriendsList.length ||
                                      formattedFriendsList.isEmpty) {
                                    return Container();
                                  }
                                  return FriendTile(
                                      refreshFriendScreen: refreshFriendScreen,
                                      friend: formattedFriendsList[i],
                                      databaseService: databaseService);
                                },
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                              child: Center(
                                child: Text(
                                  "You have no friends :(",
                                  style:
                                      TextStyle(fontSize: 20, letterSpacing: 2),
                                ),
                              ),
                            );
                          }
                        }
                      } else {
                        return CircularProgressIndicator.adaptive();
                      }
                    }),
                SizedBox(
                  height: height / 100,
                )
              ],
            ),
          )),
        ),
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
        //   child: Constants.makeBlueShadowButton(
        //       "Add new friends", Icons.person_add, () async {
        //     String QRScanResult = await Utilities.scanQR(mounted);
        //     if (QRScanResult.length > 5) {
        //       // vibrate when QR code is successfully scanned
        //       Vibration.vibrate();
        //       try {
        //         if (QRScanResult.contains("https://soshi.app/deeplink/group")) {
        //           String groupId = QRScanResult.split("/").last;
        //           await Popups.showJoinGroupPopup(context, groupId);
        //         } else {
        //           String friendSoshiUsername = QRScanResult.split("/").last;
        //           Map friendData =
        //               await databaseService.getUserFile(friendSoshiUsername);
        //           Friend friend = databaseService.userDataToFriend(friendData);
        //           bool isFriendAdded =
        //               await LocalDataService.isFriendAdded(friendSoshiUsername);

        //           Navigator.push(context, MaterialPageRoute(builder: (context) {
        //             return ViewProfilePage(
        //               friendSoshiUsername: friend.soshiUsername,
        //               refreshScreen: () {},
        //             ); // show friend popup when tile is pressed
        //           }));
        //           if (!isFriendAdded &&
        //               friendSoshiUsername !=
        //                   databaseService.currSoshiUsername) {
        //             List<String> newFriendsList =
        //                 await LocalDataService.addFriend(friend: friend);
        //             refreshFriendScreen();
        //             // databaseService.addFriend(
        //             //     thisSoshiUsername:
        //             //         databaseService.currSoshiUsername,
        //             //     friendSoshiUsername: friendSoshiUsername);
        //             databaseService.overwriteFriendsList(newFriendsList);
        //           }

        //           // bool friendHasTwoWaySharing = await databaseService.getTwoWaySharing(friendData);
        //           // if (friendHasTwoWaySharing == null || friendHasTwoWaySharing == true) {
        //           //   // if user has two way sharing on, add self to user's friends list
        //           //   databaseService.addFriend(thisSoshiUsername: friendSoshiUsername, friendSoshiUsername: databaseService.currSoshiUsername);
        //           // }
        //           //add friend right here

        //           Analytics.logQRScan(
        //               QRScanResult, true, "friendScreen.dart Add new friends");
        //         }
        //       } catch (e) {
        //         Analytics.logQRScan(
        //             QRScanResult, false, "friendScreen.dart Add new friends");
        //         print(e);
        //       }
        //     }
        //   }),
        // )
      ],
    ));
    //   }
    //   return Text("Error loading friends :("); // ensure screen is not null
    // });
  }
}

class SoshiPointsButton extends StatelessWidget {
  double height, width;
  int soshiPointsCurr;
  double soshiPointsButtonWidth;
  SoshiPointsButton(this.height, this.width);

  @override
  Widget build(BuildContext context) {
    soshiPointsCurr = LocalDataService.getSoshiPoints();
    soshiPointsCurr < 10
        ? soshiPointsButtonWidth = 5.7
        : soshiPointsCurr < 100
            ? soshiPointsButtonWidth = 4.85
            : soshiPointsCurr < 1000
                ? soshiPointsButtonWidth = 4.25
                : soshiPointsButtonWidth = 3.7;
    return Container(
      //decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      width: width / soshiPointsButtonWidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: .5,
          // shadowColor: Colors.cyan,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
        ),
        onPressed: () {
          Popups.soshiPointsExplainedPopup(context, width, height);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: width / 18,
              child: Flex(direction: Axis.horizontal, children: <Widget>[
                Expanded(
                  child: Icon(CupertinoIcons.bolt,
                      size: width / 20, color: Colors.grey),
                ),
              ]),
            ),
            SizedBox(
              width: 4,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Text(
                soshiPointsCurr.toString(),
                style: TextStyle(
                    fontSize: width / 22,
                    // color: Colors.cyan[300]
                    color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  Friend friend;
  DatabaseService databaseService;
  Function refreshFriendScreen;

  FriendTile({this.friend, this.databaseService, this.refreshFriendScreen});
  /* Creates a single "friend tile" (an element of the ListView of Friends) */

  Widget build(BuildContext context) {
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);

    return Container(
      height: height / 10,
      child: ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ViewProfilePage(
                  friendSoshiUsername: friend.soshiUsername,
                  refreshScreen: refreshFriendScreen,
                  friend: friend); // show friend popup when tile is pressed
            }));
          },
          leading: Hero(
              tag: friend.soshiUsername,
              child: ProfilePic(radius: width / 14, url: friend.photoURL)),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(friend.fullName,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                      // color: Colors.cyan[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              SizedBox(height: height / 170),
              SoshiUsernameText(friend.soshiUsername,
                  fontSize: 14, isVerified: friend.isVerified)
            ],
          ),
          tileColor: Colors.transparent,

          // selectedTileColor: Constants.buttonColorLight,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            // side: BorderSide(width: .5)
          ),
          trailing: IconButton(
              icon: Icon(
                Icons.more_horiz_rounded,
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
                                            padding: EdgeInsets.fromLTRB(0,
                                                height / 160, 0, height / 100),
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
                                                ),
                                              ),
                                              SizedBox(
                                                width: width / 130,
                                              ),
                                              friend.isVerified == null ||
                                                      friend.isVerified == false
                                                  ? Container()
                                                  : Image.asset(
                                                      "assets/images/misc/verified.png",
                                                      scale: width / 21,
                                                    )
                                            ],
                                          ),
                                          Divider(),
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
                                                  await LocalDataService.removeFriend(
                                                      friendsoshiUsername: friend
                                                          .soshiUsername); // update local list
                                              databaseService.overwriteFriendsList(
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
              })),
    );
  }
}
