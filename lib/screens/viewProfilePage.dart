import 'dart:typed_data';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
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

import 'package:glassmorphism/glassmorphism.dart';

import '../constants/constants.dart';
import '../services/contacts.dart';
import 'mainapp/friendScreen.dart';
import 'package:http/http.dart' as http;



// class ViewProfilePage extends StatefulWidget {
//   ViewProfilePage(
//       {String friendSoshiUsername, Friend friend, Function refreshScreen});

//   @override
//   State<ViewProfilePage> createState() => _ViewProfilePageState();
// }

// class _ViewProfilePageState extends State<ViewProfilePage> {


//   String friendSoshiUsername;

//   Friend friend; 

//   Function refreshScreen;

//   @override
//   Widget build(BuildContext context) {
//     String userUsername = LocalDataService.getLocalUsername();
//   // get list of all visible platforms
//   DatabaseService databaseService = new DatabaseService(
//       currSoshiUsernameIn: LocalDataService.getLocalUsername());

//   Map userData = await databaseService.getUserFile(friendSoshiUsername);

//   List<String> visiblePlatforms;
//   Map<String, dynamic> usernames;
//   bool isContactEnabled;

//   if (friend == null) {
//     // DYNAMIC SHARING if no friend data passed in
//     visiblePlatforms = await databaseService.getEnabledPlatformsList(userData);
//     // get list of profile usernames
//     usernames = databaseService.getUserProfileNames(userData);
//   } else {
//     // STATIC SHARING
//     visiblePlatforms = friend.enabledUsernames.keys.toList();
//     usernames = friend.enabledUsernames;
//   }

//   if (visiblePlatforms.contains("Contact")) {
//     visiblePlatforms.remove("Contact");
//     isContactEnabled = true;
//   } else {
//     isContactEnabled = false;
//   }

//   double popupHeightDivisor;
//   //double innerContainerSizeDivisor;

//   String fullName = databaseService.getFullName(userData);
//   bool isFriendAdded = LocalDataService.isFriendAdded(friendSoshiUsername);
//   String profilePhotoURL = databaseService.getPhotoURL(userData);
//   String bio = databaseService.getBio(userData);
//   bool isVerified = databaseService.getVerifiedStatus(userData);
//   int soshiPoints = databaseService.getSoshiPoints(userData);

//   double height = MediaQuery.of(context).size.height;
//   double width = MediaQuery.of(context).size.width;

//   int numfriends = userData["Friends"].length;
//   String numFriendsString = numfriends.toString();

