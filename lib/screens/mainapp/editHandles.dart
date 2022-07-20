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
    soshiUsername = LocalDataService.getLocalUsername();
    databaseService = new DatabaseService();
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    profilePlatforms = LocalDataService.getLocalProfilePlatforms();
    print(profilePlatforms.toString());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // loop throgh all profilePlatforms
            // check if LocalDataservice.getusernameForPlatform(platform) equals the userNameController.text for each of the profile platforms
            // if ALL match, then pop
            // if even ONE doesn't match throw popup saying "Save changes, ..."
            // Then in that popup, if they say "Save" --> same function for onpressed of "Done"
            // if they say "Discard" --> just pop

            Navigator.of(context).pop();
          },
          icon: Icon(CupertinoIcons.back),
        ),
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
        elevation: .5,
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
        padding: EdgeInsets.fromLTRB(width / 40, 0, width / 40, 0),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: height / 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
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
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: SMCard(
                              platformName: profilePlatforms[index],
                              soshiUsername: soshiUsername,
                              refreshScreen: refreshScreen),
                        );
                      },
                      itemCount: profilePlatforms.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 3.35,
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
        platformName == "Spotify" ||
        platformName == "Youtube" ||
        platformName == "AppleMusic") {
      hintText = "Link to Profile";
      indicator = "URL";
    } else if (platformName == "Personal") {
      hintText = "Link";
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
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              side:
                  // (isSwitched == true)
                  // ?
                  // BorderSide(color: Colors.blueGrey)

                  // :
                  BorderSide.none),
          elevation: 2,

          // color: Colors.grey[850],

          //Colors.grey[850],
          child: Container(
              //height: height / 14.5,
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: CircleAvatar(
                    minRadius: width / 10.5,
                    maxRadius: width / 10.5,
                    backgroundImage: AssetImage(
                      'assets/images/SMLogos/' + platformName + 'Logo.png',
                    )),
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
                          .load("assets/images/misc/default_pic.png");
                      profilePicBytes = data.buffer.asUint8List();
                    }
                    Contact contact = new Contact(
                        givenName: firstName,
                        familyName: lastName,
                        emails: [
                          Item(
                            label: "Email",
                            value: LocalDataService.getLocalUsernameForPlatform(
                                "Email"),
                          ),
                        ],
                        phones: [
                          Item(
                              label: "Cell",
                              value:
                                  LocalDataService.getLocalUsernameForPlatform(
                                      "Phone")),
                        ],
                        avatar: profilePicBytes);
                    await askPermissions(context);
                    ContactsService.addContact(contact).then((dynamic success) {
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
                        username: LocalDataService.getLocalUsernameForPlatform(
                            platformName)));
                  }
                },
                iconSize: 75,
              ),
              // SizedBox(
              //   width: width / 5,
              // ),
              platformName != "Contact"
                  ? Text(indicator,
                      style:
                          TextStyle(fontSize: width / 25, color: Colors.grey))
                  : Text(
                      "  ",
                    ),
              platformName != "Contact"
                  ? Padding(
                      padding:
                          EdgeInsets.fromLTRB(0, height / 35, 0, height / 35),
                      child:
                          VerticalDivider(thickness: 1.5, color: Colors.grey),
                    )
                  : Container(),

              Container(
                child: Expanded(
                    child: platformName != "Contact"
                        ? TextField(
                            keyboardType: platformName == "Phone"
                                ? TextInputType.numberWithOptions(
                                    decimal: true, signed: true)
                                : TextInputType.text,
                            inputFormatters: platformName == "Phone"
                                ? [FilteringTextInputFormatter.digitsOnly]
                                : null,
                            style: TextStyle(
                                fontSize: width / 20, letterSpacing: 1.3),
                            // scribbleEnabled: true,
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
                                  //for testing rn
                                  platform: platformName,
                                  username: username);
                              databaseService.updateUsernameForPlatform(
                                  platform: platformName, username: username);
                            },
                          )
                        : TextField(
                            style: TextStyle(fontSize: width / 20),
                            decoration: InputDecoration(
                                border: InputBorder.none, counterText: ""),
                            controller: usernameController,
                            maxLines: 1,
                            readOnly: true, // so user cant edit their vcf link
                          )),
              ),
            ],
          )),
        ),
        Positioned(
            width: width / .55,
            height: height / 30,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                // backgroundColor: MaterialStateProperty.all(Colors.black)
              ),
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
                        height: height / 5,
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
                                          ListTile(
                                            title: Center(
                                              child: Text(
                                                "Remove " + platformName,
                                                style: TextStyle(
                                                    fontSize: width / 20,
                                                    color: Colors.red),
                                              ),
                                            ),
                                            onTap: () async {
                                              if (!LocalDataService
                                                      .getLocalChoosePlatforms()
                                                  .contains(platformName)) {
                                                Navigator.pop(context);

                                                await LocalDataService
                                                    .removePlatformsFromProfile(
                                                        platformName);
                                                LocalDataService
                                                    .addToChoosePlatforms(
                                                        platformName);

                                                LocalDataService
                                                    .updateSwitchForPlatform(
                                                        platform: platformName,
                                                        state: false);
                                                databaseService
                                                    .updatePlatformSwitch(
                                                        platform: platformName,
                                                        state: false);
                                                databaseService
                                                    .removePlatformFromProfile(
                                                        platformName);
                                                databaseService
                                                    .addToChoosePlatforms(
                                                        platformName);
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
                top: height / 27,
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
            : Container(),
      ],
    );
  }
}
