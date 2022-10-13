// ignore_for_file: must_be_immutable

import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
// import 'package:device_display_brightness/device_display_brightness.dart';

import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/screens/mainapp/editHandles.dart';
import 'package:soshi/screens/mainapp/passions.dart';
import 'package:soshi/services/contacts.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/services/url.dart';
import 'chooseSocials.dart';
import 'profileSettings.dart';
import 'package:http/http.dart' as http;

/*
A social media card used in the profile (one card per platform)
*/

class SMTile extends StatefulWidget {
  SoshiUser user;
  Social selectedSocial;
  ValueNotifier importProfileNotifier;
  SMTile(
      {@required this.user,
      @required this.selectedSocial,
      @required this.importProfileNotifier});
  @override
  _SMTileState createState() => _SMTileState();
}

class _SMTileState extends State<SMTile> {
  DatabaseService databaseService;
  String platformName = "";
  String hintText = "";

  bool isSwitched;
  TextEditingController usernameController = new TextEditingController();
  FocusNode focusNode;

  String soshiUsername;

  @override
  void initState() {
    soshiUsername = widget.user.soshiUsername;
    platformName = widget.selectedSocial.platformName;
    isSwitched = widget.selectedSocial.switchStatus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    platformName = widget.selectedSocial.platformName;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (platformName == "Phone") {
      hintText = "Phone Number";
    } else if (["Linkedin", "Facebook", "Personal"].contains(platformName)) {
      hintText = "Link to Profile";
    } else if (platformName == "Cryptowallet") {
      hintText = "Wallet address";
    } else {
      hintText = "Username";
    }
    if (platformName == "Contact") {
      usernameController.text = "Contact Card";
    }

    focusNode = new FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        if (!isSwitched) {
          setState(() {
            isSwitched = true;
          });

          if (widget.user.getUsernameGivenPlatform(platform: platformName) ==
                  null ||
              widget.user.getUsernameGivenPlatform(platform: platformName) ==
                  "") {
            if (platformName != "Contact") {
              Popups.editUsernamePopup(context, platformName,
                  MediaQuery.of(context).size.width, DataEngine.globalUser);
            }
          }

          widget.selectedSocial.switchStatus = true;
        }
        String usernameControllerLower = usernameController.text.toLowerCase();
        widget.selectedSocial.username = usernameControllerLower.trim();

        DataEngine.applyUserChanges(
            user: widget.user, cloud: true, local: true);
      }
    });

    List platformsExceptForContact = [
      "Phone",
      "Instagram",
      "Snapchat",
      "Linkedin",
      "Discord",
      "Tiktok",
      "Twitter",
      "Venmo",
      "Email",
      "Facebook",
      "Reddit",
      "Spotify",
      "Personal"
    ];

    return Neumorphic(
      style: NeumorphicStyle(
          depth: 1,
          //shadowLightColor: Colors.cyan[300],
          color: Theme.of(context).cardColor,
          shape: NeumorphicShape.concave,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(20.0),
          )),
      child: Card(
        elevation: 0,
        child: Container(
          height: MediaQuery.of(context).size.height / 6.5,
          width: MediaQuery.of(context).size.width / 3,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  splashRadius: Utilities.getWidth(context) / 25,
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/SMLogos/' + platformName + 'Logo.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  onPressed: () async {
                    if (platformName == "Contact") {
                      double width = Utilities.getWidth(context);

                      String firstName = widget.user.firstName;
                      String lastName = widget.user.lastName;
                      String photoUrl = widget.user.photoURL;

                      Uint8List profilePicBytes;
                      try {
                        // try to load profile pic from url
                        await http
                            .get(Uri.parse(photoUrl))
                            .then((http.Response response) {
                          profilePicBytes = response.bodyBytes;
                        });
                      } catch (e) {
                        // if url is invalid, use default profile pic
                        ByteData data = await rootBundle
                            .load("assets/images/SoshiLogos/soshi_icon.png");
                        profilePicBytes = data.buffer.asUint8List();
                      }
                      Contact contact = new Contact(
                          givenName: firstName,
                          familyName: lastName,
                          emails: [
                            Item(
                                label: "Email",
                                // value: LocalDataService.getLocalUsernameForPlatform("Email"),
                                value: widget.user.getUsernameGivenPlatform(
                                    platform: "Email")),
                          ],
                          phones: [
                            Item(
                                label: "Cell",
                                value: widget.user.getUsernameGivenPlatform(
                                    platform: "Phone")),
                          ],
                          avatar: profilePicBytes);
                      await askPermissions(context);
                      ContactsService.addContact(contact)
                          .then((dynamic success) {
                        Popups.showContactAddedPopup(
                            context,
                            width,
                            photoUrl,
                            firstName,
                            lastName,
                            DataEngine.globalUser
                                .getUsernameGivenPlatform(platform: "Phone"),
                            DataEngine.globalUser
                                .getUsernameGivenPlatform(platform: "Email"));
                      });
                    } else if (platformName == "Cryptowallet") {
                      Clipboard.setData(ClipboardData(
                        text: widget.user
                            .getUsernameGivenPlatform(platform: "Cryptowallet")
                            .toString(),
                      ));

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                          'Wallet address copied to clipboard!',
                          textAlign: TextAlign.center,
                        ),
                      ));
                    } else {
                      URL.launchURL(URL.getPlatformURL(
                          platform: platformName,
                          username: widget.user.getUsernameGivenPlatform(
                              platform: platformName)));
                    }
                  },
                  iconSize: 60.0,
                ),
                CupertinoSwitch(
                    thumbColor: Colors.white,
                    value: this.isSwitched,
                    activeColor: Colors.cyan,
                    onChanged: (bool value) {
                      print("Username" +
                          widget.user.getUsernameGivenPlatform(
                              platform: platformName));
                      HapticFeedback.lightImpact();

                      if ((widget.user.getUsernameGivenPlatform(
                                      platform: platformName) ==
                                  null ||
                              widget.user.getUsernameGivenPlatform(
                                      platform: platformName) ==
                                  ""
                          //     &&
                          // value == true
                          ) &&
                          platformName != "Contact") {
                        Popups.editUsernamePopup(
                            context,
                            platformName,
                            MediaQuery.of(context).size.width,
                            DataEngine.globalUser);
                      }

                      if (widget.selectedSocial.username != "") {
                        widget.user.lookupSocial[platformName].switchStatus =
                            value;
                        setState(() {
                          this.isSwitched = value;
                        });

                        //{NOTE} Updating Firestore/local storage will occurr Asynchronously
                        DataEngine.applyUserChanges(
                            user: widget.user, cloud: true, local: true);
                        // not working because of the .tghen, where to put??
                      }
                    }),
              ]),
        ),
      ),
    );

    // double width = Utilities.getWidth(context);
    // text controller for username box
  }
}

