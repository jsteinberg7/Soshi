import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:vibration/vibration.dart';

import 'constants.dart';

/* Widget to build the profile picture and check if they are null */
class ProfilePic extends StatelessWidget {
  double radius;
  String url;

  ProfilePic({double radius, String url}) {
    this.radius = radius;
    this.url = url;
  }

  @override
  Widget build(BuildContext context) {
    // String url = LocalDataService.getLocalProfilePictureURL();

    return Container(
      child: CircleAvatar(
        radius: radius,
        backgroundImage: (url != null) && (url != "null")
            ? NetworkImage(url)
            : AssetImage('assets/images/SoshiLogos/soshi_icon.png'),
      ),
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        border: new Border.all(
          color: Colors.cyanAccent,
          width: .5,
        ),
      ),
    );
  }
}

/* Widget to build the display name textfields */
class DisplayNameTextFields extends StatefulWidget {
  @override
  _DisplayNameTextFieldsState createState() => _DisplayNameTextFieldsState();
}

class _DisplayNameTextFieldsState extends State<DisplayNameTextFields> {
  String firstName = LocalDataService.getLocalFirstName();
  String lastName = LocalDataService.getLocalLastName();
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");
    DatabaseService dbService =
        new DatabaseService(currSoshiUsernameIn: soshiUsername);
    firstNameController.text = firstName;
    lastNameController.text = lastName;

    return Row(children: <Widget>[
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            controller: firstNameController,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.cyan[300]),
            onSubmitted: (String text) {
              if (text.length > 0 && text.length <= 12) {
                LocalDataService.updateFirstName(firstNameController.text);

                dbService.updateDisplayName(
                    firstNameParam: firstNameController.text,
                    lastNameParam: lastName);
                //firstNameController.text = text;
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40.0))),
                        backgroundColor: Colors.blueGrey[900],
                        title: Text(
                          "Error",
                          style: TextStyle(
                              color: Colors.cyan[600],
                              fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          ("First name must be between 1 and 12 characters"),
                          style: TextStyle(
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
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[600],
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.cyan[300],
                ),
              ),
              prefixIcon: Icon(Icons.person, color: Colors.cyanAccent),
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              label: Text("First"),
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey[400]),
              fillColor: Colors.grey[850],
              hintText: "First Name",
              hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.cyan[300]),
            controller: lastNameController,
            onSubmitted: (String text) {
              if (text.length > 0 && text.length <= 12) {
                LocalDataService.updateLastName(lastNameController.text);
                dbService.updateDisplayName(
                    firstNameParam: firstName,
                    lastNameParam: lastNameController.text);
                //lastNameController.text = text;
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40.0))),
                        backgroundColor: Colors.blueGrey[900],
                        title: Text(
                          "Error",
                          style: TextStyle(
                              color: Colors.cyan[600],
                              fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          ("Last name must be between 1 and 12 characters"),
                          style: TextStyle(
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
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[600],
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.cyan[300],
                ),
              ),
              prefixIcon: Icon(Icons.person, color: Colors.cyanAccent),
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              label: Text("Last"),
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey[400]),
              fillColor: Colors.grey[850],
              hintText: "Last Name",
              hintStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ]);
  }
}

/* Widget to return the amount of connections someone has */
class ReturnNumConnections extends StatefulWidget {
  @override
  _ReturnNumConnectionsState createState() => _ReturnNumConnectionsState();
}

class _ReturnNumConnectionsState extends State<ReturnNumConnections> {
  int connectionsCount = LocalDataService.getFriendsListCount();
  @override
  Widget build(BuildContext context) {
    if (connectionsCount.toString() == "1") {
      return Text("1 friend",
          style: TextStyle(
            color: Colors.cyan[300],
            letterSpacing: 2.0,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ));
    }
    return Text(connectionsCount.toString() + " friends",
        style: TextStyle(
          color: Colors.cyan[300],
          letterSpacing: 2.0,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ));
  }
}

class ShareButton extends StatelessWidget {
  double size;
  String soshiUsername;

  ShareButton({this.size, this.soshiUsername});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Constants.buttonColorDark, shape: CircleBorder()),
      onPressed: () {
        Share.share("https://soshi.app/#/user/" + soshiUsername,
            subject: LocalDataService.getLocalFirstName() +
                " " +
                LocalDataService.getLocalLastName() +
                "'s Soshi Contact Card");
      },
      child: Icon(Icons.share, color: Colors.cyan[300], size: size),
    );
  }
}
