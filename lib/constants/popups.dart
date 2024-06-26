import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/contacts.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:http/http.dart' as http;
import 'package:soshi/services/url.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
// import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import '../screens/mainapp/friendScreen.dart';
import '../screens/mainapp/groupScreen.dart';
import '../screens/mainapp/viewGroupPage.dart';
import '../services/dataEngine.dart';
import 'constants.dart';
//import 'package:google_fonts/google_fonts.dart';

/*
Custom popup dialogs
*/
class Popups {
  static void platformSwitchesExplained(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            //backgroundColor: Colors.blueGrey[900],
            title: Text(
              "Platform Switches",
              style: TextStyle(
                  // color: Colors.cyan[600],
                  fontWeight: FontWeight.bold),
            ),
            content: Text(
              ("These switches control what platform(s) you are sharing. "),
              style: TextStyle(
                  fontSize: 20,
                  // color: Colors.cyan[700],
                  fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  // static void twoWarSharingExplained(
  //     BuildContext context, double width, double height) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(40.0))),
  //           //backgroundColor: Colors.blueGrey[900],
  //           title: Text(
  //             "2 way sharing!",
  //             style: TextStyle(
  //                 // color: Colors.cyan[600],
  //                 fontWeight: FontWeight.bold),
  //           ),
  //           content: Text(
  //             ("When this switch is enabled, this means that when you share your QR code, you are added as a friend on their account AND they are added as a friend on yours!"),
  //             style: TextStyle(
  //                 fontSize: 20,
  //                 // color: Colors.cyan[700],
  //                 fontWeight: FontWeight.bold),
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //               child: Text(
  //                 'Ok',
  //                 style: TextStyle(fontSize: 20, color: Colors.blue),
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }

  static void contactCardExplainedPopup(
      BuildContext context, double width, double height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.grey[850],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            // backgroundColor: Colors.blueGrey[900],
            title: Text(
              "Contact Card",
              style: TextStyle(
                  // color: Colors.cyan[600],
                  fontWeight: FontWeight.bold),
            ),
            content: Flex(
              direction: Axis.vertical,
              children: [
                Flexible(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Theme.of(context).brightness == Brightness.light
                        ? Image.network(
                            "https://firebasestorage.googleapis.com/v0/b/soshi-bc9ec.appspot.com/o/GifsAndAnimations%2FcontactCardExampleLight.gif?alt=media&token=6f3b422b-d9f8-4ff3-9a1b-71ec657e8f31")
                        : Image.network(
                            "https://firebasestorage.googleapis.com/v0/b/soshi-bc9ec.appspot.com/o/GifsAndAnimations%2FcontactCardExampleDark.gif?alt=media&token=3eab18ba-4088-4ff8-b801-f645a01a182f",
                          ),
                  ],
                )),
                Padding(
                  padding: EdgeInsets.only(top: height / 90),
                  child: Text("Share your contact card!"),
                )
              ],
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: width / 20),
                child: TextButton(
                  child: Text(
                    'Done',
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        });
  }