/*
A social media card used in the profile (one card per platform)
*/

class AddPlatformsTile extends StatefulWidget {
  ValueNotifier importProfileNotifier;
  SoshiUser user;

  AddPlatformsTile({@required this.importProfileNotifier, @required this.user});

  @override
  _AddPlatformsTileState createState() => _AddPlatformsTileState();
}

class _AddPlatformsTileState extends State<AddPlatformsTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    return NeumorphicButton(
      onPressed: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Scaffold(body: ChooseSocials());
        })).then((value) {
          print("✅ Done adding socials to profile, time to refresh the screen");
          widget.importProfileNotifier.notifyListeners();
        });
      },
      style: NeumorphicStyle(
          depth: 1,
          color: Theme.of(context).cardColor,
          shape: NeumorphicShape.concave,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(20.0),
          )),
      child: Card(
          //semanticContainer: true,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
              height: height / .5,
              width: width / 3,
              child: Center(
                child: Icon(
                  CupertinoIcons.add,
                  size: width / 8,
                  color: Colors.green,
                ),
              ))),
    );
  }
}

class Profile extends StatefulWidget {
  ValueNotifier importProfileNotifier;

  Profile({@required this.importProfileNotifier});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  refreshProfileScreen() {
    setState(() {
      this.userSocials = DataEngine.globalUser.getChosenPlatforms();
    });
  }

  List<Social> userSocials;
  ValueNotifier controlsEditHandlesScreen =
      new ValueNotifier("CONTROL_EDIT_HANDLES");

