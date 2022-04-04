import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/contacts.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:http/http.dart' as http;
import 'package:soshi/services/url.dart';
// import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'constants.dart';
//import 'package:google_fonts/google_fonts.dart';

/*
Custom popup dialogs
*/
class Popups {
  // Create a clickable social media icon
  static Widget createSMButton(
      {String soshiUsername,
      String platform,
      String username,
      double size = 70.0,
      BuildContext context}) {
    return Container(
        child: IconButton(
      // splashColor: Colors.cyan[300],
      splashRadius: 55.0,
      icon: Image.asset(
        "assets/images/SMLogos/" + platform + "Logo.png",
      ),
      onPressed: () async {
        Analytics.logAccessPlatform(platform);
        if (platform == "Contact") {
          DialogBuilder(context).showLoadingIndicator();

          double width = MediaQuery.of(context).size.width;
          DatabaseService databaseService =
              new DatabaseService(currSoshiUsernameIn: soshiUsername);
          Map userData = await databaseService.getUserFile(soshiUsername);

          String firstName =
              await databaseService.getFirstDisplayName(userData);
          String lastName = databaseService.getLastDisplayName(userData);
          String email = await databaseService.getUsernameForPlatform(
              platform: "Email", userData: userData);
          String phoneNumber = await databaseService.getUsernameForPlatform(
              platform: "Phone", userData: userData);
          String photoUrl = databaseService.getPhotoURL(userData);

          Uint8List profilePicBytes;

          try {
            // try to load profile pic from url
            await http.get(Uri.parse(photoUrl)).then((http.Response response) {
              profilePicBytes = response.bodyBytes;
            });
          } catch (e) {
            // if url is invalid, use default profile pic
            ByteData data = await rootBundle
                .load("assets/images/SoshiLogos/soshi_icon.png");
            profilePicBytes = data.buffer.asUint8List();
          }
          Contact newContact = new Contact(
              givenName: firstName,
              familyName: lastName,
              emails: [
                Item(label: "Email", value: email),
              ],
              phones: [
                Item(label: "Cell", value: phoneNumber),
              ],
              avatar: profilePicBytes);
          await askPermissions(context);

          await ContactsService.addContact(newContact);

          DialogBuilder(context).hideOpenDialog();

          Popups.showContactAddedPopup(context, width, firstName, lastName);

          //ContactsService.openContactForm();
          // ContactsService.addContact(newContact).then((dynamic success) {
          // });
          //         ContactsService.addContact(newContact).then(dynamic success)
          // {             ContactsService.openExistingContact(newContact);
          //       };

          // .then((dynamic success) {
          //   Popups.showContactAddedPopup(context, width, firstName, lastName);
          // });
        } else {
          print("Launching $username");
          URL.launchURL(
              URL.getPlatformURL(platform: platform, username: username));
        }
      },
      iconSize: size,
    ));
  }

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

