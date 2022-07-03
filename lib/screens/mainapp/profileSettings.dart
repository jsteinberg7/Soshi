//import 'dart:html';
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

/* 
* Widget allows users to access their profile settings 
* (name, password, etc) 
*/
class ProfileSettings extends StatefulWidget {
  String soshiUsername;
  Function refreshProfileScreen;

  ProfileSettings({String soshiUsername, Function refreshProfile}) {
    this.soshiUsername = soshiUsername;
    this.refreshProfileScreen = refreshProfile;
  }
  @override
  ProfileSettingsState createState() => ProfileSettingsState();
}

class ProfileSettingsState extends State<ProfileSettings> {
  String soshiUsername;
  DatabaseService databaseService;
  int connectionCount = 0;

  Function refreshProfileScreen;
  // bool twoWaySharingSwitch;
  bool isVerified;

  void refreshProfileSettings() {
    setState(() {});
  }

  void initState() {
    super.initState();
    soshiUsername = widget.soshiUsername;
    refreshProfileScreen = widget.refreshProfileScreen;
    databaseService = new DatabaseService(currSoshiUsernameIn: soshiUsername);
    // twoWaySharingSwitch = LocalDataService.getTwoWaySharing() ?? true;
    isVerified = LocalDataService.getVerifiedStatus();
  }

  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController bioController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    firstNameController.text = LocalDataService.getLocalFirstName();
    lastNameController.text = LocalDataService.getLocalLastName();
    bioController.text = LocalDataService.getBio();

    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");
    DatabaseService dbService =
        new DatabaseService(currSoshiUsernameIn: soshiUsername);

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
                LocalDataService.updateFirstName(
                    firstNameController.text.trim());
                LocalDataService.updateLastName(lastNameController.text.trim());

                dbService.updateDisplayName(
                    firstNameParam: firstNameController.text.trim(),
                    lastNameParam: lastNameController.text.trim());

                LocalDataService.updateBio(bioController.text);
                databaseService.updateBio(
                    LocalDataService.getLocalUsernameForPlatform("Soshi"),
                    bioController.text);

                // Checking if this is first time adding a bio
                // if it is, it gives Soshi points
                if (LocalDataService.getInjectionFlag("Bio") == false ||
                    LocalDataService.getInjectionFlag("Bio") == null) {
                  LocalDataService.updateInjectionFlag("Bio", true);
                  databaseService.updateInjectionSwitch(
                      soshiUsername, "Bio", true);
                  LocalDataService.updateSoshiPoints(10);
                  databaseService.updateSoshiPoints(soshiUsername, 10);
                }

