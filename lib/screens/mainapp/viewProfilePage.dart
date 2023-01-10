import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soshi/screens/login/loading.dart';

import '../../../constants/popups.dart';
import '../../../constants/widgets.dart';
import '../../../services/database.dart';

import 'package:glassmorphism/glassmorphism.dart';

import '../../services/analytics.dart';
import '../../services/contacts.dart';
import '../../services/dataEngine.dart';
import 'package:http/http.dart' as http;

class ViewProfilePage extends StatefulWidget {
  String friendSoshiUsername;
  Function refreshScreen;
  ViewProfilePage({@required this.friendSoshiUsername, this.refreshScreen});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  SoshiUser friendUserObject;
  List<Social> visibleSocials;

  getFriendUserData() async {
    friendUserObject = await DataEngine.getUserObject(
        firebaseOverride: true, friendOverride: widget.friendSoshiUsername);

    visibleSocials = friendUserObject.getSwitchedOnPlatforms();
  }

  @override
  Widget build(BuildContext context) {
    double popupHeightDivisor;
    //double innerContainerSizeDivisor;

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder(
          future: getFriendUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<String> passionNamesFiltered = [];
              List<String> passionEmojiFiltered = [];
              for (int i = 0; i < 3; i++) {
                if (friendUserObject.passions[i].name != "Empty") {
                  passionNamesFiltered.add(friendUserObject.passions[i].name);
                  passionEmojiFiltered.add(friendUserObject.passions[i].emoji);
                }
              }

              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Stack(
                      children: [
                        ProfilePicBackdrop(friendUserObject.photoURL,
                            height: height / 2, width: width),
                        GlassmorphicContainer(
                          height: height / 2,
                          width: width,
                          borderRadius: 0,
                          blur: 10,
                          alignment: Alignment.bottomCenter,
                          border: 2,
                          linearGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(0.8),
                                (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(0.4),
                              ],
                              stops: [
                                0.1,
                                1,
                              ]),
                          borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (Theme.of(context).brightness == Brightness.light
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(0.5),
                              (Theme.of(context).brightness == Brightness.light
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(0.5),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                width / 40, height / 20, width / 40, 0),
                            child: Column(
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CupertinoBackButton(),
                                      Column(
                                        children: [
                                          Container(
                                            width: width / 1.5,
                                            // color: Colors.grey,
                                            child: Center(
                                              child: AutoSizeText(
                                                "${friendUserObject.firstName} ${friendUserObject.lastName}",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: width / 16),
                                              ),
                                            ),
                                          ),
                                          SoshiUsernameText(
                                              friendUserObject.soshiUsername,
                                              fontSize: width / 22,
                                              isVerified:
                                                  friendUserObject.verified)
                                        ],
                                      ),
                                      CupertinoBackButton(
                                          onPressed: () {},
                                          color: Colors.transparent),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height / 50),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: width / 4,
                                        child: Column(children: [
                                          Text(
                                            friendUserObject.friends.length
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: width / 24,
                                                letterSpacing: 1.2,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          friendUserObject.friends.length == 1
                                              ? Text(
                                                  "Friend",
                                                  style: TextStyle(
                                                      fontSize: width / 24,
                                                      letterSpacing: 1.2),
                                                )
                                              : Text(
                                                  "Friends",
                                                  style: TextStyle(
                                                      fontSize: width / 24,
                                                      letterSpacing: 1.2),
                                                )
                                        ]),
                                      ),
                                      Hero(
                                        tag: friendUserObject.soshiUsername,
                                        child: ProfilePic(
                                            radius: width / 6.5,
                                            url: friendUserObject.photoURL),
                                      ),
                                      SizedBox(
                                        width: width / 4,
                                        child: Column(children: [
                                          Text(
                                            friendUserObject.soshiPoints == null
                                                ? "0"
                                                : friendUserObject.soshiPoints
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: width / 24,
                                                letterSpacing: 1.2,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          friendUserObject.soshiPoints
                                                      .toString() ==
                                                  "1"
                                              ? Text("Bolt",
                                                  style: TextStyle(
                                                      fontSize: width / 24,
                                                      letterSpacing: 1.2))
                                              : Text("Bolts",
                                                  style: TextStyle(
                                                      fontSize: width / 24,
                                                      letterSpacing: 1.2))
                                        ]),
                                      ),
                                    ],
                                  ),
                                ),
                                //SizedBox(height: height / 1),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        width / 7, 0, width / 7, 0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          child: //Padding(
                                              //padding: EdgeInsets.fromLTRB(width / 5, 0, width / 5, 0),
                                              //child:
                                              Visibility(
                                                  visible:
                                                      friendUserObject.bio !=
                                                          null,
                                                  child: Text(
                                                      friendUserObject.bio ??
                                                          "",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: width / 25
                                                          // color: Colors.grey[300],
                                                          )))),
                                    )
                                    //),
                                    ),
                                SizedBox(
                                  height: height / 30,
                                ),
                                //FIX LATE - BY SRI

                                Visibility(
                                  visible: passionNamesFiltered != null ||
                                      passionNamesFiltered.isNotEmpty,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        width / 35, 0, width / 35, 0),
                                    child: Center(
                                      child: SizedBox(
                                        width: width / 1.1,
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: width / 65,
                                          children: List.generate(
                                              passionNamesFiltered.length, (i) {
                                            return PassionBubble(
                                                passionNamesFiltered[i],
                                                passionEmojiFiltered[i]);
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: height / 2.2,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: height / 45,
                          ),
                          AddFriendButton(
                              friend: Friend(
                                  soshiUsername: friendUserObject.soshiUsername,
                                  fullName: (friendUserObject.firstName +
                                      " " +
                                      friendUserObject.lastName),
                                  photoURL: friendUserObject.photoURL,
                                  isVerified: friendUserObject.verified),
                              height: height,
                              width: width),
                          Container(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  width / 35, height / 50, width / 35, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: width / 40),
                                    child: Text(
                                      "Socials",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: width / 17),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height / 300,
                                  ),
                                  Center(
                                    child: (visibleSocials == null ||
                                            visibleSocials.isEmpty == true)
                                        ? Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Text(
                                                "This user isn't currently sharing any social media platforms :(",
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            // height: height / 3.5,
                                            width: width / 1.1,
                                            // child: GridView.builder(
                                            //   physics:
                                            //       const NeverScrollableScrollPhysics(),
                                            //   shrinkWrap: true,
                                            //   itemBuilder:
                                            //       (BuildContext context, int i) {
                                            //         Social currentPlatform = visibleSocials[i];

                                            //     return Padding(
                                            //         padding: const EdgeInsets.fromLTRB(
                                            //             0, 0, 0, 10),
                                            //         child: Popups.createSMButton(
                                            //             soshiUsername:
                                            //                 friendSoshiUsername,
                                            //             platform: visiblePlatforms[i],
                                            //             username: usernames[
                                            //                 visiblePlatforms[i]],
                                            //             size: width / 15,
                                            //             context: context));
                                            //   },
                                            //   itemCount: visibleSocials.length,
                                            //   gridDelegate:
                                            //       SliverGridDelegateWithFixedCrossAxisCount(
                                            //           crossAxisCount: 4,
                                            //           childAspectRatio: .9,
                                            //           crossAxisSpacing: width / 60),
                                            // ),
                                            child: Wrap(
                                              alignment: WrapAlignment.center,
                                              spacing: width / 40,
                                              children: List.generate(
                                                  visibleSocials.length, (i) {
                                                return SMButton(
                                                  soshiUsername:
                                                      friendUserObject
                                                          .soshiUsername,
                                                  platform: visibleSocials[i]
                                                      .platformName,
                                                  username: visibleSocials[i]
                                                      .username,
                                                  size: width / 7,
                                                );
                                              }),
                                            )),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        0, height / 30, 0, height / 20),
                                    child: Center(
                                      child: Visibility(
                                        //Remove harcode later
                                        visible: false,
                                        // visible: false,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            DialogBuilder(context)
                                                .showLoadingIndicator();

                                            double width =
                                                MediaQuery.of(context)
                                                    .size
                                                    .width;
                                            // DatabaseService databaseService =
                                            //     new DatabaseService(currSoshiUsernameIn: soshiUsername);
                                            // Map userData = await databaseService.getUserFile(soshiUsername);

                                            String firstName =
                                                friendUserObject.firstName;
                                            String lastName =
                                                friendUserObject.lastName;
                                            String email = friendUserObject
                                                .getUsernameGivenPlatform(
                                                    platform: "Email");
                                            String phoneNumber =
                                                friendUserObject
                                                    .getUsernameGivenPlatform(
                                                        platform: "Phone");
                                            String photoUrl =
                                                friendUserObject.photoURL;

                                            Uint8List profilePicBytes;

                                            try {
                                              // try to load profile pic from url
                                              await http
                                                  .get(Uri.parse(photoUrl))
                                                  .then(
                                                      (http.Response response) {
                                                profilePicBytes =
                                                    response.bodyBytes;
                                              });
                                            } catch (e) {
                                              // if url is invalid, use default profile pic
                                              ByteData data = await rootBundle.load(
                                                  "assets/images/misc/default_pic.png");
                                              profilePicBytes =
                                                  data.buffer.asUint8List();
                                            }
                                            Contact newContact = new Contact(
                                                givenName: firstName,
                                                familyName: lastName,
                                                emails: [
                                                  Item(
                                                      label: "Email",
                                                      value: email),
                                                ],
                                                phones: [
                                                  Item(
                                                      label: "Cell",
                                                      value: phoneNumber),
                                                ],
                                                avatar: profilePicBytes);
                                            await askPermissions(context);

                                            await ContactsService.addContact(
                                                newContact);

                                            DialogBuilder(context)
                                                .hideOpenDialog();

                                            Popups.showContactAddedPopup(
                                                context,
                                                width,
                                                photoUrl,
                                                firstName,
                                                lastName,
                                                phoneNumber,
                                                email);

                                            //ContactsService.openContactForm();
                                            // ContactsService.addContact(newContact).then((dynamic success) {
                                            // });
                                            //         ContactsService.addContact(newContact).then(dynamic success)
                                            // {             ContactsService.openExistingContact(newContact);
                                            //       };

                                            // .then((dynamic success) {
                                            //   Popups.showContactAddedPopup(context, width, firstName, lastName);
                                            // });
                                          },
                                          child: Container(
                                            height: height / 22,
                                            width: width / 2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Image.asset(
                                                  "assets/images/SMLogos/ContactLogo.png",
                                                  //width: width / 10
                                                  //height: height / 5,
                                                ),
                                                Text(
                                                  "Add To Contacts + ",
                                                  style: TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontSize: width / 25,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.black,
                                            primary:
                                                Colors.white.withOpacity(0.6),
                                            // side: BorderSide(color: Colors.cyan[400]!, width: 2),
                                            elevation: 20,
                                            padding: const EdgeInsets.all(15.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator.adaptive());
            }
          }),
    );
  }
}

