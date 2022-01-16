import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soshi/constants/constants.dart';
import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/services/contacts.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/services/url.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chooseSocials.dart';
import 'profileSettings.dart';
import 'package:http/http.dart' as http;

/*
A social media card used in the profile (one card per platform)
*/
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
  String soshiUsername, platformName, hintText = "Username";
  // used to store local state of switch
  bool isSwitched;
  TextEditingController usernameController = new TextEditingController();
  FocusNode focusNode;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    soshiUsername = widget.soshiUsername;
    platformName = widget.platformName;
    if (platformName == "Phone") {
      hintText = "Phone Number";
    } else if (platformName == "Linkedin" ||
        platformName == "Facebook" ||
        platformName == "Tiktok") {
      hintText = "Link to Profile";
    } else {
      hintText = "Username";
    }
    databaseService = new DatabaseService(
        currSoshiUsernameIn: soshiUsername); // store ref to databaseService
    isSwitched = LocalDataService.getLocalStateForPlatform(platformName) ??
        false; // track state of platform switch
    usernameController.text =
        LocalDataService.getLocalUsernameForPlatform(platformName) ?? null;
    focusNode = new FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        if (usernameController.text.length > 3) {
          // turn on switch if username is not empty (say, at least 3 chars)
          if (!isSwitched) {
            setState(() {
              isSwitched = true;
            });
            LocalDataService.updateSwitchForPlatform(
                platform: platformName, state: true);
            databaseService.updatePlatformSwitch(
                platform: platformName, state: true);
          }
        }
        LocalDataService.updateUsernameForPlatform(
            platform: platformName, username: usernameController.text);
        databaseService.updateUsernameForPlatform(
            platform: platformName, username: usernameController.text);
      }
    });

    double height = Utilities.getHeight(context);
    //double width = Utilities.getWidth(context);
    // text controller for username box

    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: (isSwitched == true)
                  ? BorderSide(color: Colors.blueGrey)
                  : BorderSide.none),
          elevation: 10,

          color: Colors.grey[850],

          //Colors.grey[850],
          child: Container(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
            child: Row(
              children: <Widget>[
                Switch(
                    activeThumbImage:
                        AssetImage('assets/images/SoshiLogos/soshi_icon.png'),
                    inactiveThumbImage: AssetImage(
                        'assets/images/SoshiLogos/soshi_icon_marble.png'),
                    value: isSwitched,
                    activeColor: Colors.cyan[500],
                    onChanged: (bool value) {
                      setState(() {
                        isSwitched = value;
                      });
                      LocalDataService.updateSwitchForPlatform(
                          platform: platformName, state: value);
                      databaseService.updatePlatformSwitch(
                          platform: platformName, state: value);

                      if (LocalDataService.getFirstSwitchTap()) {
                        LocalDataService.updateFirstSwitchTap(false);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(40.0))),
                                backgroundColor: Colors.blueGrey[900],
                                title: Text(
                                  "Platform Switches",
                                  style: TextStyle(
                                      color: Colors.cyan[600],
                                      fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  ("These switches control what platform(s) you are sharing. "),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.cyan[700],
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
                    }),
                Material(
                  color: Colors.transparent,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: IconButton(
                    splashColor: Colors.cyan[300],
                    splashRadius: Utilities.getWidth(context) / 11,
                    icon: Image.asset(
                      'assets/images/SMLogos/' + platformName + 'Logo.png',
                    ),
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
                              .load("assets/images/SoshiLogos/soshi_icon.png");
                          profilePicBytes = data.buffer.asUint8List();
                        }
                        Contact contact = new Contact(
                            givenName: firstName,
                            familyName: lastName,
                            emails: [
                              Item(
                                label: "Email",
                                value: LocalDataService
                                    .getLocalUsernameForPlatform("Email"),
                              ),
                            ],
                            phones: [
                              Item(
                                  label: "Cell",
                                  value: LocalDataService
                                      .getLocalUsernameForPlatform("Phone")),
                            ],
                            avatar: profilePicBytes);
                        await askPermissions(context);
                        ContactsService.openContactForm();
                        // ContactsService.addContact(contact)
                        //     .then((dynamic success) {
                        //   Popups.showContactAddedPopup(
                        //       context, width, firstName, lastName);
                        // });
                      } else {
                        await launch(
                            URL.getPlatformURL(
                                platform: platformName,
                                username: LocalDataService
                                    .getLocalUsernameForPlatform(platformName)),
                            universalLinksOnly: true,
                            forceWebView: false);
                        // URL.launchURL(URL.getPlatformURL(
                        //     platform: platformName,
                        //     username:
                        //         LocalDataService.getLocalUsernameForPlatform(
                        //             platformName)));

                      }
                    },
                    iconSize: 60.0,
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: usernameController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[800]),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan),
                      ), //border: Inp
                      hintText: hintText,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        //fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      //fontWeight: FontWeight.bold,
                      color: Colors.grey[50],
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 35),
                )
              ],
            ),
          )),
        ),
        Visibility(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSwitched = true;
                });
                LocalDataService.updateSwitchForPlatform(
                    platform: platformName, state: true);
                databaseService.updatePlatformSwitch(
                    platform: platformName, state: true);
              },
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    height: Utilities.getHeight(context) / 10,
                    child: Row(
                      children: [Expanded(child: Text(""))],
                    ),
                  ),
                  color: Colors.black26),
            ),
            visible: !isSwitched),
        Padding(
          padding: EdgeInsets.only(top: height / 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 30,
                    color: Colors.grey[200],
                  ),
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60.0)),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: TextButton(
                          child: Text(
                            "Remove $platformName",
                            style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (!LocalDataService.getLocalChoosePlatforms()
                                .contains(platformName)) {
                              Navigator.pop(context);

                              await LocalDataService.removePlatformsFromProfile(
                                  platformName);
                              LocalDataService.addToChoosePlatforms(
                                  platformName);

                              LocalDataService.updateSwitchForPlatform(
                                  platform: platformName, state: false);
                              databaseService.updatePlatformSwitch(
                                  platform: platformName, state: false);
                              databaseService
                                  .removePlatformFromProfile(platformName);
                              databaseService
                                  .addToChoosePlatforms(platformName);
                              print(LocalDataService.getLocalProfilePlatforms()
                                  .toString());
                              widget.refreshScreen();
                            } else {
                              Navigator.pop(context);
                              await LocalDataService.removePlatformsFromProfile(
                                  platformName);
                              widget.refreshScreen();
                            }
                          },
                        ),
                      )
                    ];
                  }),
            ],
          ),
        )
      ],
    );
  }
}

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  refreshScreen() {
    setState(() {
      profilePlatforms = LocalDataService.getLocalProfilePlatforms();
    });
  }

  String soshiUsername;
  List profilePlatforms;
  FocusNode bioFocusNode;
  TextEditingController personalBioTextController;
  @override
  void initState() {
    super.initState();
    soshiUsername = LocalDataService.getLocalUsernameForPlatform("Soshi");
    profilePlatforms = LocalDataService.getLocalProfilePlatforms();

    //TextEditingController psBioControl = new TextEditingController();
    //ersonalBioTextController.text = LocalDataService.getBio();
    bioFocusNode = new FocusNode();
    bioFocusNode.addListener(() {
      if (!bioFocusNode.hasFocus) {
        //This whole block is NOT being exeuted when lost focus
        LocalDataService.updateBio(personalBioTextController.text);
        print(LocalDataService.getBio().toString());
        DatabaseService tempDB = new DatabaseService();
        tempDB.updateBio(LocalDataService.getLocalUsernameForPlatform("Soshi"),
            personalBioTextController.text);
        print("123456789" + LocalDataService.getBio());
      }
    });
  }

  // @override
  // void setFocus() {
  //   FocusScope.of(context).requestFocus(bioFocusNode);
  // }

  // @override
  // void dispose() {
  //   bioFocusNode.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);
    TextEditingController personalBioTextController =
        new TextEditingController();
    personalBioTextController.text = LocalDataService.getBio();

    return SingleChildScrollView(
      child: Container(
        child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    Column(
                      children: [
                        Container(
                          child: GestureDetector(
                            onTap: () async {
                              DatabaseService dbService = new DatabaseService();
                              //dbService.chooseAndCropImage();

                              // update profile picture on tap
                              // open up image picker
                              final ImagePicker imagePicker = ImagePicker();
                              final PickedFile pickedImage =
                                  await imagePicker.getImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 20);
                              await dbService.cropAndUploadImage(pickedImage);
                              refreshScreen();

                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (context) {
                              //   return Scaffold(
                              //       body: ProfileSettings(
                              //           soshiUsername: soshiUsername,
                              //           refreshProfile: refreshScreen));
                              // }));
                            },
                            child: Stack(
                              children: [
                                ProfilePic(
                                    radius: 55,
                                    url: LocalDataService
                                        .getLocalProfilePictureURL()),
                                Positioned(
                                    bottom: width / 100,
                                    right: width / 100,
                                    child: Container(
                                      padding: EdgeInsets.all(width / 100),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[850]),
                                      child: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Colors.cyan,
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          // child: ProfilePic(
                          //     radius: 55,
                          //     url:
                          //         LocalDataService.getLocalProfilePictureURL()),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            border: new Border.all(
                              color: Colors.cyanAccent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Scaffold(
                                  body: ProfileSettings(
                                      soshiUsername: soshiUsername,
                                      refreshProfile: refreshScreen));
                            }));
                          },
                          style: Constants.ButtonStyleDark,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Edit Profile",
                                  style: TextStyle(
                                    color: Colors.cyan[300],
                                    //fontWeight: FontWeight.bold,
                                    //letterSpacing: 1,
                                  )),
                              SizedBox(width: 4.0),
                              Icon(Icons.person_rounded,
                                  color: Colors.cyan[300], size: 20.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 160,
                        child: Container(
                          child: TextField(
                              //focusNode: bioFocusNode,
                              maxLength: 80,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              maxLines: 6,
                              autocorrect: true,
                              controller: personalBioTextController,

                              //focusNode: bioFocusNode,
                              // onTap: () {
                              // if (LocalDataService.getBio() == "") {
                              //   DatabaseService tempDB =
                              //       new DatabaseService();
                              //   tempDB.updateBio(
                              //       LocalDataService
                              //           .getLocalUsernameForPlatform("Soshi"),
                              //       "");
                              // }
                              //},
                              onSubmitted: (String bio) {
                                DatabaseService tempDB = new DatabaseService();

                                LocalDataService.updateBio(bio);
                                tempDB.updateBio(
                                    LocalDataService
                                        .getLocalUsernameForPlatform("Soshi"),
                                    bio);
                                //update in database
                                //update in sharedPref

                                // ProfanityFilter profanityFilter =
                                //     new ProfanityFilter();
                                // if (!prof1234nityFilter.hasProfanity(bio)) {
                                //   //upload to database
                                //   //update sharedPreferences
                                // } else {
                                //   List<String> profanityWords =
                                //       profanityFilter.getAllProfanity(bio);
                                //   //alert dialog accusing user of using profanity
                                //   // also print the list of word(s) being detected as profanity
                                // }
                              },
                              style: TextStyle(
                                  height: 1.2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 1.5),
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                    color: Colors.cyan[300],
                                  ),
                                ),
                                labelStyle: TextStyle(
                                    color: Colors.cyanAccent, fontSize: 20),
                                labelText: 'Bio',

                                hintText: "Enter your bio!",

                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 15),
                                // labelText: "Personal Bio"
                              )),
                        ),
                      ),
                    )
                  ]),
                  SizedBox(height: 5),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[],
                  ),
                  Divider(
                    color: Colors.cyan[300],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Toggle',
                        style: TextStyle(
                          color: Colors.grey,
                          letterSpacing: 2,
                        ),
                      ),
                      ElevatedButton(
                        child: Icon(
                          Icons.help,
                          size: 30,
                          color: Colors.grey[900],
                        ),
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(35, 35),
                            primary: Colors.blueGrey[500],
                            shape: CircleBorder()),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(40.0))),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
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
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        primary:
                                                            Colors.blueGrey,
                                                        shadowColor: Constants
                                                            .buttonColorDark,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        15.0)))),
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
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
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
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        primary:
                                                            Colors.blueGrey,
                                                        shadowColor: Constants
                                                            .buttonColorDark,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        15.0)))),
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
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
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
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        primary:
                                                            Colors.blueGrey,
                                                        shadowColor: Constants
                                                            .buttonColorDark,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        15.0)))),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
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
                                              padding: const EdgeInsets.only(
                                                  top: 12.0),
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
                                );
                              });
                        },
                      ),
                      // SizedBox(
                      //   width: width / 12,
                      // ),
                    ],
                  ),
                  Container(
                    child: (profilePlatforms == null ||
                            profilePlatforms.isEmpty == true)
                        ? Column(
                            children: <Widget>[
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Add your platforms!",
                                    style: TextStyle(
                                      color: Colors.cyan[300],
                                      fontSize: 25,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: 3.0,
                                      //fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 30,
                                    color: Colors.cyan[100],
                                  ),
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 30,
                                    color: Colors.cyan[300],
                                  ),
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 30,
                                    color: Colors.cyan[700],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                            ],
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: SMCard(
                                    platformName: profilePlatforms[index],
                                    soshiUsername: soshiUsername,
                                    refreshScreen: refreshScreen),
                              );
                            },
                            itemCount: profilePlatforms.length),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50, 10, 50, 40),
                    child: ElevatedButton(
                      onPressed: () async {
                        // check if user has all platforms (in case of update)
                        if (Constants.originalPlatforms.length +
                                Constants.addedPlatforms.length >
                            LocalDataService.getLocalChoosePlatforms().length +
                                LocalDataService.getLocalProfilePlatforms()
                                    .length) {
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          // HORRIBLE STYLE, REDO THIS
                          return Scaffold(
                              body: ChooseSocials(
                            refreshFunction: refreshScreen,
                          ));
                        }));
                      },
                      style: Constants.ButtonStyleDark,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            child: Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.cyan[300],
                              size: 30,
                            ),
                          ),
                          Text('Add Platforms!',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.cyan[300],
                                  letterSpacing: 3.0,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  )
                ])),
      ),
    );
  }
}
