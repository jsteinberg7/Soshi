import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/screens/mainapp/passions.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/utilities.dart';

/* 
* Widget allows users to access their profile settings 
* (name, password, etc) 
*/
class ProfileSettings extends StatefulWidget {
  ValueNotifier importProfileNotifier;
  ProfileSettings({this.importProfileNotifier});

  @override
  ProfileSettingsState createState() => ProfileSettingsState();
}

class ProfileSettingsState extends State<ProfileSettings> {
  SoshiUser user;
  File image;
  String tempNewURL;

  loadDataEngine() async {
    print("🌐 GLOBAL USER loading data engine inside profileSettings");
    if (tempNewURL == null) {
      tempNewURL = DataEngine.globalUser.photoURL;
    }
    // this.user = await DataEngine.getUserObject(firebaseOverride: false);
    this.user = DataEngine.globalUser;
    log(user.toString());
  }

  Future pickImage() async {
    try {
      final profilePic =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      final profilePicTemp = File(profilePic.path);

      if (profilePic == null) {
        return tempNewURL;
      } else {
        await cropAndUploadImage(profilePicTemp);
      }
    } on PlatformException catch (e) {
      print("failed to pick image: $e");
    }
  }

  Future<CroppedFile> cropImage(String path,
      {CropStyle cropStyle = CropStyle.circle}) async {
    return (await ImageCropper().cropImage(
      cropStyle: cropStyle,
      sourcePath: path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 700,
      maxWidth: 700,
      compressFormat: ImageCompressFormat.jpg,
    ));
  }

  Future<void> cropAndUploadImage(
    File passedInImage,
  ) async {
    if (passedInImage != null) {
      CroppedFile croppedImageFirst = await cropImage(passedInImage.path);
      final File croppedImageFinal = File(croppedImageFirst.path);
      DialogBuilder(context).showLoadingIndicator();
      await FirebaseStorage.instance
          .ref()
          .child("Profile Pictures/" + user.soshiUsername)
          .putFile(croppedImageFinal);

      // upload image to firebase to get URL
      String urlNew = await FirebaseStorage.instance
          .ref()
          .child("Profile Pictures/" + user.soshiUsername)
          .getDownloadURL();

      setState(() => tempNewURL = urlNew);
      DialogBuilder(context).hideOpenDialog();

      print("after setstate");
    } else {
      print("No image picked");
      return;
    }
  }

  TextEditingController testController;

  Widget build(BuildContext context) {
    print("🌐 GLOBAL USER loading data engine inside profileSettings");
    if (tempNewURL == null) {
      tempNewURL = DataEngine.globalUser.photoURL;
    }
    // this.user = await DataEngine.getUserObject(firebaseOverride: false);
    this.user = DataEngine.globalUser;
    log(user.toString());

    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    // DatabaseService dbService = new DatabaseService(currSoshiUsernameIn: this.user.soshiUsername);
    return Scaffold(
      appBar: AppBar(
        leading: CupertinoBackButton(
          onPressed: () {
            print("verify discard changes?");
            CustomAlertDialogDoubleChoice.showCustomAlertDialogDoubleChoice(
                "Unsaved Changes",
                "Unsaved changes will be discarded",
                "Yes",
                "No", () {
              Navigator.pop(context);
              Navigator.pop(context);
            }, () {
              Navigator.pop(context);
            }, context, height, width);
          },
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
                  fontSize: width / 23,
                ),
              ),
              onPressed: () async {
                user.photoURL = tempNewURL;
                DataEngine.applyUserChanges(
                    user: DataEngine.globalUser, cloud: true, local: true);
                // Need alternative to refresh the profile!!!!
                Navigator.pop(context);
              },
            ),
          )
        ],
        elevation: .5,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            letterSpacing: 0,
            fontSize: width / 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: Container(

          // return Text(user.toString());
          child: SafeArea(
              child: Padding(
        padding: EdgeInsets.fromLTRB(width / 40, height / 50, width / 40, 0),
        child: SingleChildScrollView(
          child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    pickImage();

                    // await imagePicker.getImage(
                    //     source: ImageSource.gallery,
                    //     imageQuality: 20);

                    //await dbService.cropAndUploadImage(pickedImage);
                  },
                  child: Stack(
                    children: [
                      ProfilePic(radius: 55, url: tempNewURL),
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
                Divider(),
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
                      child: TextFormField(
                        style: TextStyle(fontSize: width / 23),
                        decoration: InputDecoration(
                            border: InputBorder.none, counterText: ""),
                        controller: DataEngine.globalUser.firstNameController,
                        //this.user.firstNameController,
                        maxLines: 1,
                        maxLength: 12,
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Last Name",
                      style: TextStyle(
                          fontSize: width / 23, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: width / 15,
                    ),
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(fontSize: width / 23),
                        decoration: InputDecoration(
                            border: InputBorder.none, counterText: ""),
                        controller: DataEngine.globalUser.lastNameController,
                        maxLines: 1,
                        maxLength: 12,
                      ),
                    ),
                  ],
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, height / 60, 0, height / 60),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Username",
                        style: TextStyle(
                            fontSize: width / 23, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: width / 15,
                      ),
                      Row(
                        children: [
                          Text(
                            "@ ",
                            style: TextStyle(
                                fontSize: width / 23, color: Colors.grey),
                          ),
                          Text(
                            this.user.soshiUsername,
                            style: TextStyle(
                                fontSize: width / 23, color: Colors.grey
                                //color: Colors.grey
                                ),
                          ),
                          user.verified == false || user.verified == null
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.only(left: 3),
                                  child: Image.asset(
                                    "assets/images/misc/verified.png",
                                    scale: width / 22,
                                  ),
                                )
                        ],
                      )
                    ],
                  ),
                ),
                Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height / 65),
                      child: Text(
                        "Bio",
                        style: TextStyle(
                            fontSize: width / 23, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: width / 4.5,
                    ),
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(fontSize: width / 23),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        controller: user.bioController,
                        maxLines: 3,
                        maxLength: 80,
                      ),
                    ),
                  ],
                ),
                Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: height / 65, bottom: height / 65),
                    child: Text(
                      "Passions",
                      style: TextStyle(
                          fontSize: width / 23, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                PassionTileList(
                    profileScreenRefresher: widget.importProfileNotifier),
                Divider(),
                SizedBox(
                  height: height / 15,
                )
              ]),
        ),
      ))),
    );
  }
}
