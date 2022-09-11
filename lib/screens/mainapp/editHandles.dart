import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:soshi/screens/mainapp/chooseSocials.dart';
import 'package:soshi/services/dataEngine.dart';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/utilities.dart';

import '../../constants/popups.dart';

import 'package:contacts_service/contacts_service.dart';

import 'package:soshi/constants/popups.dart';
import 'package:soshi/services/contacts.dart';
import 'package:soshi/services/url.dart';
import 'chooseSocials.dart';
import 'package:http/http.dart' as http;

class EditHandles extends StatefulWidget {
  ValueNotifier editHandleMasterControl;
  ValueNotifier profileMasterControl;

  EditHandles({@required this.editHandleMasterControl, @required this.profileMasterControl});

  @override
  State<EditHandles> createState() => _EditHandlesState();
}

class _EditHandlesState extends State<EditHandles> {
  List<Social> chosenPlatforms;
  SoshiUser user;

  loadUserEditHandles() async {
    user = await DataEngine.getUserObject(firebaseOverride: false);
    chosenPlatforms = user.getChosenPlatforms();
  }

  @override
  Widget build(BuildContext context) {
    print("🔃 rebuilding EditHandles Now 🔃");
    // soshiUsername = LocalDataService.getLocalUsername();
    // chosenPlatforms = widget.user.getChosenPlatforms();
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    return Scaffold(
      appBar: AppBar(
        leading: CupertinoBackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: width / 150),
            child: TextButton(
              style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
              child: Text(
                "Done",
                style: TextStyle(color: Colors.blue, fontSize: width / 23),
              ),
              onPressed: () async {
                await DataEngine.applyUserChanges(user: user, cloud: true, local: true);
                widget.profileMasterControl.notifyListeners();

                Navigator.pop(context);
              },
            ),
          )
        ],
        elevation: .5,
        title: Text(
          "My Platforms",
          style: TextStyle(
            letterSpacing: 1,
            fontSize: width / 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: loadUserEditHandles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator.adaptive());
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(width / 40, height / 50, width / 40, 0),
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: EdgeInsets.fromLTRB(50, 0, 50, 0)),
                    child: Text(
                      "Add",
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: width / 20, color: Colors.white),
                    ),
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return Scaffold(
                            body: ChooseSocials(
                          user: user,
                        ));
                      })).then((value) {
                        setState(() {});
                      });
                    },
                  ),
                  Container(
                    child: (chosenPlatforms == null || chosenPlatforms.isEmpty == true)
                        ? Container()
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              print("building SMCard index: ${index} with name: ${chosenPlatforms[index]}");
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: SMCard(
                                    platformSocial: chosenPlatforms[index], user: user, importEditHandlesController: widget.editHandleMasterControl),
                              );
                            },
                            itemCount: chosenPlatforms.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 3.35,
                            ),
                          ),
                  ),
                ]),
              ),
            );
          }),
    );
  }
}

class SMCard extends StatefulWidget {
  Social platformSocial;
  SoshiUser user;
  ValueNotifier importEditHandlesController;

  SMCard({@required this.user, @required this.platformSocial, @required this.importEditHandlesController});

  @override
  _SMCardState createState() => _SMCardState();
}

class _SMCardState extends State<SMCard> {
  String soshiUsername, platformName, hintText = "Username", indicator;
  bool isSwitched;
  TextEditingController usernameController;

  FocusNode focusNode;

