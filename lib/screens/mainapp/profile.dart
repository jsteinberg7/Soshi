//import 'dart:html';
// ignore_for_file: must_be_immutable

import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
// import 'package:device_display_brightness/device_display_brightness.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soshi/constants/constants.dart';
import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/screens/mainapp/editHandles.dart';
import 'package:soshi/screens/mainapp/friendScreen.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/contacts.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/services/url.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chooseSocials.dart';
import 'profileSettings.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:async';

// import 'package:keyboard_visibility/keyboard_visibility.dart';

/*
A social media card used in the profile (one card per platform)
*/

class SMTile extends StatefulWidget {
  String platformName, soshiUsername;
  Function() refreshScreen; // callback used to refresh screen
  SMTile({String platformName, String soshiUsername, Function refreshScreen}) {
    this.platformName = platformName;
    this.soshiUsername = soshiUsername;
    this.refreshScreen = refreshScreen;
  }

  @override
  _SMTileState createState() => _SMTileState();
}

class _SMTileState extends State<SMTile> {
  DatabaseService databaseService;
  String soshiUsername, platformName, hintText = "Username";
  // used to store local state of switch
  bool isSwitched;
  TextEditingController usernameController = new TextEditingController();
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    soshiUsername = widget.soshiUsername;
    platformName = widget.platformName;
    if (platformName == "Phone") {
      hintText = "Phone Number";
    } else if (platformName == "Linkedin" ||
        platformName == "Facebook" ||
        platformName == "Personal") {
      hintText = "Link to Profile";
    } else if (platformName == "Cryptowallet") {
      hintText = "Wallet address";
    } else {
      hintText = "Username";
    }

    databaseService = new DatabaseService(
        currSoshiUsernameIn: soshiUsername); // store ref to databaseService
    isSwitched = LocalDataService.getLocalStateForPlatform(platformName) ??
        false; // track state of platform switch
    usernameController.text =
        LocalDataService.getLocalUsernameForPlatform(platformName) ?? null;

    if (platformName == "Contact") {
      usernameController.text = "Contact Card";
    }

    // FocusScope.of(context).unfocus();

    focusNode = new FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        // if (usernameController.text.length != "") {
        // turn on switch if username is not empty (say, at least 3 chars)

        if (!isSwitched) {
          setState(() {
            isSwitched = true;
          });

          if (LocalDataService.getLocalUsernameForPlatform(platformName) ==
                  null ||
              LocalDataService.getLocalUsernameForPlatform(platformName) ==
                  "") {
            // prompt user to enter username
            Popups.editUsernamePopup(
              context,
              soshiUsername,
              platformName,
              MediaQuery.of(context).size.width,
            );
          }
          LocalDataService.updateSwitchForPlatform(
              platform: platformName, state: true);
          databaseService.updatePlatformSwitch(
              platform: platformName, state: true);
          if (LocalDataService.getFirstSwitchTap()) {
            LocalDataService.updateFirstSwitchTap(false);
            Popups.platformSwitchesExplained(context);
          }
        }
        // }

        String usernameControllerLower = usernameController.text.toLowerCase();

