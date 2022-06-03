import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:vibration/vibration.dart';

import '../../constants/popups.dart';
import '../../constants/utilities.dart';
import '../../constants/widgets.dart';
import '../../services/analytics.dart';
import '../../services/database.dart';
import '../../services/localData.dart';
import 'friendScreen.dart';
import 'groupScreen.dart';

class ViewGroupPage extends StatefulWidget {
  @override
  State<ViewGroupPage> createState() => _ViewGroupPageState();

  Group group;

  ViewGroupPage(this.group);
}

class _ViewGroupPageState extends State<ViewGroupPage> {
  Group group;
  DatabaseService databaseService;
  AsyncMemoizer memoizer;
  bool isAdmin;

  @override
  void initState() {
    String username = LocalDataService.getLocalUsernameForPlatform("Soshi");
    databaseService = new DatabaseService(currSoshiUsernameIn: username);
    this.group = widget.group;
    this.memoizer = new AsyncMemoizer();
    isAdmin = group.admin.contains(username);
    super.initState();
  }

  Future<dynamic> generateGroupUsers() async {
    return this.memoizer.runOnce(() async {
      List<Friend> members =
          await databaseService.membersToFriends(group.members);
      List<Friend> admin = await databaseService.adminToFriends(group.admin);
      return {"members": members, "admin": admin};
    });
  }

  /* Creates a single "friend tile" (an element of the ListView of Friends) */
  Widget createFriendTile(
      {BuildContext context,
      Friend friend,
      DatabaseService databaseService,
      bool adminPrivileges}) {
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);

    return ListTile(
        onTap: () async {
          Popups.showUserProfilePopupNew(context,
              friendSoshiUsername: friend.soshiUsername,
              refreshScreen: () {}); // show friend popup when tile is pressed
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
        trailing: !adminPrivileges
            ? Icon(Icons.arrow_forward_ios, size: 20)
            : IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 30,
                  // color: Colors.white,
                ),
                // color: Colors.black,
                onPressed: () {
                  showModalBottomSheet(
                      constraints: BoxConstraints(
                        maxWidth: width / 1.1,
                        minWidth: width / 1.1,
                      ),
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return MemberOptionsPopup(context, height, width,
                            member: friend);
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
              ));
  }

  @override
  Widget build(BuildContext context) {
    //implement loading icon
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
          child: Container(
        height: height,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    Hero(
                        tag: group.id,
                        child: RectangularProfilePic(
                            radius: width / 3, url: group.photoURL)),
                    SizedBox(height: height / 100),
                    Text(group.name, style: TextStyle(fontSize: 20.0)),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            showModalBottomSheet(
                                isScrollControlled: true,
                                constraints: BoxConstraints(
                                  minWidth: width / 1.1,
                                  maxWidth: width / 1.1,
                                ),
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return ShareGroupPopup(
                                      id: group.id,
                                      height: height,
                                      width: width);
                                });
                          },
                          child: Container(
                              width: width / 3.5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Share",
                                      style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 20.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Icon(
                                      Icons.share,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.white
                                          : Colors.black,
                                    )
                                  ],
                                ),
                              )),
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).brightness !=
                                      Brightness.light
                                  ? Colors.white
                                  : Colors.black,
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)))),
                    )
                  ],
                ),
              ),
              FutureBuilder(
                future: generateGroupUsers(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List admin = snapshot.data["admin"];
                    List members = snapshot.data["members"];
                    return Column(
                      children: [
                        Align(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 2.0),
                            child: Text("Admin (${admin.length})"),
                          ),
                          alignment: Alignment.topLeft,
                        ),
                        Container(
                          child: ListView.builder(
                            padding: EdgeInsets.all(0),
                            shrinkWrap: true,
                            itemCount: admin.length,
                            itemBuilder: (BuildContext context, int i) {
                              return createFriendTile(
                                  context: context,
                                  friend: admin[i],
                                  databaseService: databaseService,
                                  adminPrivileges: false);
                            },
                          ),
                        ),
                        Divider(),
                        Align(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 2.0),
                            child: Text("Members (${members.length})"),
                          ),
                          alignment: Alignment.topLeft,
                        ),
                        Container(
                          child: ListView.builder(
                            padding: EdgeInsets.all(0),
                            shrinkWrap: true,
                            itemCount: members.length,
                            itemBuilder: (BuildContext context, int i) {
                              return createFriendTile(
                                  context: context,
                                  friend: members[i],
                                  databaseService: databaseService,
                                  adminPrivileges: isAdmin);
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container(
                      height: height / 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    );
                  } else {
                    return Center(child: Text("Error loading members :("));
                  }
                },
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class ShareGroupPopup extends StatelessWidget {
  String id;
  double width;
  double height;
  ShareGroupPopup({this.id, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              width: width / 1.1,
              height: height / 2,

              // color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: width / 1.5,
                    width: width / 1.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan[400],

                          Colors.cyan[500],
                          Colors.cyan[900],

                          // Colors.white,
                        ],
                        tileMode: TileMode.mirror,
                      ),
                      boxShadow: [
                        BoxShadow(
                            // color: Colors.grey[900],
                            blurRadius: 3.0,
                            spreadRadius: 0.0,
                            offset: Offset(3.0, 3.0))
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: width / 1.8,
                      width: width / 1.8,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                            text: "https://soshi.app/group/" + id,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text(
                              'Copied link to clipboard :)',
                              textAlign: TextAlign.center,
                            ),
                          ));
                          Analytics.logCopyLinkToClipboard();
                        },
                        child: QrImage(
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                          embeddedImage: NetworkImage(
                              LocalDataService.getLocalProfilePictureURL()),
                          // +
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                          ),
                          data: "https://soshi.app/group/" + id,
                          size: width / 1.35,
                          padding: EdgeInsets.all(20.0),
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Text("Invite others to the group!"),
                  ShareButton(
                    size: width / 20,
                    groupId: id,
                  )
                ],
              )),
          SizedBox(
            height: height / 50,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            height: height / 15,
            width: width / 1.1,
            child: Center(
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close",
                      style:
                          TextStyle(color: Colors.blue, fontSize: width / 22))),
            ),
          ),
          SizedBox(height: height / 50)
        ],
      ),
    );
  }
}

class MemberOptionsPopup extends StatefulWidget {
  BuildContext context;
  double height, width;
  Friend member;

  MemberOptionsPopup(this.context, this.height, this.width, {this.member});

  @override
  State<MemberOptionsPopup> createState() => _MemberOptionsPopupState();
}

class _MemberOptionsPopupState extends State<MemberOptionsPopup> {
  double height, width;
  @override
  Widget build(BuildContext context) {
    width = widget.width;
    height = widget.height;
    return Container(
      height: height / 2.25,
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  )),
              height: width / 1.5,
              // color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProfilePic(
                        radius: widget.width / 10, url: widget.member.photoURL),
                    Text("@" + widget.member.soshiUsername),
                    Divider(color: Colors.grey),
                    InkWell(

                        // promote
                        onTap: () {},
                        child: Container(
                            width: widget.width,
                            child: Text("Promote",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: width / 22)))),
                    Divider(color: Colors.grey),
                    InkWell(
                        // remove
                        onTap: () {},
                        child: Container(
                            width: widget.width,
                            child: Text("Remove",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: width / 22)))),
                  ],
                ),
              )),
          SizedBox(
            height: height / 50,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            height: height / 15,
            width: width / 1.1,
            child: Center(
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close",
                      style: TextStyle(
                          color: Colors.blue, fontSize: widget.width / 22))),
            ),
          ),
          SizedBox(height: height / 50)
        ],
      ),
    );
  }
}
