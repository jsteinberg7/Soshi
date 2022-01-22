//import 'dart:html';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:soshi/screens/mainapp/resetPassword.dart';
import 'package:soshi/services/auth.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/constants/widgets.dart';

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
  @override
  String soshiUsername;
  DatabaseService databaseService;
  int connectionCount = 0;

  Function refreshProfileScreen;

  void refreshProfileSettings() {
    setState(() {});
  }

  void initState() {
    super.initState();
    soshiUsername = widget.soshiUsername;
    refreshProfileScreen = widget.refreshProfileScreen;
    databaseService = new DatabaseService(currSoshiUsernameIn: soshiUsername);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
              color: Colors.cyan[200],
              fontSize: 25,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        backgroundColor: Colors.grey[850],
        centerTitle: true,
      ),

      resizeToAvoidBottomInset: false,

      backgroundColor: Colors.grey[900],

      // floatingActionButton:

      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: ProfilePic(
                      radius: 50.0,
                      url: LocalDataService.getLocalProfilePictureURL(),
                    ),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: Colors.grey[850],
                    splashColor: Colors.grey[800],
                    onPressed: () async {
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
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Edit Profile Picture',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.cyan[300],
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.mode_edit,
                            size: 15,
                            color: Colors.blueGrey,
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 40, color: Colors.blueGrey),
                  Row(
                    children: <Widget>[
                      Text(
                        'Display Name',
                        style: TextStyle(
                          color: Colors.grey,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  DisplayNameTextFields(),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(
                          color: Colors.grey,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    LocalDataService.getLocalUsernameForPlatform("Soshi"),
                    //"Soshi username",
                    style: TextStyle(
                      color: Colors.cyan[300],
                      letterSpacing: 2,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(Icons.lock, color: Colors.cyanAccent),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: Colors.grey[850],
                          splashColor: Colors.cyan,
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ResetPassword();
                            }));
                          },
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.cyan[300],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Icon(Icons.email_outlined, color: Colors.grey, size: 25),
                  SizedBox(height: 10),
                  Text(
                    Provider.of<User>(context, listen: false).email,
                    style: TextStyle(
                      color: Colors.cyan[300],
                      letterSpacing: 2.0,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 5,
                        ),
                        // DeleteProfileButton(),
                        SizedBox(
                          width: 0,
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

class DeleteProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 3, 3),
                child: Icon(
                  Icons.delete,
                  color: Colors.cyan,
                ),
              ),
              Text("Delete Account",
                  style: TextStyle(
                      color: Colors.cyan[300], fontWeight: FontWeight.bold)),
            ],
          ),
          onPressed: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40.0))),
                    backgroundColor: Colors.blueGrey[900],
                    title: Text(
                      "Delete Account",
                      style: TextStyle(
                        color: Colors.cyan[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      ("Are you sure you want to delete your profile? This cannot be undone."),
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.cyan[700],
                          fontWeight: FontWeight.bold),
                    ),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                            child: Text(
                              'No',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text(
                              'Yes',
                              style: TextStyle(fontSize: 20, color: Colors.red),
                            ),
                            onPressed: () async {
                              String soshiUsername =
                                  LocalDataService.getLocalUsername();
                              DatabaseService databaseService =
                                  new DatabaseService(
                                      currSoshiUsernameIn: soshiUsername);
                              await databaseService.deleteProfileData();

                              // wipe profile data in firestore
                              AuthService authService = new AuthService();
                              Navigator.of(context).pop();
                              await authService
                                  .deleteProfile(); // delete user account from firebase
                              LocalDataService
                                  .wipeSharedPreferences(); // clear local user data
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                });
          }),
    );
  }
}

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 3, 3),
            child: Icon(
              Icons.exit_to_app,
              color: Colors.cyan,
            ),
          ),
          Text("Sign out",
              style: TextStyle(
                  color: Colors.cyan[300], fontWeight: FontWeight.bold)),
        ],
      ),

      onPressed: () {
        AuthService authService = new AuthService();

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40.0))),
                backgroundColor: Colors.blueGrey[900],
                title: Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.cyan[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  ("Are you sure you want to sign out?"),
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.cyan[700],
                      fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextButton(
                        child: Text(
                          'No',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Yes',
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                        onPressed: () async {
                          await authService.signOut();
                          Navigator.pop(context); // close popup
                          Navigator.pop(context); // pop to login screen
                        },
                      ),
                    ],
                  ),
                ],
              );
            });
      },
      // icon: //Text("Sign out"),
      //     Icon(
      //   Icons.exit_to_app,
      //   color: Colors.cyan,
      // ),
      // elevation: 20,
      // backgroundColor: Colors.grey[850],
    );
  }
}