        LocalDataService.updateUsernameForPlatform(
            platform: platformName, username: usernameControllerLower.trim());
        databaseService.updateUsernameForPlatform(
            platform: platformName, username: usernameControllerLower.trim());
      }
    });

    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
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

    return Stack(
      children: [
        Card(
          //semanticContainer: true,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            height: height / 6.5,
            width: width / 3,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    splashRadius: Utilities.getWidth(context) / 25,
                    icon: Image.asset(
                      'assets/images/SMLogos/' + platformName + 'Logo.png',
                    ),
                    onPressed: () async {
                      if (platformName == "Contact") {
                        double width = Utilities.getWidth(context);
                        String firstName = LocalDataService.getLocalFirstName();
                        String lastName = LocalDataService.getLocalLastName();
                        String photoUrl =
                            LocalDataService.getLocalProfilePictureURL();
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
                                value: LocalDataService
                                    .getLocalUsernameForPlatform("Email"),
                              ),
                            ],
                            phones: [
                              Item(
                                  label: "Cell",
                                  value: LocalDataService
                                      .getLocalUsernameForPlatform("Phone")),
                            ],
                            avatar: profilePicBytes);
                        await askPermissions(context);
                        ContactsService.addContact(contact)
                            .then((dynamic success) {
                          Popups.showContactAddedPopup(
                              context, width, firstName, lastName);
                        });
                      } else if (platformName == "Cryptowallet") {
                        Clipboard.setData(ClipboardData(
                          text: LocalDataService.getLocalUsernameForPlatform(
                                  "Cryptowallet")
                              .toString(),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                            'Wallet address copied to clipboard!',
                            textAlign: TextAlign.center,
                          ),
                        ));

                        // snackbar or popup that says:
                        // "First name + last name's wallet address has been copied to clipboard"

                      } else {
                        URL.launchURL(URL.getPlatformURL(
                            platform: platformName,
                            username:
                                LocalDataService.getLocalUsernameForPlatform(
                                    platformName)));
                      }
                    },
                    iconSize: 60.0,
                  ),
                  CupertinoSwitch(
                      value: isSwitched,
                      activeColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      onChanged: (bool value) {
                        setState(() {
                          isSwitched = value;
                        });

                        if (LocalDataService.getLocalUsernameForPlatform(
                                    platformName) ==
                                null ||
                            LocalDataService.getLocalUsernameForPlatform(
                                    platformName) ==
                                "") {
                          Popups.editUsernamePopup(
                              context, soshiUsername, platformName, width);

                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   return EditHandles(); // Returning the edit Socials screen
                          // }));
                        }
                        LocalDataService.updateSwitchForPlatform(
                            platform: platformName, state: value);
                        databaseService.updatePlatformSwitch(
                            platform: platformName, state: value);

                        if (LocalDataService.getFirstSwitchTap()) {
                          LocalDataService.updateFirstSwitchTap(false);
                          Popups.platformSwitchesExplained(context);
                        }
                      }),
                ]),
          ),
        )
      ],
    );

    // double width = Utilities.getWidth(context);
    // text controller for username box
  }
}

/*
A social media card used in the profile (one card per platform)
*/

class AddPlatformsTile extends StatefulWidget {
  String platformName, soshiUsername;
  Function() refreshScreen; // callback used to refresh screen
  AddPlatformsTile(
      {String platformName, String soshiUsername, Function refreshScreen}) {
    this.platformName = platformName;
    this.soshiUsername = soshiUsername;
    this.refreshScreen = refreshScreen;
  }

  @override
  _AddPlatformsTileState createState() => _AddPlatformsTileState();
}