//   int numGroups; // need groups injection for this to work
//   String numGroupsString = "15";
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(25.0),
//                   child: Image.network(
//                     (friend.photoURL != "null"
//                         ? friend.photoURL
//                         : "https://img.freepik.com/free-photo/abstract-luxury-plain-blur-grey-black-gradient-used-as-background-studio-wall-display-your-products_1258-58170.jpg?w=2000"),
//                     fit: BoxFit.fill,
//                     height: height / 2.5,
//                     width: width,
//                   ),
//                 ),
//                 GlassmorphicContainer(
//                   height: height / 2.5,
//                   width: width,
//                   borderRadius: 25.0,
//                   blur: 10,
//                   alignment: Alignment.bottomCenter,
//                   border: 2,
//                   linearGradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Color(0xFFffffff).withOpacity(0.8),
//                         Color(0xFFFFFFFF).withOpacity(0.4),
//                       ],
//                       stops: [
//                         0.1,
//                         1,
//                       ]),
//                   borderGradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Color(0xFFffffff).withOpacity(0.5),
//                       Color((0xFFFFFFFF)).withOpacity(0.5),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(width / 40),
//                     child: Column(
//                       children: [
//                         Stack(children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: <Widget>[
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(
//                                     width / 10, height / 30, width / 10, 0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     IconButton(
//                                         onPressed: () {
//                                           Navigator.pop(context);
//                                         },
//                                         icon: Icon(
//                                             Icons.arrow_back_ios_new_rounded)),
//                                     Column(
//                                       children: [
//                                         Text(
//                                           fullName,
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: width / 16,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           height: height / 170,
//                                         ),
//                                         Row(
//                                           children: [
//                                             Text("@" + friendSoshiUsername,
//                                                 style: TextStyle(
//                                                     fontSize: width / 22,
//                                                     fontStyle: FontStyle.italic,
//                                                     letterSpacing: 1.2)),
//                                             SizedBox(
//                                               width: 3,
//                                             ),
//                                             isVerified == null ||
//                                                     isVerified == false
//                                                 ? Container()
//                                                 : Image.asset(
//                                                     "assets/images/Verified.png",
//                                                     scale: width / 22,
//                                                   )
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                     IconButton(
//                                         color: Colors.transparent,
//                                         icon: Icon(Icons
//                                             .arrow_back_ios_new_rounded)), // for balancing
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ]),
//                         SizedBox(
//                           height: height / 60,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Column(children: [
//                               Text(
//                                 numFriendsString.toString(),
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: width / 25,
//                                     letterSpacing: 1.2),
//                               ),
//                               numFriendsString == "1"
//                                   ? Text(
//                                       "Friend",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: width / 25,
//                                           letterSpacing: 1.2),
//                                     )
//                                   : Text(
//                                       "Friends",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: width / 25,
//                                           letterSpacing: 1.2),
//                                     )
//                             ]),
//                             ProfilePic(radius: 60, url: profilePhotoURL),
//                             Column(children: [
//                               Text(
//                                 numGroupsString,
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: width / 25,
//                                     letterSpacing: 1.2),
//                               ),
//                               numGroupsString == "1"
//                                   ? Text("Group",
//                                       style: TextStyle(
//                                           fontSize: width / 25,
//                                           fontWeight: FontWeight.bold,
//                                           letterSpacing: 1.2))
//                                   : Text("Groups",
//                                       style: TextStyle(
//                                           fontSize: width / 25,
//                                           fontWeight: FontWeight.bold,
//                                           letterSpacing: 1.2))
//                             ]),
//                           ],
//                         ),
//                         //SizedBox(height: height / 1),
//                         Padding(
//                             padding: EdgeInsets.fromLTRB(
//                                 width / 6, height / 70, width / 6, height / 80),
//                             child: Container(
//                                 child: //Padding(
//                                     //padding: EdgeInsets.fromLTRB(width / 5, 0, width / 5, 0),
//                                     //child:
//                                     (bio != null)
//                                         ? Text(bio,
//                                             textAlign: TextAlign.center,
//                                             style:
//                                                 TextStyle(fontSize: width / 25
//                                                     // color: Colors.grey[300],
//                                                     ))
//                                         : Container())
//                             //),
//                             ),
//                         // SizedBox(
//                         //   height: height / 150,
//                         // ),

//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               CupertinoIcons.bolt,
//                               size: 25,
//                             ),
//                             Text(
//                               soshiPoints == null
//                                   ? "0 bolts"
//                                   : soshiPoints.toString() + " bolts",
//                               style: TextStyle(
//                                   fontStyle: FontStyle.italic,
//                                   fontSize: width / 25),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Stack(children: [
//           //   Padding(
//           //     padding: EdgeInsets.fromLTRB(
//           //         width / 25, height / 140, width / 25, 0),
//           //     child: Divider(
//           //       color: Colors.grey,
//           //     ),
//           //   ),
//           //   Row(
//           //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           //     children: [
//           //       Container(
//           //         decoration: BoxDecoration(
//           //             // color: Colors.grey[850],
//           //             border: Border.all(
//           //               color: Colors.red,
//           //             ),
//           //             borderRadius: BorderRadius.all(Radius.circular(5))),

//           //         child: Padding(
//           //           padding: EdgeInsets.all(3.0),
//           //           child: Text("Basketball"),
//           //         ),

