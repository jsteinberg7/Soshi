import 'package:flutter/material.dart';
import 'package:soshi/screens/mainapp/chooseSocials.dart';
import 'package:soshi/services/database.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/screens/mainapp/profile.dart';
import 'package:soshi/screens/mainapp/resetPassword.dart';
import 'package:soshi/services/auth.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/utilities.dart';

import '../../constants/popups.dart';
import '../../services/nfc.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';

import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
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

class EditHandles extends StatefulWidget {
  String soshiUsername;

  EditHandles({String soshiUsername}) {
    this.soshiUsername = soshiUsername;
  }

  @override
  State<EditHandles> createState() => _EditHandlesState();
}

String soshiUsername;
DatabaseService databaseService;
List<String> profilePlatforms;

class _EditHandlesState extends State<EditHandles> {
  refreshScreen() {
    setState(() {
      profilePlatforms = LocalDataService.getLocalProfilePlatforms();
    });
  }

  @override
  Widget build(BuildContext context) {
    soshiUsername = LocalDataService.getLocalUsernameForPlatform("Soshi");
    databaseService = new DatabaseService();
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    profilePlatforms = LocalDataService.getLocalProfilePlatforms();
    print(profilePlatforms.toString());

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: width / 150),
            child: TextButton(
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent)),
              child: Text(
                "Done",
                style: TextStyle(color: Colors.blue, fontSize: width / 23),
              ),
              onPressed: () {
                // for (int i = 0; i < profilePlatforms.length; i++) {
                //                                       LocalDataService.updateUsernameForPlatform(
                //                         platform: profilePlatforms[i],
                //                         username: );
                //                     databaseService.updateUsernameForPlatform(
                //                         platform: profilePlatforms[i],
                //                         username: );

                // }
                Navigator.pop(context);
              },
            ),
          )
        ],
        elevation: 10,
        shadowColor: Colors.cyan,
        title: Text(
          "My Platforms",
          style: TextStyle(
            // color: Colors.cyan[200],
            letterSpacing: 1,
            fontSize: width / 18,
            fontWeight: FontWeight.bold,
            //fontStyle: FontStyle.italic
          ),
        ),
        // backgroundColor: Colors.grey[850],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(width / 40, height / 50, width / 40, 0),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 5,
                  primary: Colors.green,
                  shape: RoundedRectangleBorder(
                      //to set border radius to button
                      borderRadius: BorderRadius.circular(15)),
                  padding: EdgeInsets.fromLTRB(
                      50, 0, 50, 0) //content padding inside button

                  ),
              child: Text(
                "Add",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: width / 20,
                    color: Colors.white),
              ),
              onPressed: () async {
                // check if user has all platforms (in case of update)
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
                      if (LocalDataService.getLocalUsernameForPlatform(
                              platform) ==
                          null) {
                        await LocalDataService.updateUsernameForPlatform(
                            platform: platform,
                            username:
                                ""); // create username mapping for platform if absent
                      }
                    }
                  }
                }
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return Scaffold(
                      body: ChooseSocials(
                    refreshFunction: refreshScreen,
                  ));
                }));
              },
            ),
            // Constants.makeBlueShadowButton(
            //     "Add Platforms!", Icons.add_circle_outline_rounded, () async {
            //   // check if user has all platforms (in case of update)
            //   if (Constants.originalPlatforms.length +
            //           Constants.addedPlatforms.length >
            //       LocalDataService.getLocalChoosePlatforms().length +
            //           LocalDataService.getLocalProfilePlatforms().length) {
            //     // check which platforms need to be added
            //     for (String platform in Constants.addedPlatforms) {
            //       if (!LocalDataService.getLocalProfilePlatforms()
            //               .contains(platform) &&
            //           !LocalDataService.getLocalChoosePlatforms()
            //               .contains(platform)) {
            //         await LocalDataService.addToChoosePlatforms(
            //             platform); // add new platform to choose platforms
            //         await LocalDataService.updateSwitchForPlatform(
            //             platform: platform,
            //             state:
            //                 false); // create switch for platform in and initialize to false
            //         if (LocalDataService.getLocalUsernameForPlatform(
            //                 platform) ==
            //             null) {
            //           await LocalDataService.updateUsernameForPlatform(
            //               platform: platform,
            //               username:
            //                   ""); // create username mapping for platform if absent
            //         }
            //       }
            //     }
            //   }
            //   await Navigator.push(context,
            //       MaterialPageRoute(builder: (context) {
            //     return Scaffold(
            //         body: ChooseSocials(
            //       refreshFunction: refreshScreen,
            //     ));
            //   }));
            // }),
            Container(
              child: (profilePlatforms == null ||
                      profilePlatforms.isEmpty == true)
                  ? Container()
                  // Column(
                  //     children: <Widget>[
                  //       SizedBox(height: 10),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: <Widget>[
                  //           Text(
                  //             "Add your platforms!",
                  //             style: TextStyle(
                  //               color: Colors.cyan[300],
                  //               fontSize: 25,
                  //               fontStyle: FontStyle.italic,
                  //               letterSpacing: 3.0,
                  //               //fontWeight: FontWeight.bold
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       SizedBox(height: 10),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Icon(
                  //             Icons.arrow_downward_rounded,
                  //             size: 30,
                  //             color: Colors.cyan[100],
                  //           ),
                  //           Icon(
                  //             Icons.arrow_downward_rounded,
                  //             size: 30,
                  //             color: Colors.cyan[300],
                  //           ),
                  //           Icon(
                  //             Icons.arrow_downward_rounded,
                  //             size: 30,
                  //             color: Colors.cyan[700],
                  //           ),
                  //         ],
                  //       ),
                  //       SizedBox(height: 5),
                  //     ],
                  //   )
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: SMCard(
                              platformName: profilePlatforms[index],
                              soshiUsername: soshiUsername,
                              refreshScreen: refreshScreen),
                        );
                      },
                      itemCount: profilePlatforms.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 4,
                        // crossAxisSpacing: width / 20
                      ),
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

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
  String soshiUsername, platformName, hintText = "Username", indicator;
  // used to store local state of switch
  bool isSwitched;
  TextEditingController usernameController = new TextEditingController();
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    // create global list of controllers
  }

  @override
  Widget build(BuildContext context) {
    soshiUsername = widget.soshiUsername;
    platformName = widget.platformName;
    if (platformName == "Phone") {
      hintText = "Phone Number";
      indicator = "#";
    } else if (platformName == "Linkedin" ||
        platformName == "Facebook" ||
        platformName == "Personal" ||
        platformName == "Spotify" ||
        platformName == "Youtube") {
      hintText = "Link to Profile";
      indicator = "URL";
    } else if (platformName == "Cryptowallet") {
      hintText = "Wallet address";
      indicator = "##";
    }
    // else if (platformName == "Contact") {
    //   hintText == "You should not be able to see this";
    //   indicator == "   ";
    // }
    else {
      hintText = "Username";
      indicator = "@";
    }

    databaseService = new DatabaseService(
        currSoshiUsernameIn: soshiUsername); // store ref to databaseService
    isSwitched = LocalDataService.getLocalStateForPlatform(platformName) ??
        false; // track state of platform switch
    usernameController.text =
        LocalDataService.getLocalUsernameForPlatform(platformName) ?? null;

    usernameController.text =
        LocalDataService.getLocalUsernameForPlatform(platformName);

    if (platformName == "Contact") {
      usernameController.text = "Contact Card";
    }

    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

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
                    IconButton(
                      splashRadius: Utilities.getWidth(context) / 25,
                      icon: Image.asset(
                        'assets/images/SMLogos/' + platformName + 'Logo.png',
                      ),
                      onPressed: () async {
                        if (platformName == "Contact") {
                          double width = Utilities.getWidth(context);
                          String firstName =
                              LocalDataService.getLocalFirstName();
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
                            ByteData data = await rootBundle.load(
                                "assets/images/SoshiLogos/soshi_icon.png");
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
                      iconSize: 60,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    platformName != "Contact"
                        ? Text(indicator,
                            style: TextStyle(
                                fontSize: width / 25, color: Colors.grey))
                        : Text(
                            "  ",
                          ),
                    platformName != "Contact"
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(
                                0, height / 45, 0, height / 45),
                            child: VerticalDivider(
                                thickness: 1.5, color: Colors.grey),
                          )
                        : Container(),
                    Container(
                      child: Expanded(
                          child: platformName != "Contact"
                              ? TextField(
                                  style: TextStyle(
                                      fontSize: width / 20, letterSpacing: 1.3),
                                  scribbleEnabled: true,
                                  cursorColor: Colors.blue,
                                  decoration: InputDecoration(
                                      hintText: hintText,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      counterText: ""),
                                  controller: usernameController,
                                  maxLines: 1,
                                  onSubmitted: (String username) async {
                                    LocalDataService.updateUsernameForPlatform(
                                        platform: platformName,
                                        username: username);
                                    databaseService.updateUsernameForPlatform(
                                        platform: platformName,
                                        username: username);
                                  },
                                )
                              : TextField(
                                  style: TextStyle(fontSize: width / 20),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterText: ""),
                                  controller: usernameController,
                                  maxLines: 1,
                                  readOnly:
                                      true, // so user cant edit their vcf link
                                )),
                    ),
                  ],
                ),
              )),
        ),
        Positioned(
            width: width / .55,
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
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40.0))),
                        // backgroundColor: Colors.blueGrey[900],
                        title: Text(
                          "Remove Platform",
                          style: TextStyle(
                              // color: Colors.cyan[600],
                              fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          ("Are you sure you want to remove " +
                              platformName +
                              " from your profile?"),
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
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text(
                                  'Remove',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.blue),
                                ),
                                onPressed: () async {
                                  if (!LocalDataService
                                          .getLocalChoosePlatforms()
                                      .contains(platformName)) {
                                    Navigator.pop(context);

                                    await LocalDataService
                                        .removePlatformsFromProfile(
                                            platformName);
                                    LocalDataService.addToChoosePlatforms(
                                        platformName);

                                    LocalDataService.updateSwitchForPlatform(
                                        platform: platformName, state: false);
                                    databaseService.updatePlatformSwitch(
                                        platform: platformName, state: false);
                                    databaseService.removePlatformFromProfile(
                                        platformName);
                                    databaseService
                                        .addToChoosePlatforms(platformName);
                                    print(LocalDataService
                                            .getLocalProfilePlatforms()
                                        .toString());
                                    widget.refreshScreen();
                                  } else {
                                    Navigator.pop(context);
                                    await LocalDataService
                                        .removePlatformsFromProfile(
                                            platformName);
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
                color: Colors.red,
              ),
            )),
        platformName == "Contact"
            ? Positioned(
                width: width / .8,
                height: height / 30,
                top: height / 30,
                child: ElevatedButton(
                  style: ButtonStyle(
                      // backgroundColor: Theme.of(context).brightness ==
                      //                         Brightness.light
                      //                     ? Colors.white
                      //                     : Colors.black,
                      shape: MaterialStateProperty.all(CircleBorder()),
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? MaterialStateProperty.all(Colors.white)
                              : MaterialStateProperty.all(Colors.grey[850])),
                  onPressed: () {
                    Popups.contactCardExplainedPopup(context, width, height);
                  },
                  child: Icon(
                    Icons.question_mark,
                    size: 20,
                    // color: Colors.white,
                  ),
                ))
            : Container()
      ],
    );
  }
}
