//import 'dart:html';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
// import 'package:device_display_brightness/device_display_brightness.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soshi/constants/constants.dart';
import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
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
class SMCard extends StatefulWidget {
  String platformName, soshiUsername;
  Function() refreshScreen; // callback used to refresh screen
  SMCard({String platformName, String soshiUsername, Function refreshScreen}) {
    this.platformName = platformName;
    this.soshiUsername = soshiUsername;
    this.refreshScreen = refreshScreen;
  }
  @override
  _SMCardState createState() => _SMCardState();
}

class _SMCardState extends State<SMCard> {
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
    } else if (platformName == "Linkedin" || platformName == "Facebook" || platformName == "Personal") {
      hintText = "Link to Profile";
    } else {
      hintText = "Username";
    }

    databaseService = new DatabaseService(currSoshiUsernameIn: soshiUsername); // store ref to databaseService
    isSwitched = LocalDataService.getLocalStateForPlatform(platformName) ?? false; // track state of platform switch
    usernameController.text = LocalDataService.getLocalUsernameForPlatform(platformName) ?? null;

    if (platformName == "Contact") {
      usernameController.text = "Contact Card";
    }

    // FocusScope.of(context).unfocus();

    focusNode = new FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        if (usernameController.text.length != "") {
          // turn on switch if username is not empty (say, at least 3 chars)

          if (!isSwitched) {
            setState(() {
              isSwitched = true;
            });
            LocalDataService.updateSwitchForPlatform(platform: platformName, state: true);
            databaseService.updatePlatformSwitch(platform: platformName, state: true);
          }
        }

        String usernameControllerLower = usernameController.text.toLowerCase();

        LocalDataService.updateUsernameForPlatform(platform: platformName, username: usernameControllerLower.trim());
        databaseService.updateUsernameForPlatform(platform: platformName, username: usernameControllerLower.trim());
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

    //double width = Utilities.getWidth(context);
    // text controller for username box

    return Stack(
      children: [
        Card(
          // color: Theme.of(context).brightness == Brightness.light
          //     ? Colors.white
          //     : Colors.grey[850],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side:
                  // (isSwitched == true)
                  // ?
                  // BorderSide(color: Colors.blueGrey)

                  // :
                  BorderSide.none),
          elevation: 5,

          // color: Colors.grey[850],

          //Colors.grey[850],
          child: Container(
              height: height / 11,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Transform.scale(
                      scaleY: .9,
                      scaleX: .9,
                      child: CupertinoSwitch(
                          // activeThumbImage:
                          //     AssetImage('assets/images/SoshiLogos/soshi_icon.png'),
                          // inactiveThumbImage: AssetImage(
                          //     'assets/images/SoshiLogos/soshi_icon_marble.png'),
                          value: isSwitched,
                          activeColor: Colors.cyan[500],
                          onChanged: (bool value) {
                            setState(() {
                              isSwitched = value;
                            });

                            // if (LocalDataService.getLocalUsernameForPlatform(
                            //             platformName) ==
                            //         null ||
                            //     LocalDataService.getLocalUsernameForPlatform(
                            //             platformName) ==
                            //         "") {
                            //   if (platformName == "Instagram" ||
                            //       platformName == "Snapchat" ||
                            //       platformName == "Venmo" ||
                            //       platformName == "Twitter" ||
                            //       platformName == "Tiktok" ||
                            //       platformName == "Discord" ||
                            //       platformName == "Spotify") {
                            //     Popups.editUsernamePopup(context, soshiUsername,
                            //         platformName, "Username", "@", width);
                            //   } else {
                            //     if (platformName == "Personal" ||
                            //         platformName == "Facebook" ||
                            //         platformName == "Linkedin") {
                            //       Popups.editUsernamePopup(
                            //           context,
                            //           soshiUsername,
                            //           platformName,
                            //           "Link to Profile",
                            //           "https://",
                            //           width);
                            //     } else if (platformName == "Phone") {
                            //       Popups.editUsernamePopup(
                            //           context,
                            //           soshiUsername,
                            //           platformName,
                            //           "Phone Number",
                            //           "#",
                            //           width);
                            //     } else if (platformName == "Youtube") {
                            //       Popups.editUsernamePopup(
                            //           context,
                            //           soshiUsername,
                            //           platformName,
                            //           "Channel ID",
                            //           "Chan. ID",
                            //           width);
                            //     } else {
                            //       Popups.editUsernamePopup(
                            //           context,
                            //           soshiUsername,
                            //           platformName,
                            //           "",
                            //           "",
                            //           width);
                            //     }
                            //   }
                            // }

                            LocalDataService.updateSwitchForPlatform(platform: platformName, state: value);
                            databaseService.updatePlatformSwitch(platform: platformName, state: value);

                            if (LocalDataService.getFirstSwitchTap()) {
                              LocalDataService.updateFirstSwitchTap(false);
                              Popups.platformSwitchesExplained(context);
                            }
                          }),
                    ),
                    // Center(
                    //   child: Material(
                    //     color: Colors.transparent,
                    //     shadowColor: Colors.black54,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(0.0),
                    //     ),
                    //child:
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
                          String photoUrl = LocalDataService.getLocalProfilePictureURL();
                          Uint8List profilePicBytes;
                          try {
                            // try to load profile pic from url
                            await http.get(Uri.parse(photoUrl)).then((http.Response response) {
                              profilePicBytes = response.bodyBytes;
                            });
                          } catch (e) {
                            // if url is invalid, use default profile pic
                            ByteData data = await rootBundle.load("assets/images/SoshiLogos/soshi_icon.png");
                            profilePicBytes = data.buffer.asUint8List();
                          }
                          Contact contact = new Contact(
                              givenName: firstName,
                              familyName: lastName,
                              emails: [
                                Item(
                                  label: "Email",
                                  value: LocalDataService.getLocalUsernameForPlatform("Email"),
                                ),
                              ],
                              phones: [
                                Item(label: "Cell", value: LocalDataService.getLocalUsernameForPlatform("Phone")),
                              ],
                              avatar: profilePicBytes);
                          await askPermissions(context);
                          ContactsService.addContact(contact).then((dynamic success) {
                            Popups.showContactAddedPopup(context, width, firstName, lastName);
                          });
                        } else {
                          URL.launchURL(
                              URL.getPlatformURL(platform: platformName, username: LocalDataService.getLocalUsernameForPlatform(platformName)));
                        }
                      },
                      iconSize: 55.0,
                    ),

                    // ['Email', 'Phone', 'Contact', 'Linkedin', 'Facebook']
                    //         .contains(platformName)
                    //     ? Container()
                    //     : Padding(
                    //         padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    //         child: Text("@",
                    //             style: TextStyle(
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.bold,
                    //                 fontSize: 20)),
                    //       ),
                    // Padding(
                    //   padding: EdgeInsets.only(right: 35),
                    // )
                  ],
                ),
              )),
        ),
        Visibility(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSwitched = true;
                });
                LocalDataService.updateSwitchForPlatform(platform: platformName, state: true);
                databaseService.updatePlatformSwitch(platform: platformName, state: true);
              },
              child: Card(
                // color: Colors.black12,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  height: Utilities.getHeight(context) / 11,
                ),
              ),
            ),
            visible: !isSwitched),
        Padding(
          padding: EdgeInsets.fromLTRB(0, height / 38, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // SizedBox(
              //   width: width / 3,
              // ),
              platformName != "Contact"
                  ? Container(
                      height: height / 20,
                      width: width / 9,
                      decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                      child: IconButton(
                        onPressed: () {
                          if (platformName == "Instagram" ||
                              platformName == "Snapchat" ||
                              platformName == "Venmo" ||
                              platformName == "Twitter" ||
                              platformName == "Tiktok" ||
                              platformName == "Discord" ||
                              platformName == "Spotify") {
                            Popups.editUsernamePopup(context, soshiUsername, platformName, "Username", "@", width);
                          } else {
                            if (platformName == "Facebook" || platformName == "Linkedin" || platformName == "Personal") {
                              Popups.editUsernamePopup(context, soshiUsername, platformName, "Link to Profile", "https://", width);
                            } else if (platformName == "Phone") {
                              Popups.editUsernamePopup(context, soshiUsername, platformName, "Phone", "#", width);
                            } else if (platformName == "Youtube") {
                              Popups.editUsernamePopup(context, soshiUsername, platformName, "Channel ID", "Chan. ID", width);
                            } else {
                              Popups.editUsernamePopup(context, soshiUsername, platformName, "", "", width);
                            }
                          }
                          //popup of edit username
                        },
                        iconSize: 25,
                        splashRadius: 20,
                        icon: Icon(Icons.edit),
                        // color: Colors.white,
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.question_mark_rounded),
                      iconSize: 25,
                      color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                      onPressed: () {
                        Popups.contactCardExplainedPopup(context, width, height);
                      },
                      splashRadius: 5,
                    )
            ],
          ),
        ),
        Positioned(
            width: width / 1.16,
            height: height / 35,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                // backgroundColor: MaterialStateProperty.all(Colors.black)
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40.0))),
                        // backgroundColor: Colors.blueGrey[900],
                        title: Text(
                          "Remove Platform",
                          style: TextStyle(
                              // color: Colors.cyan[600],
                              fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          ("Are you sure you want to remove " + platformName + " from your profile?"),
                          style: TextStyle(
                            fontSize: 20,
                            // color: Colors.cyan[700],
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TextButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(fontSize: 20, color: Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text(
                                  'Remove',
                                  style: TextStyle(fontSize: 20, color: Colors.blue),
                                ),
                                onPressed: () async {
                                  if (!LocalDataService.getLocalChoosePlatforms().contains(platformName)) {
                                    Navigator.pop(context);

                                    await LocalDataService.removePlatformsFromProfile(platformName);
                                    LocalDataService.addToChoosePlatforms(platformName);

                                    LocalDataService.updateSwitchForPlatform(platform: platformName, state: false);
                                    databaseService.updatePlatformSwitch(platform: platformName, state: false);
                                    databaseService.removePlatformFromProfile(platformName);
                                    databaseService.addToChoosePlatforms(platformName);
                                    print(LocalDataService.getLocalProfilePlatforms().toString());
                                    widget.refreshScreen();
                                  } else {
                                    Navigator.pop(context);
                                    await LocalDataService.removePlatformsFromProfile(platformName);
                                    widget.refreshScreen();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    });
              },
              child: Icon(
                Icons.remove,
                size: 20,
                // color: Colors.white,
              ),
            ))
      ],
    );
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
  TextEditingController profileBioController =
      TextEditingController(text: LocalDataService.getBio() == null ? "" : LocalDataService.getBio().toString());

  @override
  void initState() {
    super.initState();

    // double startingBrightness = LocalDataService.getInitialScreenBrightness();
    // DeviceDisplayBrightness.setBrightness(startingBrightness);

    // DeviceDisplayBrightness.resetBrightness();

    soshiUsername = LocalDataService.getLocalUsernameForPlatform("Soshi");
    profilePlatforms = LocalDataService.getLocalProfilePlatforms();

    verifiedUsers = LocalDataService.getVerifiedUsersLocal();
    print(verifiedUsers.toString());

    isVerified = verifiedUsers.contains(soshiUsername);

    databaseService.updateVerifiedStatus(soshiUsername, isVerified);
    LocalDataService.updateVerifiedStatus(isVerified);
    print(LocalDataService.getVerifiedStatus());

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

    profileBioController.text = LocalDataService.getBio();

    return SingleChildScrollView(
      child: Container(
        child: Padding(
            padding: EdgeInsets.fromLTRB(width / 35, 20, width / 35, 0),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Row(children: <Widget>[
                Column(
                  children: [
                    Container(
                      child: GestureDetector(
                        onTap: () async {
                          DatabaseService dbService = new DatabaseService();
                          //dbService.chooseAndCropImage();

                          // update profile picture on tap
                          // open up image picker
                          final ImagePicker imagePicker = ImagePicker();
                          final PickedFile pickedImage = await imagePicker.getImage(source: ImageSource.gallery, imageQuality: 20);
                          await dbService.cropAndUploadImage(pickedImage);
                          refreshScreen();
                        },
                        child: Stack(
                          children: [
                            ProfilePic(radius: 55, url: LocalDataService.getLocalProfilePictureURL()),
                            Positioned(
                                bottom: width / 100,
                                right: width / 100,
                                child: Container(
                                  padding: EdgeInsets.all(width / 100),
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.cyan[500]),
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      width: 130,
                      child: Constants.makeBlueShadowButtonSmall(
                        "Edit Profile",
                        Icons.person_rounded,
                        () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return Scaffold(body: ProfileSettings(soshiUsername: soshiUsername, refreshProfile: refreshScreen));
                          }));
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 160,
                    child: BioTextField(importController: profileBioController, soshiUsername: soshiUsername),
                  ),
                )
              ]),
              SizedBox(height: 5),
              Row(
                //mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[],
              ),
              Divider(
                color: Colors.cyan[300],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Toggle',
                    style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),
                  // ElevatedButton(
                  //   child: Icon(
                  //     Icons.help,
                  //     size: 30,
                  //     // color: Colors.grey[900],
                  //   ),
                  //   style: ElevatedButton.styleFrom(
                  //       fixedSize: Size(35, 35),
                  //       primary: Colors.blueGrey[500],
                  //       shape: CircleBorder()),
                  //   onPressed: () {
                  //     Popups.showPlatformHelpPopup(context, height);
                  //   },
                  // ),
                  // SizedBox(
                  //   width: width / 12,
                  // ),
                ],
              ),
              Container(
                child: (profilePlatforms == null || profilePlatforms.isEmpty == true)
                    ? Column(
                        children: <Widget>[
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Add your platforms!",
                                style: TextStyle(
                                  color: Colors.cyan[300],
                                  fontSize: 25,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 3.0,
                                  //fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                size: 30,
                                color: Colors.cyan[100],
                              ),
                              Icon(
                                Icons.arrow_downward_rounded,
                                size: 30,
                                color: Colors.cyan[300],
                              ),
                              Icon(
                                Icons.arrow_downward_rounded,
                                size: 30,
                                color: Colors.cyan[700],
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                        ],
                      )
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: SMCard(platformName: profilePlatforms[index], soshiUsername: soshiUsername, refreshScreen: refreshScreen),
                          );
                        },
                        itemCount: profilePlatforms.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.75, crossAxisSpacing: 7),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 40),
                child: Constants.makeBlueShadowButton("Add Platforms!", Icons.add_circle_outline_rounded, () async {
                  // check if user has all platforms (in case of update)
                  if (Constants.originalPlatforms.length + Constants.addedPlatforms.length >
                      LocalDataService.getLocalChoosePlatforms().length + LocalDataService.getLocalProfilePlatforms().length) {
                    // check which platforms need to be added
                    for (String platform in Constants.addedPlatforms) {
                      if (!LocalDataService.getLocalProfilePlatforms().contains(platform) &&
                          !LocalDataService.getLocalChoosePlatforms().contains(platform)) {
                        await LocalDataService.addToChoosePlatforms(platform); // add new platform to choose platforms
                        await LocalDataService.updateSwitchForPlatform(
                            platform: platform, state: false); // create switch for platform in and initialize to false
                        if (LocalDataService.getLocalUsernameForPlatform(platform) == null) {
                          await LocalDataService.updateUsernameForPlatform(
                              platform: platform, username: ""); // create username mapping for platform if absent
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
                }),
              ),
              SizedBox(height: 30)
            ])),
      ),
    );
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
        databaseService.updateBio(widget.soshiUsername, widget.importController.text);
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
          maxLength: 80,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          // keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          maxLines: 6,
          autocorrect: true,
          controller: widget.importController,
          onSubmitted: (String bio) {
            DatabaseService tempDB = new DatabaseService();
            LocalDataService.updateBio(bio);
            tempDB.updateBio(LocalDataService.getLocalUsernameForPlatform("Soshi"), bio);

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