  @override
  Widget build(BuildContext context) {
    this.userSocials = DataEngine.globalUser.getChosenPlatforms();

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    // UV tried to use the dynamic container size. Will neeed to find a better way.
    int addedContainerSize = 30;
    int numSocialsPlusAddTile = this.userSocials.length + 1;
    int rows = (numSocialsPlusAddTile / 3).ceil();

    if (rows == 1) {
      addedContainerSize = 0;
    }

    if (numSocialsPlusAddTile > 3) {
      print(rows);
      if (rows > 1) {
        for (int i = 0; i < rows; i++) {
          if (i > 2) {
            addedContainerSize += 100;
          } else {
            addedContainerSize += 60;
          }

          // if (height < 800) {
          //   containerSize += .2;
          // } else {
          //   containerSize += .19;
          // }
        }
      }
    }

    return SingleChildScrollView(
      child: Container(
        height: height + addedContainerSize,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  Container(
                    width: width,
                    // height: height / containerSize,
                    height: MediaQuery.of(context).size.height / 2.3,
                    child: Image.network(Defaults.defaultProfilePic,
                        fit: BoxFit.fill),
                  ),
                  ProfilePicBackdrop(DataEngine.globalUser.photoURL,
                      height: height / 2, width: width),
                  GlassmorphicContainer(
                    // height: height / containerSize,
                    height: height / 2,
                    width: width,
                    borderRadius: 0,
                    blur: 8,
                    alignment: Alignment.bottomCenter,
                    border: 2,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(0.8),
                        (Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(0.4)
                      ],
                      stops: [0.1, 1],
                    ),
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
                  ),
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SafeArea(
                          child: Container(
                            // color: Colors.green,
                            // height: height / containerSize,
                            width: width,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  width / 40, width / 40, width / 40, 0),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                        icon: Icon(
                                            CupertinoIcons.line_horizontal_3)),
                                    Column(
                                      children: [
                                        Container(
                                          width: width / 1.5,
                                          child: Center(
                                            child: AutoSizeText(
                                              DataEngine.globalUser.firstName +
                                                  " " +
                                                  DataEngine
                                                      .globalUser.lastName,
                                              maxLines: 1,
                                              minFontSize: 1,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: width / 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 3.0, bottom: 2.0),
                                          child: SoshiUsernameText(
                                              DataEngine
                                                  .globalUser.soshiUsername,
                                              fontSize: width / 22,
                                              isVerified: DataEngine
                                                  .globalUser.verified),
                                        )
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return Scaffold(
                                                body: ProfileSettings(
                                                    // importProfileNotifier: widget.importProfileNotifier

                                                    ));
                                          })).then((value) {
                                            print(
                                                "☹️☹️☹️☹️☹️ returnign from profile settings, must refresh screen state");
                                            setState(() {});
                                          });
                                        },

                                        // {
                                        //   Navigator.push(context,
                                        //       MaterialPageRoute(
                                        //           builder: (context) {
                                        //     return Scaffold(
                                        //         body: ProfileSettings(
                                        //             // importProfileNotifier: widget.importProfileNotifier

                                        //             ));
                                        //   }));
                                        // },
                                        icon: Icon(CupertinoIcons.pen)),
                                  ],
                                ),
                                SizedBox(
                                  height: height / 100,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: width / 4,
                                      child: Column(children: [
                                        Text(
                                            DataEngine.globalUser.friends.length
                                                .toString(),
                                            style: TextStyle(
                                                letterSpacing: 1.2,
                                                fontSize: width / 25,
                                                fontWeight: FontWeight.bold)),
                                        DataEngine.globalUser.friends.length ==
                                                1
                                            ? Text(
                                                "Friend",
                                                style: TextStyle(
                                                    //fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.2,
                                                    fontSize: width / 25),
                                              )
                                            : Text("Friends",
                                                style: TextStyle(
                                                    letterSpacing: 1.2,
                                                    fontSize: width / 25)),
                                      ]),
                                    ),
                                    ProfilePic(
                                        radius: width / 6.5,
                                        url: DataEngine.globalUser.photoURL),
                                    SizedBox(
                                      width: width / 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          Popups.soshiPointsExplainedPopup(
                                              context, width, height);
                                        },
                                        child: Column(children: [
                                          Text(
                                              DataEngine.globalUser.soshiPoints
                                                  .toString(),
                                              style: TextStyle(
                                                  letterSpacing: 1.2,
                                                  fontSize: width / 25,
                                                  fontWeight: FontWeight.bold)),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              DataEngine.globalUser
                                                          .soshiPoints ==
                                                      1
                                                  ? Text("Bolt",
                                                      style: TextStyle(
                                                          letterSpacing: 1.2,
                                                          fontSize: width / 25))
                                                  : Text("Bolts",
                                                      style: TextStyle(
                                                          letterSpacing: 1.2,
                                                          fontSize:
                                                              width / 25)),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 2),
                                                child: IconButton(
                                                  onPressed: () {
                                                    Popups
                                                        .soshiPointsExplainedPopup(
                                                            context,
                                                            width,
                                                            height);
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(
                                                      maxHeight: width / 28,
                                                      maxWidth: width / 28,
                                                      minHeight: 0,
                                                      minWidth: 0),
                                                  icon: Icon(
                                                      CupertinoIcons
                                                          .info_circle,
                                                      size: width / 28),
                                                ),
                                              )
                                            ],
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height / 60),
                                DataEngine.globalUser.bio == "" ||
                                        DataEngine.globalUser.bio == null
                                    ? Container()
                                    : Container(
                                        child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            width / 7, 0, width / 7, 0),
                                        child: AutoSizeText(
                                          DataEngine.globalUser.bio,
                                          maxLines: 3,
                                          minFontSize: 1,
                                          style:
                                              TextStyle(fontSize: width / 22),
                                          textAlign: TextAlign.center,
                                        ),
                                      )),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: height / 2.2,
              child: Container(
                  //height: height / 2,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      // color: Colors.blue,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        width / 35, height / 90, width / 35, 0),
                    child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: width / 40),
                          child: Text(
                            "Passions",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: width / 17),
                          ),
                        ),
                        SizedBox(
                          height: height / 100,
                        ),
                        PassionTileList(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            IconButton(
                              icon: Icon(
                                  CupertinoIcons.pencil_ellipsis_rectangle),
                              onPressed: () async {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return Scaffold(
                                      body: ValueListenableBuilder(
                                          valueListenable:
                                              this.controlsEditHandlesScreen,
                                          builder: (context, value, _) {
                                            return EditHandles(
                                                refreshScreenParam:
                                                    refreshProfileScreen,
                                                // editHandleMasterControl:
                                                //     controlsEditHandlesScreen,
                                                profileMasterControl: widget
                                                    .importProfileNotifier);
                                          }));
                                }));
                              },
                            )
                          ],
                        ),
                        Container(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: GridView.builder(
                              // add an extra tile with the "+" that can be used always to add morem platforms
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    child: index != userSocials.length
                                        ? SMTile(
                                            user: DataEngine.globalUser,
                                            selectedSocial: userSocials[index],
                                            importProfileNotifier:
                                                widget.importProfileNotifier,
                                          )
                                        : AddPlatformsTile(
                                            importProfileNotifier:
                                                widget.importProfileNotifier,
                                            user: DataEngine.globalUser));
                              },
                              itemCount: userSocials.length + 1,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: .8,
                                      crossAxisSpacing: width / 40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
  