class _AddPlatformsTileState extends State<AddPlatformsTile> {
  refreshScreen() {
    setState(() {
      profilePlatforms = LocalDataService.getLocalProfilePlatforms();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            if (Constants.originalPlatforms.length +
                    Constants.addedPlatforms.length >
                LocalDataService.getLocalChoosePlatforms().length +
                    LocalDataService.getLocalProfilePlatforms().length) {
              // check which platforms need to be added
              for (String platform in Constants.addedPlatforms) {
                if (!LocalDataService.getLocalProfilePlatforms()
                        .contains(platform) &&
                    !LocalDataService.getLocalChoosePlatforms()
                        .contains(platform)) {
                  await LocalDataService.addToChoosePlatforms(
                      platform); // add new platform to choose platforms
                  await LocalDataService.updateSwitchForPlatform(
                      platform: platform,
                      state:
                          false); // create switch for platform in and initialize to false
                  if (LocalDataService.getLocalUsernameForPlatform(platform) ==
                      null) {
                    await LocalDataService.updateUsernameForPlatform(
                        platform: platform,
                        username:
                            ""); // create username mapping for platform if absent
                  }
                }
              }
            }
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Scaffold(
                  body: ChooseSocials(
                refreshFunction: refreshScreen,
              ));
            }));
          },
          child: Card(
              //semanticContainer: true,
              elevation: 5,
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
        )
      ],
    );

    // double width = Utilities.getWidth(context);
    // text controller for username box
  }
}

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  refreshScreen() {
    setState(() {
      profilePlatforms = LocalDataService.getLocalProfilePlatforms();
    });
  }

  List verifiedUsers;
  bool isVerified;
  String soshiUsername;
  List profilePlatforms;
  DatabaseService databaseService = new DatabaseService();

  // FocusNode bioFocusNode;
  TextEditingController profileBioController = TextEditingController(
      text: LocalDataService.getBio() == null
          ? ""
          : LocalDataService.getBio().toString());

  @override
  void initState() {
    super.initState();

    // double startingBrightness = LocalDataService.getInitialScreenBrightness();
    // DeviceDisplayBrightness.setBrightness(startingBrightness);

    // DeviceDisplayBrightness.resetBrightness();

    soshiUsername = LocalDataService.getLocalUsernameForPlatform("Soshi");
    profilePlatforms = LocalDataService.getLocalProfilePlatforms();
    verifiedUsers = LocalDataService.getVerifiedUsersLocal();

    isVerified = verifiedUsers.contains(soshiUsername);

    databaseService.updateVerifiedStatus(soshiUsername, isVerified);
    LocalDataService.updateVerifiedStatus(isVerified);

    // bioFocusNode = new FocusNode();
    // bioFocusNode.addListener(() {
    //   if (!bioFocusNode.hasFocus) {
    //     LocalDataService.updateBio(personalBioTextController.text);
    //     print(LocalDataService.getBio().toString());
    //     DatabaseService databaseService = new DatabaseService();
    //     databaseService.updateBio(soshiUsername, personalBioTextController.text);
    //   }
    // });

    // var keyboardVisibilityController = KeyboardVisibilityController();

    // keyboardVisibilityController.onChange.listen((bool visible) {
    //   if (visible == false) {
    //     print("inside one and only profile keyboard updater!");

    //     // Literally take all userData from local storage and push that to cloud

    //     // UPDATING BIO -----------------------
    //     DatabaseService tempDB = new DatabaseService();
    //     String latestBio = profileBioController.text;
    //     LocalDataService.updateBio(latestBio).then((value) {
    //       DatabaseService tempDB = new DatabaseService();
    //       tempDB.updateBio(LocalDataService.getLocalUsernameForPlatform("Soshi"), latestBio);
    //       // UPDATING BIO -----------------------

    //       // UPDATING ALL PLATFORMS --------------

    //       // LocalDataService.updateUsernameForPlatform()
    //     });
    //   }
    // });

    // print('Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');
    // keyboardVisibilityController.onChange.listen((bool visible) {
    //   print('Keyboard visibility update. Is visible: $visible');

    //   if (visible == false) {
    //     DatabaseService tempDB = new DatabaseService();
    //     String latestBio = personalBioTextController.text;
    //     print("[CLOUD +] Pushing latest Bio to cloud");
    //     LocalDataService.updateBio(latestBio);
    //     tempDB.updateBio(LocalDataService.getLocalUsernameForPlatform("Soshi"), latestBio);

    //     FocusScope.of(context).unfocus();

    //     // focusNode = new FocusNode();

    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    /* This is the dynamic sizing based on how long the bio is */
    double containerSize;
    double soshiPointsButtonSpacing;
    int bioChars;
    double bioSpacing;

    String bio = LocalDataService.getBio();
    if (bio == null || bio == "") {
      bioSpacing = 90;
      soshiPointsButtonSpacing = 1000;
      containerSize = 3.3;
    } else {
      bioChars = bio.length;

      if (bioChars <= 25) {
        bioSpacing = 50;
        soshiPointsButtonSpacing = 100;
        containerSize = 3.2;
      } else if (bioChars > 25 && bioChars <= 50) {
        bioSpacing = 80;
        soshiPointsButtonSpacing = 150;
        containerSize = 3.2;
      } else {
        bioSpacing = 90;
        soshiPointsButtonSpacing = 1000;
        containerSize = 3.1;
      }
    }

    profileBioController.text = LocalDataService.getBio();
    return SingleChildScrollView(
      child: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: width,
                height: height / 3,
                child: Image.network(
                    (LocalDataService.getLocalProfilePictureURL() != "null"
                        ? LocalDataService.getLocalProfilePictureURL()
                        : "https://img.freepik.com/free-photo/abstract-luxury-plain-blur-grey-black-gradient-used-as-background-studio-wall-display-your-products_1258-58170.jpg?w=2000"),
                    fit: BoxFit.fill),
              ),
              GlassmorphicContainer(
                height: height / 3,
                width: width,
                borderRadius: 0,
                blur: 5,
                alignment: Alignment.bottomCenter,
                border: 2,
                linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFffffff).withOpacity(0.8),
                      Color(0xFFFFFFFF).withOpacity(0.4),
                    ],
                    stops: [
                      0.1,
                      1,
                    ]),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFffffff).withOpacity(0.5),
                    Color((0xFFFFFFFF)).withOpacity(0.5),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    SafeArea(
                      child: Container(
                        // color: Colors.green,
                        height: height / containerSize,
                        width: width,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              width / 40, width / 40, width / 40, 0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.share)),
                                  Column(
                                    children: [
                                      Container(
                                        width: width / 1.5,
                                        child: Center(
                                          child: AutoSizeText(
                                            LocalDataService
                                                    .getLocalFirstName() +
                                                " " +
                                                LocalDataService
                                                    .getLocalLastName(),
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: width / 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                              "@" +
                                                  LocalDataService
                                                      .getLocalUsername(),
                                              style: TextStyle(
                                                  letterSpacing: 1.5)),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          isVerified == null ||
                                                  isVerified == false
                                              ? Container()
                                              : Image.asset(
                                                  "assets/images/Verified.png",
                                                  scale: width / 20,
                                                )
                                        ],
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
                                                  soshiUsername: soshiUsername,
                                                  refreshProfile:
                                                      refreshScreen));
                                        }));
                                      },
                                      icon: Icon(Icons.edit)),
                                ],
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(children: [
                                    Text(
                                        LocalDataService.getFriendsListCount()
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                            fontSize: width / 25)),
                                    LocalDataService.getFriendsListCount() == 1
                                        ? Text(
                                            "Friend",
                                            style: TextStyle(
                                                //fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                                fontSize: width / 25),
                                          )
                                        : Text("Friends",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                                fontSize: width / 25))
                                  ]),
                                  ProfilePic(
                                      radius: 55,
                                      url: LocalDataService
                                          .getLocalProfilePictureURL()),
                                  Column(children: [
                                    Text(
                                        LocalDataService.getFriendsListCount()
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                            fontSize: width / 25)),
                                    LocalDataService.getFriendsListCount() == 1
                                        ? Text("Group",
                                            style: TextStyle(
                                                letterSpacing: 1.2,
                                                fontSize: width / 25))
                                        : Text("Groups",
                                            style: TextStyle(
                                                letterSpacing: 1.2,
                                                fontSize: width / 25))
                                  ]),
                                ],
                              ),
                              //SizedBox(height: height / 1),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      width / 5,
                                      height / bioSpacing,
                                      width / 5,
                                      height / soshiPointsButtonSpacing),
                                  child: bio == "" || bio == null
                                      ? Container()
                                      : Container(
                                          child: //Padding(
                                              //padding: EdgeInsets.fromLTRB(width / 5, 0, width / 5, 0),
                                              //child:
                                              AutoSizeText(
                                            LocalDataService.getBio(),
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                  //),
                                  ),
                              SoshiPointsButton(height, width),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.fromLTRB(width / 25, 0, width / 25, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Stack(
          //   children: [
          //     Padding(
          //       padding: EdgeInsets.fromLTRB(width / 30, 0, width / 30, 0),
          //       child: Divider(
          //         color: Colors.white,
          //       ),
          //     ),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         Container(
          //           child: Text("Hello"),
          //         )
          //       ],
          //     )
          //   ],
          // ),
          Container(
              child: Padding(
            padding: EdgeInsets.fromLTRB(width / 35, 0, width / 35, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Socials",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: width / 17),
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.list_bullet),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Scaffold(
                              body: EditHandles(
                            soshiUsername: soshiUsername,
                          ));
                        }));
                      },
                      color: Colors.black,
                    )
                  ],
                ),
                Container(
                  child: GridView.builder(
                    // add an extra tile with the "+" that can be used always to add morem platforms

                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: index != profilePlatforms.length
                              ? SMTile(
                                  platformName: profilePlatforms[index],
                                  soshiUsername: soshiUsername,
                                  refreshScreen: refreshScreen)
                              : AddPlatformsTile(refreshScreen: refreshScreen));
                    },
                    itemCount: profilePlatforms.length + 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: .8,
                        crossAxisSpacing: width / 40),
                  ),
                ),
              ],
            ),
          )),
        ],
      )),
    );

    // return SingleChildScrollView(
    //   child: Container(
    //     child: Padding(
    //         padding: EdgeInsets.fromLTRB(width / 35, 20, width / 35, 0),
    //         child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Row(children: <Widget>[
    //                 Column(
    //                   children: [
    //                     Container(
    // child: GestureDetector(
    //   onTap: () async {
    //     DatabaseService dbService = new DatabaseService();
    //     //dbService.chooseAndCropImage();

    //     // update profile picture on tap
    //     // open up image picker
    //     final ImagePicker imagePicker = ImagePicker();
    //     final PickedFile pickedImage =
    //         await imagePicker.getImage(
    //             source: ImageSource.gallery,
    //             imageQuality: 20);
    //     await dbService.cropAndUploadImage(pickedImage);

    //     // Checking if this is first time adding a profile pic
    //     // if it is, it gives Soshi points
    //     if (LocalDataService.getInjectionFlag(
    //                 "Profile Pic") ==
    //             false ||
    //         LocalDataService.getInjectionFlag(
    //                 "Profile Pic") ==
    //             null) {
    //       LocalDataService.updateInjectionFlag(
    //           "Profile Pic", true);
    //       dbService.updateInjectionSwitch(
    //           soshiUsername, "Profile Pic", true);
    //       databaseService.updateSoshiPoints(
    //           soshiUsername, 10);
    //       LocalDataService.updateSoshiPoints(10);
    //     }

    //     refreshScreen();
    //   },
    //   child: Stack(
    //     children: [
    //       ProfilePic(
    //           radius: 55,
    //           url: LocalDataService
    //               .getLocalProfilePictureURL()),
    //       Positioned(
    //           bottom: width / 100,
    //           right: width / 100,
    //           child: Container(
    //             padding: EdgeInsets.all(width / 100),
    //             decoration: BoxDecoration(
    //                 shape: BoxShape.circle,
    //                 color: Colors.cyan[500]),
    //             child: Icon(
    //               Icons.edit,
    //               size: 20,
    //               color: Colors.white,
    //             ),
    //           ))
    //     ],
    //   ),
    //  ),
    //                     ),
    //                     SizedBox(height: 15),
    //                     Container(
    //                       width: 130,
    //                       child: Constants.makeBlueShadowButtonSmall(
    //                         "Edit Profile",
    //                         Icons.person_rounded,
    //                         () {
    //                           Navigator.push(context,
    //                               MaterialPageRoute(builder: (context) {
    //                             return Scaffold(
    //                                 body: ProfileSettings(
    //                                     soshiUsername: soshiUsername,
    //                                     refreshProfile: refreshScreen));
    //                           }));
    //                         },
    //                       ),
    //                     )
    //                   ],
    //                 ),
    //                 SizedBox(width: 10),
    //                 Expanded(
    //                   child: SizedBox(
    //                     height: 160,
    //                     child: BioTextField(
    //                         importController: profileBioController,
    //                         soshiUsername: soshiUsername),
    //                   ),
    //                 )
    //               ]),
    //               SizedBox(height: 5),
    //               Row(
    //                 //mainAxisAlignment: MainAxisAlignment.start,
    //                 //crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[],
    //               ),
    //               Divider(
    //                 color: Colors.cyan[300],
    //               ),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 children: <Widget>[
    //                   Text(
    //                     'Toggle',
    //                     style: TextStyle(
    //                       color: Colors.grey,
    //                       letterSpacing: 2,
    //                     ),
    //                   ),
    //                   // ElevatedButton(
    //                   //   child: Icon(
    //                   //     Icons.help,
    //                   //     size: 30,
    //                   //     // color: Colors.grey[900],
    //                   //   ),
    //                   //   style: ElevatedButton.styleFrom(
    //                   //       fixedSize: Size(35, 35),
    //                   //       primary: Colors.blueGrey[500],
    //                   //       shape: CircleBorder()),
    //                   //   onPressed: () {
    //                   //     Popups.showPlatformHelpPopup(context, height);
    //                   //   },
    //                   // ),
    //                   // SizedBox(
    //                   //   width: width / 12,
    //                   // ),
    //                 ],
    //               ),
    // Container(
    //   child: (profilePlatforms == null ||
    //           profilePlatforms.isEmpty == true)
    //       ? Column(
    //           children: <Widget>[
    //             SizedBox(height: 10),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: <Widget>[
    //                 Text(
    //                   "Add your platforms!",
    //                   style: TextStyle(
    //                     color: Colors.cyan[300],
    //                     fontSize: 25,
    //                     fontStyle: FontStyle.italic,
    //                     letterSpacing: 3.0,
    //                     //fontWeight: FontWeight.bold
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             SizedBox(height: 10),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(
    //                   Icons.arrow_downward_rounded,
    //                   size: 30,
    //                   color: Colors.cyan[100],
    //                 ),
    //                 Icon(
    //                   Icons.arrow_downward_rounded,
    //                   size: 30,
    //                   color: Colors.cyan[300],
    //                 ),
    //                 Icon(
    //                   Icons.arrow_downward_rounded,
    //                   size: 30,
    //                   color: Colors.cyan[700],
    //                 ),
    //               ],
    //             ),
    //             SizedBox(height: 5),
    //           ],
    //         )
    //       : GridView.builder(
    //           physics: const NeverScrollableScrollPhysics(),
    //           shrinkWrap: true,
    //           itemBuilder: (BuildContext context, int index) {
    //             return Padding(
    //               padding:
    //                   const EdgeInsets.fromLTRB(0, 10, 0, 10),
    //               child: SMCard(
    //                   platformName: profilePlatforms[index],
    //                   soshiUsername: soshiUsername,
    //                   refreshScreen: refreshScreen),
    //             );
    //           },
    //           itemCount: profilePlatforms.length,
    //           gridDelegate:
    //               SliverGridDelegateWithFixedCrossAxisCount(
    //                   crossAxisCount: 2,
    //                   childAspectRatio: 1.75,
    //                   crossAxisSpacing: 7),
    //         ),
    // ),
    //               Padding(
    //                 padding: const EdgeInsets.fromLTRB(50, 10, 50, 40),
    //                 child: Constants.makeBlueShadowButton(
    //                     "Add Platforms!", Icons.add_circle_outline_rounded,
    //                     () async {
    //                   // check if user has all platforms (in case of update)
    //                   if (Constants.originalPlatforms.length +
    //                           Constants.addedPlatforms.length >
    //                       LocalDataService.getLocalChoosePlatforms().length +
    //                           LocalDataService.getLocalProfilePlatforms()
    //                               .length) {
    //                     // check which platforms need to be added
    //                     for (String platform in Constants.addedPlatforms) {
    //                       if (!LocalDataService.getLocalProfilePlatforms()
    //                               .contains(platform) &&
    //                           !LocalDataService.getLocalChoosePlatforms()
    //                               .contains(platform)) {
    //                         await LocalDataService.addToChoosePlatforms(
    //                             platform); // add new platform to choose platforms
    //                         await LocalDataService.updateSwitchForPlatform(
    //                             platform: platform,
    //                             state:
    //                                 false); // create switch for platform in and initialize to false
    //                         if (LocalDataService.getLocalUsernameForPlatform(
    //                                 platform) ==
    //                             null) {
    //                           await LocalDataService.updateUsernameForPlatform(
    //                               platform: platform,
    //                               username:
    //                                   ""); // create username mapping for platform if absent
    //                         }
    //                       }
    //                     }
    //                   }
    //                   await Navigator.push(context,
    //                       MaterialPageRoute(builder: (context) {
    //                     return Scaffold(
    //                         body: ChooseSocials(
    //                       refreshFunction: refreshScreen,
    //                     ));
    //                   }));
    //                 }),
    //               ),
    //               SizedBox(height: 30)
    //             ])),
    //   ),
    // );
  }
}