                Navigator.pop(context);
              },
            ),
          )
        ],
        elevation: 10,
        shadowColor: Colors.cyan,
        title: Text(
          "Edit Profile",
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

      resizeToAvoidBottomInset: false,

      // backgroundColor: Colors.grey[900],

      // floatingActionButton:

      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(width / 25, height / 50, width / 25, 0),
            child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      DatabaseService dbService = new DatabaseService();
                      //dbService.chooseAndCropImage();

                      // update profile picture on tap
                      // open up image picker
                      final ImagePicker imagePicker = ImagePicker();
                      final PickedFile pickedImage = await imagePicker.getImage(
                          source: ImageSource.gallery, imageQuality: 20);
                      await dbService.cropAndUploadImage(pickedImage);

                      // Checking if this is first time adding a profile pic
                      // if it is, it gives Soshi points
                      if (LocalDataService.getInjectionFlag("Profile Pic") ==
                              false ||
                          LocalDataService.getInjectionFlag("Profile Pic") ==
                              null) {
                        LocalDataService.updateInjectionFlag(
                            "Profile Pic", true);
                        dbService.updateInjectionSwitch(
                            soshiUsername, "Profile Pic", true);
                        databaseService.updateSoshiPoints(soshiUsername, 10);
                        LocalDataService.updateSoshiPoints(10);
                      }

                      //refreshScreen();
                    },
                    child: Stack(
                      children: [
                        ProfilePic(
                            radius: 55,
                            url: LocalDataService.getLocalProfilePictureURL()),
                        Positioned(
                          right: width / 15,
                          top: height / 30,
                          child: Container(
                            padding: EdgeInsets.all(width / 100),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent),
                            child: Icon(
                              Icons.edit,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height / 100,
                  ),
                  Divider(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "First Name",
                        style: TextStyle(fontSize: width / 23),
                      ),
                      SizedBox(
                        width: width / 15,
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none, counterText: ""),
                          controller: firstNameController,
                          maxLines: 1,
                          maxLength: 12,
                          onSubmitted: (String firstName) {
                            // LocalDataService.updateFirstName(
                            //     firstNameController.text.trim());
                            // LocalDataService.updateLastName(
                            //     lastNameController.text.trim());

                            // dbService.updateDisplayName(
                            //     firstNameParam: firstNameController.text.trim(),
                            //     lastNameParam: lastNameController.text.trim());
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Last Name",
                        style: TextStyle(fontSize: width / 23),
                      ),
                      SizedBox(
                        width: width / 15,
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none, counterText: ""),
                          controller: lastNameController,
                          maxLines: 1,
                          maxLength: 12,
                          onSubmitted: (String lastName) {
                            LocalDataService.updateFirstName(
                                firstNameController.text.trim());
                            LocalDataService.updateLastName(
                                lastNameController.text.trim());

                            dbService.updateDisplayName(
                                firstNameParam: firstNameController.text.trim(),
                                lastNameParam: lastNameController.text.trim());
                          },
                        ),
                      ),
                    ],
                  ),

                  Divider(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white),

                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(0, height / 60, 0, height / 60),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Username",
                          style: TextStyle(fontSize: width / 23),
                        ),
                        SizedBox(
                          width: width / 15,
                        ),
                        Row(
                          children: [
                            Text(
                              "@ ",
                              style: TextStyle(
                                  fontSize: width / 25,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                            Text(
                              LocalDataService.getLocalUsername(),
                              style: TextStyle(
                                fontSize: width / 25,
                                fontStyle: FontStyle.italic,
                                //color: Colors.grey
                              ),
                            ),
                            isVerified == false || isVerified == null
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.only(left: width / 100),
                                    child: Image.asset(
                                      "assets/images/Verified.png",
                                      scale: width / 22,
                                    ),
                                  )
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white),

                  Row(
                    children: [
                      Text(
                        "Bio",
                        style: TextStyle(fontSize: width / 23),
                      ),
                      SizedBox(
                        width: width / 4.5,
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          controller: bioController,
                          maxLines: 2,
                          maxLength: 40,
                          //maxLengthEnforcement: MaxLengthEnforcement.none,
                          onSubmitted: (String bio) {
                            LocalDataService.updateBio(bio);
                            databaseService.updateBio(
                                LocalDataService.getLocalUsernameForPlatform(
                                    "Soshi"),
                                bio);

                            // Checking if this is first time adding a bio
                            // if it is, it gives Soshi points
                            if (LocalDataService.getInjectionFlag("Bio") ==
                                    false ||
                                LocalDataService.getInjectionFlag("Bio") ==
                                    null) {
                              LocalDataService.updateInjectionFlag("Bio", true);
                              databaseService.updateInjectionSwitch(
                                  soshiUsername, "Bio", true);

                              LocalDataService.updateSoshiPoints(10);
                              databaseService.updateSoshiPoints(
                                  soshiUsername, 10);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white),

                  GestureDetector(
                    onTap: () {
                      print("Go to passions page");
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(0, height / 60, 0, height / 60),
                      child: Row(children: [
                        Text(
                          "Passions",
                          style: TextStyle(fontSize: width / 23),
                        ),
                        SizedBox(
                          width: width / 10,
                        ),
                        Expanded(
                          child: Text(
                            "Basketball, Programming, Partying",
                            style: TextStyle(
                              fontSize: width / 25,
                              overflow: TextOverflow.fade,
                            ),
                            softWrap: false,
                          ),
                        ),
                        Icon(Icons.arrow_right_sharp)
                      ]),
                    ),
                  ),
                  Divider(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white),
                  SizedBox(
                    height: height / 15,
                  ),
                  ActivatePortalButton(),
                  SizedBox(
                    height: height / 30,
                  ),

                  SignOutButton()

                  // Center(
                  //   child: ProfilePic(
                  //     radius: width / 8.0,
                  //     url: LocalDataService.getLocalProfilePictureURL(),
                  //   ),
                  // ),

                  // Constants.makeBlueShadowButton(
                  //     "Edit Profile Picture", Icons.edit, () async {
                  //   DatabaseService dbService = new DatabaseService();
                  //   //dbService.chooseAndCropImage();

                  //   // update profile picture on tap
                  //   // open up image picker
                  //   final ImagePicker imagePicker = ImagePicker();
                  //   final PickedFile pickedImage = await imagePicker.getImage(
                  //       source: ImageSource.gallery, imageQuality: 20);
                  //   await dbService.cropAndUploadImage(pickedImage);
                  //   refreshProfileSettings(); // force refresh
                  //   refreshProfileScreen();

                  // String soshiUsername =
                  //     LocalDataService.getLocalUsernameForPlatform("Soshi");
                  // // send image to website based on URL
                  // DatabaseService databaseService =
                  //     new DatabaseService(soshiUsernameIn: soshiUsername);
                  // await databaseService.uploadProfilePicture(pickedImage);
                  // String URL = await FirebaseStorage.instance
                  //     .ref()
                  //     .child("Profile Pictures/" + soshiUsername)
                  //     .getDownloadURL();
                  // await LocalDataService.updateLocalPhotoURL(URL);
                  // databaseService.updateUserProfilePictureURL(URL);
                  // }),

                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //       elevation: 7.0,
                  //       shadowColor: Colors.cyan,
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: new BorderRadius.circular(30))),

                  //   // style: RoundedRectangleBorder(
                  //   //   borderRadius: BorderRadius.circular(30.0),
                  //   // ),
                  //   // color: Colors.grey[850],
                  //   // splashColor: Colors.grey[800],
                  //   onPressed: ,
                  //   child: Center(
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: <Widget>[
                  //         Text(
                  //           'Edit Profile Picture',
                  //           style: TextStyle(
                  //             fontSize: width / 25,
                  //             // color: Colors.cyan[300],
                  //             letterSpacing: 2,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //         SizedBox(width: width / 60),
                  //         Icon(
                  //           Icons.mode_edit,
                  //           size: height / 40,
                  //           // color: Colors.blueGrey,
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Row(
                  //   children: <Widget>[
                  //     Text(
                  //       'Name',
                  //       style: TextStyle(
                  //         //color: Colors.grey,
                  //         letterSpacing: 2,
                  //       ),
                  //     ),
                  // DisplayNameTextFields()
                  //   ],
                  // ),
                  // // SizedBox(height: height / 80),
                  // DisplayNameTextFields(),
                  // // SizedBox(height: height / 50),

                  // Divider(
                  //     height: height / 30,
                  //     color: Theme.of(context).brightness == Brightness.light
                  //         ? Colors.black
                  //         : Colors.white
                  //     //color: Colors.blueGrey
                  //     ),

                  // Stack(children: [
                  //   Row(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         'Username',
                  //         style: TextStyle(
                  //           //color: Colors.grey,
                  //           letterSpacing: 2,
                  //         ),
                  //       ),
                  //       Row(
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: [
                  //             Text(
                  //               "@" +
                  //                   LocalDataService
                  //                       .getLocalUsernameForPlatform("Soshi"),
                  //               //"Soshi username",
                  //               style: TextStyle(
                  //                 // color: Colors.cyan[300],
                  //                 letterSpacing: 2,
                  //                 //fontSize: width / 20,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //             SizedBox(width: width / 45),
                  //             isVerified == null || isVerified == false
                  //                 ? Container()
                  //                 : Image.asset(
                  //                     "assets/images/Verified.png",
                  //                     scale: width / 30,
                  //                   )
                  //           ]),
                  //     ],
                  //   ),
                  // ]),

                  //SizedBox(height: height / 50),
                  // Row(
                  //   children: [
                  //     Text(
                  //       'Two-Way Sharing',
                  //       style: TextStyle(
                  //           //color: Colors.grey,
                  //           letterSpacing: 2,
                  //           fontSize: 15),
                  //     ),
                  //     ElevatedButton(
                  //       child: Icon(
                  //         Icons.question_mark_sharp,
                  //         size: 20,
                  //       ),
                  //       onPressed: () {
                  //         Popups.twoWarSharingExplained(context, width, height);
                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         elevation: 7,
                  //         shadowColor: Colors.cyan,
                  //         fixedSize: Size(width / 50, height / 50),
                  //         shape: const CircleBorder(),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  //SizedBox(height: height / 100),
                  // Row(children: [
                  //   Icon(Icons.person),
                  //   Transform.scale(
                  //     scaleY: .9,
                  //     scaleX: .9,
                  //     child: CupertinoSwitch(
                  //         value: twoWaySharingSwitch,
                  //         activeColor: Colors.cyan[500],
                  //         onChanged: (bool value) {
                  //           setState(() {
                  //             twoWaySharingSwitch = value;
                  //           });
                  //           LocalDataService.updateTwoWaySharing(value);
                  //           databaseService.updateTwoWaySharing(value);
                  //         }),
                  //   ),

                  //   Icon(Icons.people),
                  //   // SizedBox(width: width / 45),
                  // ]),
                  // SizedBox(height: height / 50),
                  // Text(
                  //   'Password',
                  //   style: TextStyle(
                  //     //color: Colors.grey,
                  //     letterSpacing: 2,
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: height / 100,
                  // ),
                  // Row(
                  //   children: <Widget>[
                  //     Icon(
                  //       Icons.lock,
                  //       color: Theme.of(context).brightness == Brightness.light
                  //           ? Colors.black
                  //           : Colors.white,
                  //     ),
                  //     Padding(
                  //       padding: EdgeInsets.fromLTRB(width / 25, 0, 0, 0),
                  //       child: Container(
                  //         width: 220,
                  //         child: Constants.makeBlueShadowButton(
                  //             "Forgot Password?", null, () {
                  //           Navigator.push(context,
                  //               MaterialPageRoute(builder: (context) {
                  //             return ResetPassword();
                  //           }));
                  //         }),
                  //       ),

                  //       // child: ElevatedButton(
                  //       //   style: ElevatedButton.styleFrom(
                  //       //     elevation: 7,
                  //       //     shadowColor: Colors.cyan,
                  //       //     shape: RoundedRectangleBorder(
                  //       //       borderRadius: BorderRadius.circular(20.0),
                  //       //     ),
                  //       //     // color: Colors.grey[850],
                  //       //   ),
                  //       //   onPressed: () {
                  //       //     Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //       //       return ResetPassword();
                  //       //     }));
                  //       //   },
                  //       //   child: Row(
                  //       //     children: <Widget>[
                  //       //       Text(
                  //       //         "Forgot Password?",
                  //       //         style: TextStyle(
                  //       //           fontSize: width / 30,
                  //       //           // color: Colors.cyan[300],
                  //       //           fontWeight: FontWeight.bold,
                  //       //         ),
                  //       //       ),
                  //       //     ],
                  //       //   ),
                  //       // ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: height / 50),
                  // Icon(Icons.email_outlined,

                  //     // color: Colors.grey,
                  //     size: 25),
                  // SizedBox(height: height / 100),
                  // Text(
                  //   Provider.of<User>(context, listen: false).email,
                  //   style: TextStyle(
                  //     // color: Colors.cyan[300],
                  //     letterSpacing: 2.0,
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: height / 30),
                  // Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: <Widget>[
                  //       SizedBox(
                  //         width: 5,
                  //       ),
                  //       // DeleteProfileButton(),
                  //       Padding(
                  //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 15.0),
                  //         child: Constants.makeBlueShadowButton(
                  //             "Activate Portal", Icons.tap_and_play, () async {
                  //           showModalBottomSheet(
                  //               constraints: BoxConstraints(
                  //                   minWidth: width / 1.1,
                  //                   maxWidth: width / 1.1),
                  //               backgroundColor: Colors.transparent,
                  //               context: context,
                  //               builder: (BuildContext context) {
                  //                 return NFCWriter(height, width);
                  //               });
                  //         }),
                  //       ),

                  //                     SignOutButton(),
                ]),
          ),
        ),
      ),
    );
  }
}