class AddFriendButton extends StatefulWidget {
  @override
  State<AddFriendButton> createState() => _AddFriendButtonState();

  Friend friend;
  Function refreshFunction;
  double height, width;
  AddFriendButton(
      {@required this.friend,
      @required this.refreshFunction,
      @required this.height,
      @required this.width});
}

class _AddFriendButtonState extends State<AddFriendButton> {
  double height;
  double width;
  bool isFriendAdded;
  bool isAdding = false;
  String friendSoshiUsername;
  Function refreshFunction;
  DatabaseService databaseService;
  String soshiUsername = DataEngine.soshiUsername;

  @override
  void initState() {
    height = widget.height;
    width = widget.width;
    friendSoshiUsername = widget.friend.soshiUsername;
    refreshFunction = widget.refreshFunction;
    isFriendAdded = DataEngine.globalUser.friends.contains(friendSoshiUsername);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NeumorphicButton(
          onPressed: () async {
            if (isFriendAdded || friendSoshiUsername == soshiUsername) {
              // do nothing
              return;
            } else {
              setState(() {
                isAdding = true;
              });
              // isFriendAdded =
              //     DataEngine.globalUser.friends.contains(friendSoshiUsername);

              if (!isFriendAdded) {
                List<Friend> friends = await DataEngine.getCachedFriendsList();
                friends.add(widget.friend); // update friends cached list
                DataEngine.updateCachedFriendsList(friends: friends);
                DataEngine.globalUser.friends
                    .add(friendSoshiUsername); // update friends string list
                DataEngine.globalUser.soshiPoints =
                    DataEngine.globalUser.soshiPoints +
                        25; // Adding 25 points for every friend added
                DataEngine.applyUserChanges(
                    user: DataEngine.globalUser, cloud: true, local: true);
              }

              Analytics.logAddFriend(friendSoshiUsername);
              setState(() {
                isAdding = false;
                isFriendAdded = true;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
                height: height / 40,
                width: width / 1.7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    isAdding
                        ? CircularProgressIndicator.adaptive()
                        : (isFriendAdded
                            ? Text(
                                "Friend Added",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: GoogleFonts.inter().fontFamily,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.8,
                                    fontSize: width / 22.5),
                              )
                            : Text(
                                "Add Friend",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: GoogleFonts.inter().fontFamily,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.8,
                                    fontSize: width / 22.5),
                              ))
                  ],
                )),
          ),
          style: NeumorphicStyle(
              shadowDarkColor: Colors.black,
              shadowLightColor: Colors.black12,
              color: isFriendAdded ? Colors.black : Colors.blue,
              boxShape:
                  NeumorphicBoxShape.roundRect(BorderRadius.circular(20.0)))),
    );
  }
}