class BioTextField extends StatefulWidget {
  TextEditingController importController;
  String soshiUsername;

  BioTextField({this.importController, this.soshiUsername});

  @override
  State<BioTextField> createState() => _BioTextFieldState();
}

class _BioTextFieldState extends State<BioTextField> {
  FocusNode bioFocusNode;

  @override
  void initState() {
    super.initState();

    bioFocusNode = new FocusNode();
    bioFocusNode.addListener(() {
      if (!bioFocusNode.hasFocus) {
        LocalDataService.updateBio(widget.importController.text);
        print(LocalDataService.getBio().toString());
        DatabaseService databaseService = new DatabaseService();
        databaseService.updateBio(
            widget.soshiUsername, widget.importController.text);
      }
    });
  }

  // void initState() {
  //   super.initState();
  //   var keyboardVisibilityController = KeyboardVisibilityController();
  //   print(
  //       'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');
  //   keyboardVisibilityController.onChange.listen((bool visible) {
  //     print('Keyboard visibility update. Is visible: $visible');

  //     if (visible == false) {
  //       DatabaseService tempDB = new DatabaseService();
  //       String latestBio = personalBioTextController.text;
  //       print("[CLOUD +] Pushing latest Bio to cloud");

  //       LocalDataService.updateBio(latestBio);
  //       tempDB.updateBio(
  //           LocalDataService.getLocalUsernameForPlatform("Soshi"), latestBio);