  static Future<dynamic> showContactAddedPopup(
      BuildContext context,
      double width,
      String profilePicURL,
      String firstName,
      String lastName,
      String phoneNumber,
      String email) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              TextButton(
                child: Text("Done",
                    style: TextStyle(color: Colors.blue, fontSize: width / 20)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            // backgroundColor: Colors.grey[850],
            content: Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ProfilePic(
                    radius: width / 8,
                    url: profilePicURL,
                  ),
                  SizedBox(
                    height: height / 80,
                  ),
                  Center(
                    child: Text(
                      firstName + " " + lastName,
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: width / 18,
                          letterSpacing: 1.2),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.phone),
                      SizedBox(width: 5),
                      Text(phoneNumber)
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.mail),
                      SizedBox(width: 5),
                      Text(email)
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    thickness: .5,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    firstName +
                        "'s information has been added to your devices contacts.",
                    style: TextStyle(fontSize: width / 22),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          );
        });
  }

  static void editUsernamePopup(BuildContext context, String soshiuser,
      String platformName, double width) {
    DatabaseService databaseService =
        new DatabaseService(currSoshiUsernameIn: soshiuser);
    TextEditingController usernameController = new TextEditingController();
    String usernameForPlatform =
        LocalDataService.getLocalUsernameForPlatform(platformName);
    usernameController.text = usernameForPlatform;
    String indicator;
    String hintText;
    if (platformName == "Instagram" ||
        platformName == "Snapchat" ||
        platformName == "Venmo" ||
        platformName == "Twitter" ||
        platformName == "Tiktok" ||
        platformName == "Discord" ||
        platformName == "BeReal" ||
        platformName == "CashApp" ||
        platformName == "Vsco" ||
        platformName == "OnlyFans") {
      hintText = "Username";
      indicator = "@";
    } else {
      if (platformName == "Facebook" ||
          platformName == "Linkedin" ||
          platformName == "Personal" ||
          platformName == "Spotify" ||
          platformName == "AppleMusic") {
        hintText = "Link To Profile";
        indicator = "https://";
      } else if (platformName == "Phone") {
        hintText = "Phone Number";
        indicator = "#";
      } else if (platformName == "Youtube") {
        hintText = "Channel ID";
        indicator = "Chan. ID";
      } else if (platformName == "Cryptowallet") {
        hintText = "0x...";
        indicator = "Wallet addr."; // or "Wallet Addr."
      } else {
        hintText = "";
        indicator = "";
      }
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            // backgroundColor: Colors.blueGrey[900],
            title: Text(
              platformName.contains("Cryptowallet")
                  ? "Edit your Crypto Hash"
                  : "Edit your " + platformName,
            ),
            //   style: TextStyle(
            //       //color: Colors.cyan[600],
            //       //fontWeight: FontWeight.bold),
            // ),
            content: Row(
              children: [
                Text(indicator,
                    style: TextStyle(
                      // color: Colors.white,
                      fontSize: width / 20,
                      //fontWeight: FontWeight.bold
                    )),
                SizedBox(width: width / 40),
                Expanded(
                  child: TextField(
                    keyboardType: platformName.contains("Phone")
                        ? TextInputType.phone
                        : null,
                    autocorrect: false,
                    controller: usernameController,
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: width / 20,
                      //color: Colors.cyan[300]
                    ),
                    onSubmitted: (String inputText) {
                      LocalDataService.updateUsernameForPlatform(
                          platform: platformName, username: inputText);
                      databaseService.updateUsernameForPlatform(
                          platform: platformName, username: inputText);
                      Navigator.pop(context);
                    },
                    decoration: InputDecoration(
                      // enabledBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(

                      //       // color: Colors.grey[600],
                      //       ),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //     color: Colors.cyan[300],
                      //   ),
                      // ),
                      filled: false,
                      //floatingLabelBehavior: FloatingLabelBehavior.never,
                      // label: Text(platformName.contains("Cryptowallet")
                      //     ? hintText
                      //     : indicator),
                      // labelStyle: TextStyle(
                      //   fontSize: 15,
                      //   //color: Colors.black

                      //   // \\\color: Colors.grey[400]),
                      // ),
                      // fillColor: Colors.grey[850],
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: width / 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: width / 50),
                child: TextButton(
                  child: Text(
                    'Done',
                    style: TextStyle(fontSize: width / 20, color: Colors.blue),
                  ),
                  onPressed: () async {
                    LocalDataService.updateUsernameForPlatform(
                        platform: platformName,
                        username: usernameController.text);
                    databaseService.updateUsernameForPlatform(
                        platform: platformName,
                        username: usernameController.text);
                    Navigator.pop(context);
                  },
                ),
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: <Widget>[
              //     TextButton(
              //       child: Text(
              //         'Cancel',
              //         style: TextStyle(fontSize: width / 20, color: Colors.red),
              //       ),
              //       onPressed: () {
              //         Navigator.pop(context);
              //       },
              //     ),
              //     TextButton(
              //       child: Text(
              //         'Done',
              //         style:
              //             TextStyle(fontSize: width / 20, color: Colors.blue),
              //       ),
              //       onPressed: () async {
              //         LocalDataService.updateUsernameForPlatform(
              //             platform: platformName,
              //             username: usernameController.text);
              //         databaseService.updateUsernameForPlatform(
              //             platform: platformName,
              //             username: usernameController.text);
              //         Navigator.pop(context);
              //       },
              //     ),
              //   ],
              // ),
            ],
          );
        });
  }

  static void deletePlatformPopup(BuildContext context,
      {@required String platformName, @required Function refreshScreen}) {
    DatabaseService databaseService = new DatabaseService();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0))),
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
                            if (!LocalDataService.getLocalChoosePlatforms()
                                .contains(platformName)) {
                              Navigator.pop(context);
                            }
                          })
                    ])
              ]);
        });
  }

  //                       await LocalDataService.removePlatformsFromProfile(
  //                           platformName);
  //                       LocalDataService.addToChoosePlatforms(platformName);

  //                       LocalDataService.updateSwitchForPlatform(
  //                           platform: platformName, state: false);
  //                       databaseService.updatePlatformSwitch(
  //                           platform: platformName, state: false);
  //                       databaseService.removePlatformFromProfile(platformName);
  //                       databaseService.addToChoosePlatforms(platformName);
  //                       print(LocalDataService.getLocalProfilePlatforms()
  //                           .toString());
  //                       refreshScreen();
  //                     } else {
  //                       Navigator.pop(context);
  //                       await LocalDataService.removePlatformsFromProfile(
  //                           platformName);
  //                       refreshScreen();
  //                     }
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ],
  //         );
  //       });
  // }
  // // display popup with user profile and social media links
  // static Future<void> showUserProfilePopup(BuildContext context,
  //     {String soshiUsername, Function refreshScreen}) async {
  //   if (refreshScreen == null) {
  //     refreshScreen = () {};
  //   }
  //   // get list of all visible platforms
  //   DatabaseService databaseService = new DatabaseService(
  //       currSoshiUsernameIn: LocalDataService.getLocalUsername());
  //   Map userData = await databaseService.getUserFile(soshiUsername);
  //   List<String> visiblePlatforms =
  //       await databaseService.getEnabledPlatformsList(userData);
  //   // get list of profile usernames
  //   Map<String, dynamic> usernames =
  //       databaseService.getUserProfileNames(userData);
  //   String fullName = await databaseService.getFullName(userData);
  //   bool isFriendAdded = LocalDataService.isFriendAdded(soshiUsername);
  //   String profilePhotoURL = await databaseService.getPhotoURL(userData);
  //   String bio = await databaseService.getBio(userData);

  //   double height = MediaQuery.of(context).size.height;
  //   double width = MediaQuery.of(context).size.width;

  //   showGeneralDialog(
  //       transitionDuration: Duration(milliseconds: 150),
  //       barrierDismissible: true,
  //       barrierLabel: '',
  //       context: context,
  //       pageBuilder: (context, animation1, animation2) {},
  //       barrierColor: Colors.grey[500].withOpacity(.25),
  //       transitionBuilder: (context, a1, a2, widget) {
  //         return Transform.scale(
  //           scale: a1.value,
  //           child: AlertDialog(
  //               insetPadding: EdgeInsets.all(0.0),
  //               backgroundColor: Colors.transparent,
  //               contentPadding:
  //                   EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(30.0),
  //               ),
  //               content: StatefulBuilder(
  //                   builder: (BuildContext context, StateSetter setState) {
  //                 return Stack(children: [
  //                   Container(
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.all(Radius.circular(30.0)),
  //                       color: Colors.grey[900],
  //                     ),
  //                     padding: EdgeInsets.only(top: width / 5.75),
  //                     margin: EdgeInsets.only(top: width / 5.75),
  //                     height: height / 1.65,
  //                     width: width / 1.1,
  //                     child: Column(children: [
  //                       Column(children: [
  //                         Column(
  //                           children: [
  //                             Text(
  //                               fullName,
  //                               style: TextStyle(
  //                                   fontSize: 20.0,
  //                                   fontWeight: FontWeight.bold,
  //                                   color: Colors.grey[200]),
  //                             ),
  //                             Text(
  //                               "@" + usernames["Soshi"],
  //                               style: TextStyle(
  //                                   fontSize: 15.0,
  //                                   color: Colors.grey[500],
  //                                   fontStyle: FontStyle.italic),
  //                             ),
  //                           ],
  //                         ),
  //                       ]),
  //                       Padding(
  //                         padding:
  //                             const EdgeInsets.fromLTRB(10.0, 15.0, 15.0, 10.0),
  //                         child: (bio != null)
  //                             ? Container(
  //                                 decoration: BoxDecoration(
  //                                     borderRadius: BorderRadius.circular(5.0),
  //                                     border: Border.all(
  //                                         color: Colors.grey[700], width: 1.0)),
  //                                 height: height / 20,
  //                                 width: width / 1.1,
  //                                 child: Center(
  //                                   child: Text(bio,
  //                                       style: TextStyle(
  //                                         color: Colors.grey[300],
  //                                       )),
  //                                 ),
  //                               )
  //                             : Container(),
  //                       ),
  //                       Divider(color: Colors.cyan[300]),
  //                       Container(
  //                         height: height / 3.5,
  //                         width: width,
  //                         padding: EdgeInsets.only(top: 10.0),
  //                         child: (visiblePlatforms.length > 0)
  //                             ? GridView.builder(
  //                                 padding: EdgeInsets.zero,
  //                                 gridDelegate:
  //                                     SliverGridDelegateWithFixedCrossAxisCount(
  //                                         crossAxisCount: 3),
  //                                 scrollDirection: Axis.vertical,
  //                                 itemBuilder: (BuildContext context, int i) {
  //                                   return createSMButton(
  //                                       soshiUsername: soshiUsername,
  //                                       platform: visiblePlatforms[i],
  //                                       username:
  //                                           usernames[visiblePlatforms[i]],
  //                                       size: width / 5,
  //                                       context: context);
  //                                 },
  //                                 itemCount: visiblePlatforms.length,
  //                               )
  //                             : Center(
  //                                 child: Padding(
  //                                   padding: const EdgeInsets.all(15),
  //                                   child: Text(
  //                                     "This user isn't currently sharing any social media platforms :(",
  //                                     style: Constants.CustomCyan,
  //                                   ),
  //                                 ),
  //                               ),
  //                       ),
  //                       ElevatedButton(
  // onPressed: () async {
  //   if (isFriendAdded) {
  //     // do nothing
  //   } else {
  //     setState(() {
  //       isFriendAdded = true;
  //     });
  //     // add friend, update button, refresh screen
  //     await LocalDataService.addFriend(
  //         friendsoshiUsername: soshiUsername);
  //     databaseService.addFriend(
  //         friendSoshiUsername: soshiUsername);
  //     refreshScreen();
  //   }
  // },
  //                           style: ElevatedButton.styleFrom(
  //                               primary: isFriendAdded
  //                                   ? Colors.white
  //                                   : Color(0xFF181818)),
  //                           child: Container(
  //                             width: 150.0,
  //                             child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: (isFriendAdded)
  //                                     ? [
  //                                         Text(
  //                                           "Friend Added",
  //                                           style: TextStyle(
  //                                               fontSize: 20.0,
  //                                               // fontWeight: FontWeight.bold,
  //                                               color: Colors.black),
  //                                         ),
  //                                         Padding(
  //                                             padding:
  //                                                 EdgeInsets.only(left: 5.0)),
  //                                         Icon(
  //                                           Icons.verified_user,
  //                                           color: Colors.green,
  //                                         )
  //                                       ]
  //                                     : [
  //                                         Text(
  //                                           "Add Friend",
  //                                           style: TextStyle(
  //                                               fontSize: 20.0,
  //                                               fontWeight: FontWeight.bold,
  //                                               color: Colors.cyan[300]),
  //                                         ),
  //                                         Padding(
  //                                             padding:
  //                                                 EdgeInsets.only(left: 5.0)),
  //                                         Icon(
  //                                           Icons.add_circle,
  //                                           color: Colors.cyan[300],
  //                                         )
  //                                       ]),
  //                           )),
  //                       // Row(
  //                       //   mainAxisAlignment: MainAxisAlignment.end,
  //                       //   children: [
  //                       //     Padding(
  //                       //       padding: const EdgeInsets.all(8.0),
  //                       //       child: FloatingActionButton(
  //                       //           backgroundColor: Colors.cyan[400],
  //                       //           onPressed: () => Navigator.pop(context),
  //                       //           child: Icon(FlutterIcons.check_circle_faw,
  //                       //               size: width / 10)),
  //                       //     ),
  //                       //   ],
  //                       // )
  //                     ]),
  //                   ),
  //                   Positioned(
  //                       left: (width / 3.5),
  //                       // right: width / 2 - width / 3,
  //                       child: ProfilePic(
  //                           url: profilePhotoURL, radius: width / 6)),
  //                 ]);
  //               })),
  //         );
  //       });
  // }

  void usernameEmptyPopup(
      BuildContext context, String platformName, String identifier) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
          );
        });
  }

  static Future<dynamic> showPlatformHelpPopup(
      BuildContext context, double height) async {
    return showGeneralDialog(
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {},
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40.0))),
                // backgroundColor: Colors.blueGrey[900],
                title: Text(
                  "Linking Social Media",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    //color: Colors.cyan[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Container(
                  height: height / 2.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "For sharing TIKTOK, LINKEDIN, or FACEBOOK:",
                        style: TextStyle(
                          fontSize: 15,
                          // color: Colors.cyan[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Tiktok: ",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  // color: Colors.cyan[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      // primary: Colors.blueGrey,
                                      shadowColor: Constants.buttonColorDark,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)))),
                                  onPressed: () {
                                    URL.launchURL(
                                        "https://support.tiktok.com/en/using-tiktok/exploring-videos/sharing");
                                  },
                                  child: Text("Press me!")),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "LinkedIn: ",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  // color: Colors.cyan[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      // primary: Colors.blueGrey,
                                      shadowColor: Constants.buttonColorDark,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)))),
                                  onPressed: () {
                                    URL.launchURL(
                                        "https://www.linkedin.com/help/linkedin/answer/49315/find-your-linkedin-public-profile-url?lang=en");
                                  },
                                  child: Text("Press me!")),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Facebook: ",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  // color: Colors.cyan[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      // primary: Colors.blueGrey,
                                      shadowColor: Constants.buttonColorDark,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)))),
                                  onPressed: () {
                                    URL.launchURL(
                                        "https://knowledgebase.constantcontact.com/tutorials/KnowledgeBase/6069-find-the-url-for-a-facebook-profile-or-business-page?lang=en_US");
                                  },
                                  child: Text("Press me!")),
                            )
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "+ For phone, just enter your #",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                // color: Colors.cyan[700],
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "+ For all the other platforms just enter your username :)",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                // color: Colors.cyan[700],
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ], //
                  ),
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      child: Text('Ok',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          )),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  static void showJoinGroupPopup(BuildContext context, String groupId) async {
    double width = Utilities.getWidth(context);
    // get group details
    DatabaseService databaseService = DatabaseService(
        currSoshiUsernameIn: LocalDataService.getLocalUsername());

    Group group = await databaseService.getGroupData(groupId);

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return JoinGroupPopup(width, databaseService, group);
        });
  }

  static void displayNameErrorPopUp(String firstOrLast, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            // backgroundColor: Colors.blueGrey[900],
            title: Text(
              "Error",
              style: TextStyle(
                  color: Colors.cyan[600], fontWeight: FontWeight.bold),
            ),
            content: Text(
              ("$firstOrLast name must be between 1 and 12 characters"),
              style: TextStyle(
                //color: Colors.cyan[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  static void soshiPointsExplainedPopup(
      BuildContext context, double width, double height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            title: Text(
              "My Soshi Bolts",
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NeumorphicIcon(CupertinoIcons.bolt_circle_fill,
                      style: NeumorphicStyle(
                          depth: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shadowLightColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.black),
                      size: width / 6),
                ),

                Text("You have " +
                    LocalDataService.getSoshiPoints().toString() +
                    " Soshi bolts.\n"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Customize your profile and make new friends to earn bolts!",
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                      height: height / 20,
                      width: width / 1.1,
                      child: Center(
                          child: Text("Close",
                              style: TextStyle(
                                  color: Colors.blue, fontSize: width / 22))),
                    ),
                  ),
                ),
                // Text(
                //     "Who knows what you can get with these points in the future!")
              ],
            ),
          );
        });
  }
}
//}

