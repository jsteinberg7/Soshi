import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:soshi/screens/login/newIntroFlowSri.dart';
import 'package:soshi/screens/mainapp/profileSettings.dart';
import 'package:soshi/screens/mainapp/resetPassword.dart';
import 'package:soshi/services/auth.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/constants/utilities.dart';

import '../../services/url.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({Key key}) : super(key: key);

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    String soshiUsername = LocalDataService.getLocalUsernameForPlatform("Soshi");
    DatabaseService dbService = new DatabaseService(currSoshiUsernameIn: soshiUsername);

    bool isVerified = LocalDataService.getVerifiedStatus();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 0,
        title: Container(
          width: width / 2,
          child: Text(
            "Settings",
            style: TextStyle(
              // color: Colors.cyan[200],
              letterSpacing: 1,
              fontSize: width / 18,
              fontWeight: FontWeight.bold,
              //fontStyle: FontStyle.italic
            ),
          ),
        ),
        automaticallyImplyLeading: false,

        actions: [
          Padding(
            padding: EdgeInsets.only(right: width / 150),
            child: TextButton(
              style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
              child: Text(
                "Done",
                style: TextStyle(color: Colors.blue, fontSize: width / 23),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
        elevation: .5,

        // backgroundColor: Colors.grey[850],
        centerTitle: false,
      ),
      body: Scaffold(
          body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(width / 25, height / 60, width / 25, 0),
          child: Stack(children: [
            Positioned(
              //top: 20,
              //left: 30,
              child: ProfilePic(radius: height / 17, url: LocalDataService.getLocalProfilePictureURL()),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,

                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: height / 8,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          LocalDataService.getLocalFirstName() + " " + LocalDataService.getLocalLastName(),
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: width / 19,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: 5),
                      SoshiUsernameText(soshiUsername, fontSize: width / 26, isVerified: isVerified),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, height / 100, 0, 0),
                        child: Divider(
                            indent: 0,
                            endIndent: 0,
                            color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return Scaffold(body: ProfileSettings());
                          }));
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, height / 100, 0, height / 80),
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Account",
                                  style: TextStyle(fontSize: width / 23),
                                ),
                                Spacer(),
                                Icon(CupertinoIcons.forward)
                              ]),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          URL.launchURL("sms:" + "5713351885");
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, height / 60, 0, height / 80),
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Send Feedback",
                                  style: TextStyle(fontSize: width / 23),
                                ),
                                Spacer(),
                                Icon(CupertinoIcons.forward)
                              ]),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final InAppReview inAppReview = InAppReview.instance;

                          inAppReview.openStoreListing(appStoreId: '1595515750');
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, height / 60, 0, height / 80),
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Rate Soshi",
                                  style: TextStyle(fontSize: width / 23),
                                ),
                                Spacer(),
                                Icon(CupertinoIcons.forward)
                              ]),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return Scaffold(body: ResetPassword());
                          }));
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, height / 60, 0, height / 80),
                          child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Reset Password",
                                  style: TextStyle(fontSize: width / 23),
                                ),
                                Spacer(),
                                Icon(CupertinoIcons.forward)
                              ]),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    //bottom: ,
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        AuthService authService = new AuthService();

                        CustomAlertDialog.showCustomAlertDialog(
                            "Sign out", "Are you sure you want to sign out?", "Yes", "No", () async {
                          await authService.signOut();
                          Navigator.pop(context); // close popup
                          // Navigator.pop(context); // pop to login screen
                          //        Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => MainApp()),
                          // );
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => NewIntroFlow())));
                        }, () {
                          Navigator.pop(context);
                        }, context);

                        // showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       return AlertDialog(
                        //         shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.all(
                        //                 Radius.circular(40.0))),
                        //         // backgroundColor: Colors.blueGrey[900],
                        //         title: Text(
                        //           "Sign Out",
                        //           style: TextStyle(
                        //             // color: Colors.cyan[600],
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //         content: Text(
                        //           ("Are you sure you want to sign out?"),
                        //           style: TextStyle(
                        //             fontSize: 20,
                        //             // color: Colors.cyan[700],
                        //             // fontWeight: FontWeight.bold
                        //           ),
                        //         ),
                        //         actions: <Widget>[
                        //           Row(
                        //             mainAxisAlignment:
                        //                 MainAxisAlignment.spaceEvenly,
                        //             children: <Widget>[
                        //               TextButton(
                        //                 child: Text(
                        //                   'No',
                        //                   style: TextStyle(
                        //                       fontSize: 20, color: Colors.red),
                        //                 ),
                        //                 onPressed: () {
                        //                   Navigator.pop(context);
                        //                 },
                        //               ),
                        //               TextButton(
                        //                 child: Text(
                        //                   'Yes',
                        //                   style: TextStyle(
                        //                       fontSize: 20, color: Colors.blue),
                        //                 ),
                        //                 onPressed: () async {
                        //                   await authService.signOut();
                        //                   Navigator.pop(context); // close popup
                        //                   // Navigator.pop(context); // pop to login screen
                        //                   //        Navigator.push(
                        //                   //   context,
                        //                   //   MaterialPageRoute(builder: (context) => MainApp()),
                        //                   // );
                        //                   Navigator.pushReplacement(
                        //                       context,
                        //                       MaterialPageRoute(
                        //                           builder: ((context) =>
                        //                               NewIntroFlow())));
                        //                 },
                        //               ),
                        //             ],
                        //           ),
                        //         ],
                        //       );
                        //     });
                      },
                      label: Text(
                        "Sign out",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                ]),
          ]),
        ),
      )),
    );
  }
}
