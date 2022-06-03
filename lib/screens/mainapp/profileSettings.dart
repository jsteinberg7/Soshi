//import 'dart:html';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/screens/mainapp/resetPassword.dart';
import 'package:soshi/services/auth.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/utilities.dart';

import '../../constants/popups.dart';
import '../../services/nfc.dart';

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

  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        shadowColor: Colors.cyan,
        title: Text(
          "Edit Profile",
          style: TextStyle(
              // color: Colors.cyan[200],
              fontSize: width / 15,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
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
                  EdgeInsets.fromLTRB(width / 20, height / 50, width / 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: ProfilePic(
                      radius: width / 8.0,
                      url: LocalDataService.getLocalProfilePictureURL(),
                    ),
                  ),
                  SizedBox(height: 15),

                  Constants.makeBlueShadowButton(
                      "Edit Profile Picture", Icons.edit, () async {
                    DatabaseService dbService = new DatabaseService();
                    //dbService.chooseAndCropImage();

                    // update profile picture on tap
                    // open up image picker
                    final ImagePicker imagePicker = ImagePicker();
                    final PickedFile pickedImage = await imagePicker.getImage(
                        source: ImageSource.gallery, imageQuality: 20);
                    await dbService.cropAndUploadImage(pickedImage);
                    refreshProfileSettings(); // force refresh
                    refreshProfileScreen();

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
                  }),

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
                  Divider(
                      height: height / 25,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white
                      //color: Colors.blueGrey
                      ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Display Name',
                        style: TextStyle(
                          //color: Colors.grey,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height / 80),
                  DisplayNameTextFields(),
                  SizedBox(height: height / 50),
                  Row(
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(
                          //color: Colors.grey,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height / 100),
                  Row(children: [
                    Text(
                      LocalDataService.getLocalUsernameForPlatform("Soshi"),
                      //"Soshi username",
                      style: TextStyle(
                        // color: Colors.cyan[300],
                        letterSpacing: 2,
                        fontSize: width / 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: width / 45),
                    isVerified == null || isVerified == false
                        ? Container()
                        : Image.asset(
                            "assets/images/Verified.png",
                            scale: width / 30,
                          )
                  ]),
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
                  SizedBox(height: height / 50),
                  Text(
                    'Password',
                    style: TextStyle(
                      //color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(
                    height: height / 100,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.lock,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(width / 25, 0, 0, 0),
                        child: Container(
                          width: 220,
                          child: Constants.makeBlueShadowButton(
                              "Forgot Password?", null, () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ResetPassword();
                            }));
                          }),
                        ),

                        // child: ElevatedButton(
                        //   style: ElevatedButton.styleFrom(
                        //     elevation: 7,
                        //     shadowColor: Colors.cyan,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(20.0),
                        //     ),
                        //     // color: Colors.grey[850],
                        //   ),
                        //   onPressed: () {
                        //     Navigator.push(context, MaterialPageRoute(builder: (context) {
                        //       return ResetPassword();
                        //     }));
                        //   },
                        //   child: Row(
                        //     children: <Widget>[
                        //       Text(
                        //         "Forgot Password?",
                        //         style: TextStyle(
                        //           fontSize: width / 30,
                        //           // color: Colors.cyan[300],
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                  SizedBox(height: height / 50),
                  Icon(Icons.email_outlined,

                      // color: Colors.grey,
                      size: 25),
                  SizedBox(height: height / 100),
                  Text(
                    Provider.of<User>(context, listen: false).email,
                    style: TextStyle(
                      // color: Colors.cyan[300],
                      letterSpacing: 2.0,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height / 30),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 5,
                        ),
                        // DeleteProfileButton(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15.0),
                          child: Constants.makeBlueShadowButton(
                              "Activate Portal", Icons.tap_and_play, () async {
                            showModalBottomSheet(
                                constraints: BoxConstraints(
                                    minWidth: width / 1.1,
                                    maxWidth: width / 1.1),
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return NFCWriter(height, width);
                                });
                          }),
                        ),

                        SignOutButton(),
                      ]),
                ],
              )),
        ),
      ),
    );
  }
}