class JoinGroupPopup extends StatefulWidget {
  double width;
  DatabaseService databaseService;
  Group group;
  JoinGroupPopup(this.width, this.databaseService, this.group);

  @override
  State<JoinGroupPopup> createState() => _JoinGroupPopupState();
}

class _JoinGroupPopupState extends State<JoinGroupPopup> {
  Group group;
  double width;
  DatabaseService databaseService;
  bool hasJoined;
  bool isJoining;
  String username;
  @override
  void initState() {
    this.width = widget.width;
    this.group = widget.group;
    this.databaseService = widget.databaseService;
    username = LocalDataService.getLocalUsername();
    hasJoined =
        group.members.contains(username) || group.admin.contains(username);
    isJoining = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0))),
        height: 250,
        // color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Hero(
                    tag: group.id,
                    child: RectangularProfilePic(
                        radius: width / 3, url: group.photoURL)),
                Text(group.name),
              ],
            ),
            ElevatedButton(
                onPressed: () async {
                  if (!isJoining) {
                    if (hasJoined) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ViewGroupPage(
                            group); // Returning the ResetPassword screen
                      }));
                    } else {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        isJoining = true;
                      });
                      await databaseService.joinGroup(group.id);
                      setState(() {
                        isJoining = false;
                        hasJoined = true;
                      });
                    }
                  }
                },
                child: Container(
                    width: width / 3,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: !isJoining
                            ? Text(
                                (hasJoined) ? "View Group" : "Join Group",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : Colors.black),
                                textAlign: TextAlign.center,
                              )
                            : Center(child: CircularProgressIndicator()))),
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).brightness != Brightness.light
                        ? Colors.white
                        : Colors.black,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)))),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text("Close", style: TextStyle(color: Colors.blue)))
          ],
        ));
  }
}