  @override
  void initState() {
    // soshiUsername = widget.user.soshiUsername;
    platformName = widget.platformSocial.platformName;
    isSwitched = widget.platformSocial.switchStatus;
    usernameController = widget.platformSocial.usernameController;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (platformName == "Phone") {
      hintText = "Phone Number";
      indicator = "#";
    } else if (platformName == "Linkedin" ||
        platformName == "Facebook" ||
        platformName == "Spotify" ||
        platformName == "Youtube" ||
        platformName == "AppleMusic") {
      hintText = "Link to Profile";
      indicator = "URL";
    } else if (platformName == "Personal") {
      hintText = "Link";
      indicator = "URL";
    } else if (platformName == "Cryptowallet") {
      hintText = "Wallet address";
      indicator = "##";
    } else {
      hintText = "Username";
      indicator = "@";
    }

    // usernameController.text = widget.platformSocial.username;

    if (platformName == "Contact") {
      usernameController.text = "Contact Card";
    }

    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    return Stack(
      children: [
        Card(
          // color: Colors.grey[200],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(
                  color: Colors.transparent,
                  // Theme.of(context).brightness == Brightness.light
                  //     ? Colors.white
                  //     : Colors.grey[850],
                  width: 3.0)),
          elevation: 2,
          child: Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: InkWell(
                    onTap: () async {
                      if (platformName == "Contact") {
                        double width = Utilities.getWidth(context);
                        String firstName = DataEngine.globalUser.firstName;

                        String lastName = DataEngine.globalUser.lastName;
                        String photoUrl = DataEngine.globalUser.photoURL;
                        String email = DataEngine.globalUser.getUsernameGivenPlatform(platform: "Email");
                        String phoneNumber = DataEngine.globalUser.getUsernameGivenPlatform(platform: "Phone");

                        Uint8List profilePicBytes;
                        try {
                          // try to load profile pic from url
                          await http.get(Uri.parse(photoUrl)).then((http.Response response) {
                            profilePicBytes = response.bodyBytes;
                          });
                        } catch (e) {
                          // if url is invalid, use default profile pic
                          ByteData data = await rootBundle.load("assets/images/misc/default_pic.png");
                          profilePicBytes = data.buffer.asUint8List();
                        }
                        Contact contact = new Contact(
                            givenName: firstName,
                            familyName: lastName,
                            emails: [
                              Item(
                                label: "Email",
                                value: email
                              ),
                            ],
                            phones: [
                              Item(label: "Cell", value: phoneNumber),
                            ],
                            avatar: profilePicBytes);
                        await askPermissions(context);
                        ContactsService.addContact(contact).then((dynamic success) {
                          Popups.showContactAddedPopup(context, width, photoUrl, firstName, lastName, phoneNumber, email);
                        });
                      } else if (platformName == "Cryptowallet") {
                        Clipboard.setData(ClipboardData(
                          text: DataEngine.globalUser.getUsernameGivenPlatform(platform: "Cryptowallet")
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                            'Wallet address copied to clipboard!',
                            textAlign: TextAlign.center,
                          ),
                        ));
                      } else {
                        URL.launchURL(
                            URL.getPlatformURL(platform: platformName, username: DataEngine.globalUser.getUsernameGivenPlatform(platform: platformName)));
                      }
                    },
                    child: Image.asset(
                      'assets/images/SMLogos/' + platformName + 'Logo.png',
                    ),
                  ),
                ),
              ),
              platformName != "Contact"
                  ? Text(indicator, style: TextStyle(fontSize: width / 25, color: Colors.grey))
                  : Text(
                      "  ",
                    ),
              platformName != "Contact"
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(0, height / 35, 0, height / 35),
                      child: VerticalDivider(thickness: 1.5, color: Colors.grey),
                    )
                  : Container(),
              Container(
                child: Expanded(
                    child: platformName != "Contact"
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: TextField(
                              keyboardType:
                                  platformName == "Phone" ? TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
                              inputFormatters: platformName == "Phone" ? [FilteringTextInputFormatter.digitsOnly] : null,
                              style: TextStyle(fontSize: width / 20, letterSpacing: 1.3),
                              // scribbleEnabled: true,
                              cursorColor: Colors.blue,
                              decoration: InputDecoration(
                                  hintText: hintText, hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none, counterText: ""),
                              controller: usernameController,
                              maxLines: 1,
                            ),
                          )
                        : TextField(
                            style: TextStyle(fontSize: width / 20),
                            decoration: InputDecoration(border: InputBorder.none, counterText: ""),
                            controller: usernameController,
                            maxLines: 1,
                            readOnly: true, // so user cant edit their vcf link
                          )),
              ),
            ],
          )),
        ),
        Positioned(
            width: width / .55,
            height: height / 30,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                // backgroundColor: MaterialStateProperty.all(Colors.black)
              ),
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                      minWidth: width / 1.1,
                      maxWidth: width / 1.1,
                    ),
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: height / 4.85,
                        color: Colors.transparent,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ListTile(
                                      title: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ListTile(
                                            title: Center(
                                              child: Text(
                                                "Remove " + platformName,
                                                style: TextStyle(fontSize: width / 20, color: Colors.red),
                                              ),
                                            ),
                                            onTap: () async {
                                              widget.user.removeFromProfile(platformName: widget.platformSocial.platformName);
                                              Navigator.pop(context);

                                              await DataEngine.applyUserChanges(user: widget.user, cloud: false, local: true);

                                              log(widget.user.toString());
                                              widget.importEditHandlesController.notifyListeners();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  title: Center(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(fontSize: width / 20, color: Colors.blue),
                                    ),
                                  ),
                                  onTap: () => Navigator.pop(context),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              child: Icon(
                Icons.remove,
                size: 20,
                color: Colors.red,
              ),
            )),
        platformName == "Contact"
            ? Positioned(
                width: width / .8,
                height: height / 30,
                top: height / 27,
                child: ElevatedButton(
                  style: ButtonStyle(
                      // backgroundColor: Theme.of(context).brightness ==
                      //                         Brightness.light
                      //                     ? Colors.white
                      //                     : Colors.black,
                      shape: MaterialStateProperty.all(CircleBorder()),
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? MaterialStateProperty.all(Colors.white)
                          : MaterialStateProperty.all(Colors.grey[850])),
                  onPressed: () {
                    Popups.contactCardExplainedPopup(context, width, height);
                  },
                  child: Icon(
                    Icons.question_mark,
                    size: 20,
                    // color: Colors.white,
                  ),
                ))
            : Container(),
      ],
    );
  }
}