  //       personalBioTextController.clearComposing();
  //       FocusScope.of(context).unfocus();
  //     }
  //   }
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
          focusNode: bioFocusNode,
          maxLength: 40,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          // keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          maxLines: 6,
          autocorrect: true,
          controller: widget.importController,
          onSubmitted: (String bio) {
            String soshiUsername =
                LocalDataService.getLocalUsernameForPlatform("Soshi");
            DatabaseService tempDB = new DatabaseService();
            LocalDataService.updateBio(bio);
            tempDB.updateBio(
                LocalDataService.getLocalUsernameForPlatform("Soshi"), bio);

            // Checking if this is first time adding a bio
            // if it is, it gives Soshi points
            if (LocalDataService.getInjectionFlag("Bio") == false ||
                LocalDataService.getInjectionFlag("Bio") == null) {
              LocalDataService.updateInjectionFlag("Bio", true);
              tempDB.updateInjectionSwitch(soshiUsername, "Bio", true);

              LocalDataService.updateSoshiPoints(10);
              tempDB.updateSoshiPoints(soshiUsername, 10);
            }

            // bioFocusNode.unfocus();
            FocusScope.of(context).unfocus();
          },
          style: TextStyle(
              height: 1.2,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              // color: Colors.white,
              letterSpacing: 1.5),
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.blueGrey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.cyan[300],
              ),
            ),
            labelStyle: TextStyle(
                // color: Colors.cyanAccent,
                fontSize: 20),
            labelText: 'Bio',

            hintText: "Enter your bio!",

            hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
            // labelText: "Personal Bio"
          )),
    );
  }
}