//           //         //color: Colors.white,
//           //       ),
//           //       Container(
//           //         decoration: BoxDecoration(
//           //             color: Colors.grey[850],
//           //             border: Border.all(
//           //               color: Colors.green,
//           //             ),
//           //             borderRadius: BorderRadius.all(Radius.circular(5))),
//           //         child: Padding(
//           //           padding: const EdgeInsets.all(3.0),
//           //           child: Text("Contact Exchange"),
//           //         ),
//           //       ),
//           //       Container(
//           //         decoration: BoxDecoration(
//           //             color: Colors.grey[850],
//           //             border: Border.all(
//           //               color: Colors.blue,
//           //             ),
//           //             borderRadius: BorderRadius.all(Radius.circular(5))),
//           //         child: Padding(
//           //             padding: const EdgeInsets.all(3.0),
//           //             child: Text("Programming")),
//           //       )
//           //     ],
//           //   ),
//           // ]),
//           Positioned(
//             top: height / 2.6,
//             left: 0,
//             right: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                   color: Theme.of(context).scaffoldBackgroundColor,
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(20.0),
//                       topRight: Radius.circular(20.0))),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.fromLTRB(
//                         width / 25, height / 65, width / 25, height / 125),
//                     child: Text(
//                       "Socials",
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: width / 20),
//                     ),
//                   ),
//                   Center(
//                     child: (visiblePlatforms == null ||
//                             visiblePlatforms.isEmpty == true)
//                         ? Center(
//                             child: Padding(
//                               padding: const EdgeInsets.all(15),
//                               child: Text(
//                                 "This user isn't currently sharing any social media platforms :(",
//                                 style: Constants.CustomCyan,
//                               ),
//                             ),
//                           )
//                         : SizedBox(
//                             height: height / 3,
//                             width: width / 1.2,
//                             child: GridView.builder(
//                               physics: const NeverScrollableScrollPhysics(),
//                               shrinkWrap: true,
//                               itemBuilder: (BuildContext context, int i) {
//                                 return Padding(
//                                     padding:
//                                         const EdgeInsets.fromLTRB(0, 0, 0, 10),
//                                     child: Popups.createSMButton(
//                                         soshiUsername: friendSoshiUsername,
//                                         platform: visiblePlatforms[i],
//                                         username:
//                                             usernames[visiblePlatforms[i]],
//                                         size: width / 15,
//                                         context: context));
//                               },
//                               itemCount: visiblePlatforms.length,
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 4,
//                                       childAspectRatio: .9,
//                                       crossAxisSpacing: width / 60),
//                             ),
//                           ),
//                   ),
//                   Padding(
//                     padding:
//                         EdgeInsets.fromLTRB(0, height / 30, 0, height / 20),
//                     child: Center(
//                       child: Visibility(
//                         // visible: isContactEnabled,
//                         visible: false,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             DialogBuilder(context).showLoadingIndicator();

//                             double width = MediaQuery.of(context).size.width;
//                             // DatabaseService databaseService =
//                             //     new DatabaseService(currSoshiUsernameIn: soshiUsername);
//                             // Map userData = await databaseService.getUserFile(soshiUsername);

//                             String firstName = await databaseService
//                                 .getFirstDisplayName(userData);
//                             String lastName =
//                                 databaseService.getLastDisplayName(userData);
//                             String email =
//                                 await databaseService.getUsernameForPlatform(
//                                     platform: "Email", userData: userData);
//                             String phoneNumber =
//                                 await databaseService.getUsernameForPlatform(
//                                     platform: "Phone", userData: userData);
//                             String photoUrl =
//                                 databaseService.getPhotoURL(userData);

//                             Uint8List profilePicBytes;

//                             try {
//                               // try to load profile pic from url
//                               await http
//                                   .get(Uri.parse(photoUrl))
//                                   .then((http.Response response) {
//                                 profilePicBytes = response.bodyBytes;
//                               });
//                             } catch (e) {
//                               // if url is invalid, use default profile pic
//                               ByteData data = await rootBundle.load(
//                                   "assets/images/SoshiLogos/soshi_icon.png");
//                               profilePicBytes = data.buffer.asUint8List();
//                             }
//                             Contact newContact = new Contact(
//                                 givenName: firstName,
//                                 familyName: lastName,
//                                 emails: [
//                                   Item(label: "Email", value: email),
//                                 ],
//                                 phones: [
//                                   Item(label: "Cell", value: phoneNumber),
//                                 ],
//                                 avatar: profilePicBytes);
//                             await askPermissions(context);

//                             await ContactsService.addContact(newContact);

//                             DialogBuilder(context).hideOpenDialog();

//                             Popups.showContactAddedPopup(
//                                 context, width, firstName, lastName);

//                             //ContactsService.openContactForm();
//                             // ContactsService.addContact(newContact).then((dynamic success) {
//                             // });
//                             //         ContactsService.addContact(newContact).then(dynamic success)
//                             // {             ContactsService.openExistingContact(newContact);
//                             //       };

//                             // .then((dynamic success) {
//                             //   Popups.showContactAddedPopup(context, width, firstName, lastName);
//                             // });
//                           },
//                           child: Container(
//                             height: height / 22,
//                             width: width / 2,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Image.asset(
//                                   "assets/images/SMLogos/ContactLogo.png",
//                                   //width: width / 10
//                                   //height: height / 5,
//                                 ),
//                                 Text(
//                                   "Add To Contacts + ",
//                                   style: TextStyle(
//                                       fontFamily: "Montserrat",
//                                       fontSize: width / 25,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             shadowColor: Colors.black,
//                             primary: Colors.white.withOpacity(0.6),
//                             // side: BorderSide(color: Colors.cyan[400]!, width: 2),
//                             elevation: 20,
//                             padding: const EdgeInsets.all(15.0),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