// class GreenAddButton extends StatefulWidget {
//   Function() refreshScreen;
//   GreenAddButton({Function refreshScreen}) {
//     this.refreshScreen = refreshScreen;
//   }

//   @override
//   State<GreenAddButton> createState() => _GreenAddButtonState();
// }

// class _GreenAddButtonState extends State<GreenAddButton> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = Utilities.getWidth(context);
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//           elevation: 5,
//           primary: Colors.green,
//           shape: RoundedRectangleBorder(
//               //to set border radius to button
//               borderRadius: BorderRadius.circular(15)),
//           padding:
//               EdgeInsets.fromLTRB(50, 0, 50, 0) //content padding inside button

//           ),
//       child: Text(
//         "Add",
//         style: TextStyle(
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.5,
//             fontSize: width / 20,
//             color: Colors.white),
//       ),
//       onPressed: () async {
//         // check if user has all platforms (in case of update)
//         if (Constants.originalPlatforms.length +
//                 Constants.addedPlatforms.length >
//             LocalDataService.getLocalChoosePlatforms().length +
//                 LocalDataService.getLocalProfilePlatforms().length) {
//           // check which platforms need to be added
//           for (String platform in Constants.addedPlatforms) {
//             if (!LocalDataService.getLocalProfilePlatforms()
//                     .contains(platform) &&
//                 !LocalDataService.getLocalChoosePlatforms()
//                     .contains(platform)) {
//               await LocalDataService.addToChoosePlatforms(
//                   platform); // add new platform to choose platforms
//               await LocalDataService.updateSwitchForPlatform(
//                   platform: platform,
//                   state:
//                       false); // create switch for platform in and initialize to false
//               if (LocalDataService.getLocalUsernameForPlatform(platform) ==
//                   null) {
//                 await LocalDataService.updateUsernameForPlatform(
//                     platform: platform,
//                     username:
//                         ""); // create username mapping for platform if absent
//               }
//             }
//           }
//         }
//         await Navigator.push(context, MaterialPageRoute(builder: (context) {
//           return Scaffold(body: ChooseSocials());
//         }));
//       },
//     );
//   }
// }