  static void twoWarSharingExplained(
      BuildContext context, double width, double height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            //backgroundColor: Colors.blueGrey[900],
            title: Text(
              "2 way sharing!",
              style: TextStyle(
                  // color: Colors.cyan[600],
                  fontWeight: FontWeight.bold),
            ),
            content: Text(
              ("When this switch is enabled, this means that when you share your QR code, you are added as a friend on their account AND they are added as a friend on yours!"),
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

  static void contactCardExplainedPopup(
      BuildContext context, double width, double height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
                    Padding(
                      padding: EdgeInsets.only(top: height / 55.0),
                      child: Text("Share your contact card with one tap!"),
                    )
                  ],
                ))
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
      BuildContext context, double width, String firstName, String lastName) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            // backgroundColor: Colors.grey[850],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/images/SMLogos/ContactLogo.png",
                        height: width / 4,
                        width: width / 4,
                      ),
                      Icon(Icons.check,
                          color: Colors.green[600],
                          size: MediaQuery.of(context).size.width / 4)
                      // Positioned(
                      //   top: width / 2 - width / 5,
                      //   left: width / 2 - width / 5,
                      //   child: Icon(Icons.check,
                      //       color: Colors.green[600],
                      //       size: MediaQuery.of(context).size.width / 4),
                      // ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                    '$firstName $lastName was added to your device\'s contacts!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      // color: Colors.white,
                      //fontFamily: GoogleFonts.lato().fontFamily,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        child: Text(
                          "Dismiss",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  static void editUsernamePopup(BuildContext context, String soshiuser,
      String platformName, String hinttext, String indicator, double width) {
    DatabaseService databaseService =
        new DatabaseService(currSoshiUsernameIn: soshiuser);
    TextEditingController usernameController = new TextEditingController();
    String usernameForPlatform =
        LocalDataService.getLocalUsernameForPlatform(platformName);
    usernameController.text = usernameForPlatform;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            // backgroundColor: Colors.blueGrey[900],
            title: Text(
              "Edit your " + platformName,
            ),
            //   style: TextStyle(
            //       //color: Colors.cyan[600],
            //       //fontWeight: FontWeight.bold),
            // ),
            content: Row(
              children: [
                Text(
                  indicator,
                  style: TextStyle(
                      // color: Colors.white,
                      fontSize: width / 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: width / 40),
                Expanded(
                  child: TextField(
                    keyboardType: platformName.contains("Phone")
                        ? TextInputType.phone
                        : null,
                    autocorrect: false,
                    controller: usernameController,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: width / 20,
                        color: Colors.cyan[300]),
                    onSubmitted: (String inputText) {
                      LocalDataService.updateUsernameForPlatform(
                          platform: platformName, username: inputText);
                      databaseService.updateUsernameForPlatform(
                          platform: platformName, username: inputText);
                      Navigator.pop(context);
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            // color: Colors.grey[600],
                            ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.cyan[300],
                        ),
                      ),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: Text(platformName),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        //color: Colors.black

                        // \\\color: Colors.grey[400]),
                      ),
                      // fillColor: Colors.grey[850],
                      hintText: hinttext,
                      hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 20,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: width / 20, color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Done',
                      style:
                          TextStyle(fontSize: width / 20, color: Colors.blue),
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
                ],
              ),
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

                        await LocalDataService.removePlatformsFromProfile(
                            platformName);
                        LocalDataService.addToChoosePlatforms(platformName);

                        LocalDataService.updateSwitchForPlatform(
                            platform: platformName, state: false);
                        databaseService.updatePlatformSwitch(
                            platform: platformName, state: false);
                        databaseService.removePlatformFromProfile(platformName);
                        databaseService.addToChoosePlatforms(platformName);
                        print(LocalDataService.getLocalProfilePlatforms()
                            .toString());
                        refreshScreen();
                      } else {
                        Navigator.pop(context);
                        await LocalDataService.removePlatformsFromProfile(
                            platformName);
                        refreshScreen();
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }
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
  //                           onPressed: () async {
  //                             if (isFriendAdded) {
  //                               // do nothing
  //                             } else {
  //                               setState(() {
  //                                 isFriendAdded = true;
  //                               });
  //                               // add friend, update button, refresh screen
  //                               await LocalDataService.addFriend(
  //                                   friendsoshiUsername: soshiUsername);
  //                               databaseService.addFriend(
  //                                   friendSoshiUsername: soshiUsername);
  //                               refreshScreen();
  //                             }
  //                           },
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

  static void showUserProfilePopupNew(BuildContext context,
      {String friendSoshiUsername, Function refreshScreen}) async {
    // get list of all visible platforms
    DatabaseService databaseService = new DatabaseService(
        currSoshiUsernameIn: LocalDataService.getLocalUsername());
    String userUsername = LocalDataService.getLocalUsername();
    Map userData = await databaseService.getUserFile(friendSoshiUsername);
    List<String> visiblePlatforms =
        await databaseService.getEnabledPlatformsList(userData);
    // get list of profile usernames
    Map<String, dynamic> usernames =
        databaseService.getUserProfileNames(userData);
    String fullName = databaseService.getFullName(userData);
    bool isFriendAdded = LocalDataService.isFriendAdded(friendSoshiUsername);
    String profilePhotoURL = databaseService.getPhotoURL(userData);
    String bio = databaseService.getBio(userData);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    int numfriends = userData["Friends"].length;
    String numFriendsString = numfriends.toString();
    // increment variable for use with scrolling SM buttons (use instead of i)

    showGeneralDialog(

        //barrierColor: Colors.grey[500].withOpacity(.25),
        context: context,
        transitionDuration: Duration(milliseconds: 150),
        barrierDismissible: true,
        barrierLabel: '',
        pageBuilder: (context, animation1, animation2) {},
        barrierColor: Colors.grey[500].withOpacity(.25),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: AlertDialog(
                elevation: 50,
                insetPadding: EdgeInsets.all(width / 14),
                //insetPadding: EdgeInsets.all(0.0),
                // backgroundColor: Colors.black,
                // contentPadding:
                //     EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                content: Container(
                  height: height / 1.7,
                  child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: ProfilePic(
                                  url: profilePhotoURL, radius: height / 16),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: width / 30),
                              child: Container(
                                height: height / 8,
                                width: width / 2.5,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      fullName,
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontSize: width / 22,
                                        fontWeight: FontWeight.bold,
                                        // color: Colors.grey[200]
                                      ),
                                    ),
                                    //SizedBox(height: height / 120),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "@" + usernames["Soshi"],
                                          style: TextStyle(
                                              fontSize: width / 23,
                                              // color: Colors.grey[500],
                                              fontStyle: FontStyle.italic),
                                        ),
                                        SizedBox(height: height / 80),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.emoji_people,
                                              color: Colors.cyan,
                                            ),
                                            SizedBox(width: width / 100),
                                            Text(
                                              "Friends: " + numFriendsString,
                                              style: TextStyle(
                                                  fontSize: width / 25,
                                                  // color: Colors.grey[500],
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                    color: Colors.transparent, width: 1.0)),
                            //height: height / 20,
                            width: width,
                            child: Center(
                                child: (bio != null)
                                    ? Text(bio,
                                        style: TextStyle(
                                            // color: Colors.grey[300],
                                            ))
                                    : Container()),
                          ),
                        ),
                        Divider(
                          // color: Colors.blueGrey,
                          color: Colors.grey[850],
                          thickness: 1,
                        ),
                        Container(
                          height: height / 3.5,
                          width: width,
                          padding: EdgeInsets.only(top: 10.0),
                          child: (visiblePlatforms.length > 0)
                              ? GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (BuildContext context, int i) {
                                    return createSMButton(
                                        soshiUsername: friendSoshiUsername,
                                        platform: visiblePlatforms[i],
                                        username:
                                            usernames[visiblePlatforms[i]],
                                        size: width / 5,
                                        context: context);
                                  },
                                  itemCount: visiblePlatforms.length,
                                )
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(
                                      "This user isn't currently sharing any social media platforms :(",
                                      style: Constants.CustomCyan,
                                    ),
                                  ),
                                ),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              if (isFriendAdded ||
                                  friendSoshiUsername == userUsername) {
                                // do nothing
                              } else {
                                setState(() {
                                  isFriendAdded = true;
                                });
                                // add friend, update button, refresh screen
                                await LocalDataService.addFriend(
                                    friendsoshiUsername: friendSoshiUsername);
                                databaseService.addFriend(
                                    thisSoshiUsername:
                                        databaseService.currSoshiUsername,
                                    friendSoshiUsername: friendSoshiUsername);

                                bool friendHasTwoWaySharing =
                                    await databaseService
                                        .getTwoWaySharing(userData);
                                if (friendHasTwoWaySharing == null ||
                                    friendHasTwoWaySharing == true) {
                                  // if user has two way sharing on, add self to user's friends list
                                  databaseService.addFriend(
                                      thisSoshiUsername: friendSoshiUsername,
                                      friendSoshiUsername:
                                          databaseService.currSoshiUsername);
                                }
                                Analytics.logAddFriend(friendSoshiUsername);
                                refreshScreen();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 10.0,
                              minimumSize: Size(width / 1.7, height / 15),
                              shape: RoundedRectangleBorder(
                                  side: (isFriendAdded)
                                      ? BorderSide.none
                                      : BorderSide(color: Colors.cyan),
                                  borderRadius: BorderRadius.circular(25.0)),
                              //  primary:
                              // Colors.white
                            ),
                            child: Container(
                              width: 150.0,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: (isFriendAdded)
                                      ? [
                                          Text(
                                            "Friend Added",
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.bold,
                                              //color: Colors.black
                                            ),
                                          ),
                                        ]
                                      : [
                                          Text(
                                            "Add Friend",
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.cyan[300]),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 5.0)),
                                          Icon(
                                            Icons.add_reaction_outlined,
                                            color: Colors.cyan[300],
                                          )
                                        ]),
                            )),
                      ],
                    );

                    // Stack(children: [
                    //   Container(
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    //       color: Colors.grey[900],
                    //     ),
                    //     padding: EdgeInsets.only(top: width / 5.75),
                    //     margin: EdgeInsets.only(top: width / 5.75),
                    //     height: height / 1.65,
                    //     width: width / 1.1,
                    //     child: Column(children: [
                    //       Column(children: [
                    //         Column(
                    //           children: [
                    //             Text(
                    //               fullName,
                    //               style: TextStyle(
                    //                   fontSize: 20.0,
                    //                   fontWeight: FontWeight.bold,
                    //                   color: Colors.grey[200]),
                    //             ),
                    //             Text(
                    //               "@" + usernames["Soshi"],
                    //               style: TextStyle(
                    //                   fontSize: 15.0,
                    //                   color: Colors.grey[500],
                    //                   fontStyle: FontStyle.italic),
                    //             ),
                    //           ],
                    //         ),
                    //       ]),
                    //       Padding(
                    //         padding:
                    //             const EdgeInsets.fromLTRB(10.0, 15.0, 15.0, 10.0),
                    //         child: Container(
                    //           decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(5.0),
                    //               border: Border.all(
                    //                   color: Colors.grey[700], width: 1.0)),
                    //           height: height / 20,
                    //           width: width / 1.1,
                    //           child: Center(
                    //             child: Text(LocalDataService.getBio(),
                    //                 style: TextStyle(
                    //                   color: Colors.grey[300],
                    //                 )),
                    //           ),
                    //         ),
                    //       ),
                    //       Padding(
                    //         padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    //         child: Divider(color: Colors.cyan[300]),
                    //       ),
                    //       Container(
                    //         height: height / 3.5,
                    //         width: width,
                    //         padding: EdgeInsets.only(top: 10.0),
                    //         child: (visiblePlatforms.length > 0)
                    //             ? ListView.separated(
                    //                 separatorBuilder:
                    //                     (BuildContext context, int i) {
                    //                   return Padding(padding: EdgeInsets.all(10.0));
                    //                 },
                    //                 scrollDirection: Axis.vertical,
                    //                 itemBuilder: (BuildContext context, int i) {
                    //                   return Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       children: [
                    //                         createSMButton(
                    //                             soshiUsername: soshiUsername,
                    //                             platform: visiblePlatforms[index],
                    //                             username: usernames[
                    //                                 visiblePlatforms[index++]],
                    //                             size: width / 5,
                    //                             context: context),
                    //                         (index >= visiblePlatforms.length)
                    //                             ? Text("")
                    //                             : Padding(
                    //                                 padding:
                    //                                     const EdgeInsets.fromLTRB(
                    //                                         5.0, 0.0, 5.0, 0.0),
                    //                                 child: createSMButton(
                    //                                     soshiUsername:
                    //                                         soshiUsername,
                    //                                     platform:
                    //                                         visiblePlatforms[index],
                    //                                     username: usernames[
                    //                                         visiblePlatforms[
                    //                                             index++]],
                    //                                     size: width / 5,
                    //                                     context: context),
                    //                               ),
                    //                         (index >= visiblePlatforms.length)
                    //                             ? Text("")
                    //                             : createSMButton(
                    //                                 soshiUsername: soshiUsername,
                    //                                 platform:
                    //                                     visiblePlatforms[index],
                    //                                 username: usernames[
                    //                                     visiblePlatforms[index++]],
                    //                                 size: width / 5,
                    //                                 context: context),
                    //                       ]);
                    //                 },
                    //                 itemCount: (visiblePlatforms.length / 3).ceil(),
                    //               )
                    //             : Center(
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(15),
                    //                   child: Text(
                    //                     "This user isn't currently sharing any social media platforms :(",
                    //                     style: Constants.CustomCyan,
                    //                   ),
                    //                 ),
                    //               ),
                    //       ),
                    //       ElevatedButton(
                    //           onPressed: () async {
                    //             if (isFriendAdded) {
                    //               // do nothing
                    //             } else {
                    //               // reset index to avoid invalid index on refresh
                    //               index = 0;
                    //               setState(() {
                    //                 isFriendAdded = true;
                    //               });
                    //               // add friend, update button, refresh screen
                    //               await LocalDataService.addFriend(
                    //                   friendsoshiUsername: soshiUsername);
                    //               databaseService.addFriend(
                    //                   friendsoshiUsername: soshiUsername);
                    //               refreshScreen();
                    //             }
                    //           },
                    //           style: ElevatedButton.styleFrom(
                    //               primary: isFriendAdded
                    //                   ? Colors.white
                    //                   : Color(0xFF181818)),
                    //           child: Container(
                    //             width: 150.0,
                    //             child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: (isFriendAdded)
                    //                     ? [
                    //                         Text(
                    //                           "Connected",
                    //                           style: TextStyle(
                    //                               fontSize: 20.0,
                    //                               fontWeight: FontWeight.bold,
                    //                               color: Colors.black),
                    //                         ),
                    //                         Padding(
                    //                             padding:
                    //                                 EdgeInsets.only(left: 5.0)),
                    //                         Icon(
                    //                           Icons.verified_user,
                    //                           color: Colors.green,
                    //                         )
                    //                       ]
                    //                     : [
                    //                         Text(
                    //                           "Connect",
                    //                           style: TextStyle(
                    //                               fontSize: 20.0,
                    //                               fontWeight: FontWeight.bold,
                    //                               color: Colors.cyan[300]),
                    //                         ),
                    //                         Padding(
                    //                             padding:
                    //                                 EdgeInsets.only(left: 5.0)),
                    //                         Icon(
                    //                           Icons.add_circle,
                    //                           color: Colors.cyan[300],
                    //                         )
                    //                       ]),
                    //           )),
                    //       // Row(
                    //       //   mainAxisAlignment: MainAxisAlignment.end,
                    //       //   children: [
                    //       //     Padding(
                    //       //       padding: const EdgeInsets.all(8.0),
                    //       //       child: FloatingActionButton(
                    //       //           backgroundColor: Colors.cyan[400],
                    //       //           onPressed: () => Navigator.pop(context),
                    //       //           child: Icon(FlutterIcons.check_circle_faw,
                    //       //               size: width / 10)),
                    //       //     ),
                    //       //   ],
                    //       // )
                    //     ]),
                    //   ),
                    //   Positioned(
                    //       left: width / 2 - width / 3,
                    //       right: width / 2 - width / 3,
                    //       child:
                    //           ProfilePic(url: profilePhotoURL, radius: width / 6)),
                    // ]);
                  }),
                )),
          );
        });
  }

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
}

void displayNameErrorPopUp(String firstOrLast, BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40.0))),
          // backgroundColor: Colors.blueGrey[900],
          title: Text(
            "Error",
            style:
                TextStyle(color: Colors.cyan[600], fontWeight: FontWeight.bold),
          ),
          content: Text(
            ("$firstOrLast name must be between 1 and 12 characters"),
            style: TextStyle(
                //color: Colors.cyan[700],
                fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
