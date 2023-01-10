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
import 'package:vibration/vibration.dart';

import '../../services/analytics.dart';
import '../../services/dataEngine.dart';
import '../../services/dynamicLinks.dart';

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
  //List<Friend> formattedRecentsList = [];
  List<String> friendsListNames;
  TextEditingController searchController;
  AsyncMemoizer memoizer;
  bool hideRecents, isSearching = false;
  bool showKeyboard;

  @override
  void initState() {
    super.initState();
  }

  loadDataEngine() async {
    // this.user = await DataEngine.getUserObject(firebaseOverride: false);
    this.formattedFriendsList = await DataEngine.getCachedFriendsList();
    // print(formattedFriendsList.toString());
    print("uv likes men");
    print(formattedFriendsList.toString());

    //print(DataEngine.serializeUser(this.user));
  }

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
    log('refreshed friends screen');
  }

  @override
  Widget build(BuildContext context) {
    //implement loading icon
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

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
                FutureBuilder(
                    future: loadDataEngine(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        {
                          if (formattedFriendsList.isNotEmpty) {
                            return Column(
                              children: List.generate(
                                formattedFriendsList.length,
                                (i) {
                                  if (i >= formattedFriendsList.length) {
                                    return Container();
                                  }
                                  return FriendTile(
                                    friends: formattedFriendsList,
                                    user: user,
                                    refreshFriendScreen: refreshFriendScreen,
                                    friend: formattedFriendsList[
                                        formattedFriendsList.length - 1 - i],
                                  );
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
                        return Center(
                            child: CircularProgressIndicator.adaptive());
                      }
                    }),
                SizedBox(
                  height: height / 100,
                ),
              ],
            ),
          )),
        ),
      ],
    ));
  }
}

// class SoshiPointsButton extends StatelessWidget {
//   double height, width;
//   int soshiPointsCurr;
//   double soshiPointsButtonWidth;
//   SoshiPointsButton(this.height, this.width);

//   @override
//   Widget build(BuildContext context) {
//     soshiPointsCurr = LocalDataService.getSoshiPoints();

//     soshiPointsCurr < 10
//         ? soshiPointsButtonWidth = 5.7
//         : soshiPointsCurr < 100
//             ? soshiPointsButtonWidth = 4.85
//             : soshiPointsCurr < 1000
//                 ? soshiPointsButtonWidth = 4.25
//                 : soshiPointsButtonWidth = 3.7;
//     return Container(
//       //decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
//       width: width / soshiPointsButtonWidth,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           elevation: .5,
//           // shadowColor: Colors.cyan,
//           shape: new RoundedRectangleBorder(
//             borderRadius: new BorderRadius.circular(30.0),
//           ),
//         ),
//         onPressed: () {
//           Popups.soshiPointsExplainedPopup(context, width, height);
//         },
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Container(
//               width: width / 18,
//               child: Flex(direction: Axis.horizontal, children: <Widget>[
//                 Expanded(
//                   child: Icon(CupertinoIcons.bolt,
//                       size: width / 20, color: Colors.grey),
//                 ),
//               ]),
//             ),
//             SizedBox(
//               width: 4,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 0),
//               child: Text(
//                 soshiPointsCurr.toString(),
//                 style: TextStyle(
//                     fontSize: width / 22,
//                     // color: Colors.cyan[300]
//                     color: Colors.grey),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class FriendTile extends StatelessWidget {
  Friend friend;
  DatabaseService databaseService;
  Function refreshFriendScreen;
  SoshiUser user;
  List<Friend> friends;
  FriendTile(
      {@required this.user,
      @required this.friends,
      this.friend,
      this.databaseService,
      this.refreshFriendScreen});
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
              ); // show friend popup when tile is pressed
            }));
          },
          leading: Hero(
              tag: friend.fullName,
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
                                              // List<String> newFriendsList =
                                              //     await LocalDataService.removeFriend(
                                              //         friendsoshiUsername: friend
                                              //             .soshiUsername); // update local list
                                              // databaseService.overwriteFriendsList(
                                              //     newFriendsList); // update cloud list
                                              // DataEngine.applyUserChanges(user:  user, cloud: true, local: true)
                                              friends.removeWhere(
                                                  (removedFriendObj) =>
                                                      removedFriendObj
                                                          .soshiUsername ==
                                                      friend
                                                          .soshiUsername); // update cached list
                                              DataEngine
                                                  .updateCachedFriendsList(
                                                      friends: friends);
                                              DataEngine.globalUser.friends
                                                  .remove(friend
                                                      .soshiUsername); // update string list
                                              DataEngine.applyUserChanges(
                                                  user: DataEngine.globalUser,
                                                  cloud: true,
                                                  local: true);
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
