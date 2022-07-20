//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soshi/screens/mainapp/passions.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/utilities.dart';

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
        leading: IconButton(
          onPressed: () {
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
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: width / 20,
                ),
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
        elevation: 0,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            // color: Colors.cyan[200],
            letterSpacing: 0,
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
                EdgeInsets.fromLTRB(width / 40, height / 50, width / 40, 0),
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
                              color: Colors.black,
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
                        style: TextStyle(
                            fontSize: width / 23, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: width / 15,
                      ),
                      Expanded(
                        child: TextField(
                          // keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                              border: InputBorder.none, counterText: ""),
                          controller: firstNameController,

                          maxLines: 1,
                          maxLength: 12,
                          onSubmitted: (String firstName) {},
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
                                  //fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                            Text(
                              LocalDataService.getLocalUsername(),
                              style: TextStyle(
                                fontSize: width / 25,
                                //ontStyle: FontStyle.italic,
                                //color: Colors.grey
                              ),
                            ),
                            isVerified == false || isVerified == null
                                ? Container()
                                : Padding(
                                    padding: EdgeInsets.only(left: 3),
                                    child: Image.asset(
                                      "assets/images/Verified.png",
                                      scale: width / 25,
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
                          // keyboardType: TextInputType.,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          controller: bioController,
                          maxLines: 3,
                          maxLength: 80,
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
                  PassionTileList(),
                  Divider(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white),
                  SizedBox(
                    height: height / 15,
                  ),
                  SignOutButton()
                ]),
          ),
        ),
      ),
    );
  }
}
