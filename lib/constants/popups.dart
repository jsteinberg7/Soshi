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
    return IconButton(
      splashColor: Colors.cyan[300],
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
          String photoUrl = await databaseService.getPhotoURL(userData);

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
          URL.launchURL(
              URL.getPlatformURL(platform: platform, username: username));
        }
      },
      iconSize: size,
    );
  }

  static Future<dynamic> showContactAddedPopup(
      BuildContext context, double width, String firstName, String lastName) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            backgroundColor: Colors.grey[850],
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
                      color: Colors.white,
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
                backgroundColor: Colors.black,
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
                              padding: EdgeInsets.only(left: width / 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    fullName,
                                    style: TextStyle(
                                        fontSize: width / 23,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[200]),
                                  ),
                                  SizedBox(height: height / 120),
                                  Text(
                                    "@" + usernames["Soshi"],
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic),
                                  ),
                                  SizedBox(height: height / 170),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.emoji_people,
                                        color: Colors.cyan,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        "Friends: " + numFriendsString,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.grey[500],
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  )
                                ],
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
                                          color: Colors.grey[300],
                                        ))
                                    : Container()),
                          ),
                        ),
                        Divider(
                          color: Colors.blueGrey,
                          thickness: 2,
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
                              if (isFriendAdded) {
                                // do nothing
                              } else {
                                setState(() {
                                  isFriendAdded = true;
                                });
                                // add friend, update button, refresh screen
                                await LocalDataService.addFriend(
                                    friendsoshiUsername: friendSoshiUsername);
                                databaseService.addFriend(
                                    friendSoshiUsername: friendSoshiUsername);
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
                                primary: isFriendAdded
                                    ? Colors.white
                                    : Colors.transparent),
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
                                                color: Colors.black),
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
                backgroundColor: Colors.blueGrey[900],
                title: Text(
                  "Linking Social Media",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.cyan[600],
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
                          color: Colors.cyan[700],
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
                                  color: Colors.cyan[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueGrey,
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
                                  color: Colors.cyan[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueGrey,
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
                                  color: Colors.cyan[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueGrey,
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
                                color: Colors.cyan[700],
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
                                color: Colors.cyan[700],
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
          backgroundColor: Colors.blueGrey[900],
          title: Text(
            "Error",
            style:
                TextStyle(color: Colors.cyan[600], fontWeight: FontWeight.bold),
          ),
          content: Text(
            ("$firstOrLast name must be between 1 and 12 characters"),
            style:
                TextStyle(color: Colors.cyan[700], fontWeight: FontWeight.bold),
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