// class BioTextField extends StatefulWidget {
//   SoshiUser user;
//   BioTextField({@required this.user});

//   @override
//   State<BioTextField> createState() => _BioTextFieldState();
// }

// class _BioTextFieldState extends State<BioTextField> {
//   FocusNode bioFocusNode;

//   @override
//   void initState() {
//     super.initState();

//     bioFocusNode = new FocusNode();
//     bioFocusNode.addListener(() {
//       if (!bioFocusNode.hasFocus) {
//         // DataEngine.applyUserChanges(user: widget.user, cloud: false, local: true);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: TextField(
//           focusNode: bioFocusNode,
//           maxLength: 40,
//           maxLengthEnforcement: MaxLengthEnforcement.enforced,
//           // keyboardType: TextInputType.multiline,
//           textInputAction: TextInputAction.done,
//           maxLines: 6,
//           autocorrect: true,
//           controller: widget.user.bioController,
//           onSubmitted: (String bio) {
//             FocusScope.of(context).unfocus();
//           },
//           style: TextStyle(
//               height: 1.2,
//               fontWeight: FontWeight.bold,
//               fontSize: 15,
//               // color: Colors.white,
//               letterSpacing: 1.5),
//           decoration: InputDecoration(
//             floatingLabelBehavior: FloatingLabelBehavior.always,
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(15.0),
//               borderSide: BorderSide(
//                 color: Colors.blueGrey,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(15.0),
//               borderSide: BorderSide(
//                 color: Colors.cyan[300],
//               ),
//             ),
//             labelStyle: TextStyle(
//                 // color: Colors.cyanAccent,
//                 fontSize: 20),
//             labelText: 'Bio',
//             hintText: "Enter your bio!",
//             hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
//           )),
//     );
//   }
// }
