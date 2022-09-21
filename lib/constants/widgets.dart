import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:share/share.dart';
import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/screens/login/newIntroFlowSri.dart';
import 'package:soshi/services/auth.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:soshi/services/url.dart';
import '../screens/login/loading.dart';
import '../services/contacts.dart';
import '../services/nfc.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;

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
    return Container(
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        border: new Border.all(
          color: Colors.white,
          width: radius / 30,
        ),
      ),
      child: CircularProfileAvatar(
        url,
        placeHolder: (b, c) {
          return Image.asset('assets/images/misc/default_pic.png');
        },
        borderColor: Colors.white,
        borderWidth: radius / 40,
        elevation: 0,
        radius: radius,
      ),
    );

    // String url = LocalDataService.getLocalProfilePictureURL();

    //   return Container(
    //     child: CircleAvatar(
    //       backgroundColor: Colors.cyan,
    //       radius: radius,
    //       backgroundImage: (url != null) && (url != "null")
    //           ? NetworkImage(url)
    //           : AssetImage('assets/images/SoshiLogos/soshi_icon.png'),
    //     ),
    //     decoration: new BoxDecoration(
    //       shape: BoxShape.circle,
    //       border: new Border.all(
    //         color: Colors.cyanAccent,
    //         width: .5,
    //       ),
    //     ),
    //   );
  }
}

/* Widget to build the profile picture and check if they are null */
class RectangularProfilePic extends StatelessWidget {
  double customSize = 10.0;
  String url = "";
  bool defaultPic;
  File file;
  RectangularProfilePic(
      {@required double radius,
      @required String url,
      bool defaultPic = false,
      File file = null}) {
    this.customSize = radius;
    this.url = url;
    this.defaultPic = defaultPic;
    this.file = file;

    // print("received url +" + url.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
            // height: 110,
            // width: 110,
            height: customSize,
            width: customSize,
            child: (file == null)
                ? ((url == "null" || url == null || url == "")
                    ? Image.asset(
                        (defaultPic)
                            ? 'assets/images/misc/default_placeholder.png'
                            : 'assets/images/SoshiLogos/soshi_icon.png',
                        height: customSize,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        url,
                        height: customSize,
                        fit: BoxFit.cover,
                      ))
                : (Image.file(
                    file,
                    height: customSize,
                    fit: BoxFit.cover,
                  ))),
      ),
    );
  }
}

class CustomAlertDialogSingleChoice {
  static showCustomAlertDialogSingleChoice(
      String title,
      String message,
      String primaryText,
      Function primaryAction,
      BuildContext context,
      double height,
      double width) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0))),
            //backgroundColor: Colors.grey.shade800,
            // backgroundColor: Colors.blueGrey[900],
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                // color: Colors.cyan[600],
                fontWeight: FontWeight.bold,
                fontSize: width / 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width / 25,
                  ),
                ),
                SizedBox(height: height / 50),
                TextButton(
                    child: Text(
                      primaryText,
                      style: TextStyle(
                          fontSize: width / 25,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: primaryAction),
              ],
            ),
          );
        });
  }
}

class CustomAlertDialogDoubleChoice {
  static showCustomAlertDialogDoubleChoice(
      String title,
      String messageText,
      String primaryText,
      String secondaryText,
      Function primaryAction,
      Function secondaryAction,
      BuildContext context,
      double height,
      double width) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0))),
            //backgroundColor: Colors.grey.shade800,
            // backgroundColor: Colors.blueGrey[900],
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                // color: Colors.cyan[600],
                fontWeight: FontWeight.bold,
                fontSize: width / 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  messageText,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: height / 50,
                ),
                TextButton(
                    child: Text(
                      primaryText,
                      style: TextStyle(
                          fontSize: width / 25,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: primaryAction),
                Divider(),
                TextButton(
                    child: Text(
                      secondaryText,
                      style: TextStyle(
                          fontSize: width / 25,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: secondaryAction),
              ],
            ),
          );
        });
  }
}

class CustomAlertDialogDoubleChoiceWithAsset {
  static showCustomAlertDialogDoubleChoiceWithAsset(
      String title,
      String assetUrl,
      String primaryText,
      String secondaryText,
      Function primaryAction,
      Function secondaryAction,
      BuildContext context,
      double height,
      double width) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0))),
            //backgroundColor: Colors.grey.shade800,
            // backgroundColor: Colors.blueGrey[900],
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                // color: Colors.cyan[600],
                fontWeight: FontWeight.bold,
                fontSize: width / 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: height / 5,
                  child: Image.asset(
                    assetUrl,
                  ),
                ),
                SizedBox(height: height / 50),
                TextButton(
                    child: Text(
                      primaryText,
                      style: TextStyle(
                          fontSize: width / 25,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: primaryAction),
                Divider(),
                TextButton(
                    child: Text(
                      secondaryText,
                      style: TextStyle(
                          fontSize: width / 25,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white),
                    ),
                    onPressed: secondaryAction),
              ],
            ),
          );
        });
  }
}

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Constants.makeRedShadowButton("Sign out", Icons.logout_outlined, () {
      AuthService authService = new AuthService();

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0))),
              // backgroundColor: Colors.blueGrey[900],
              title: Text(
                "Sign Out",
                style: TextStyle(
                  // color: Colors.cyan[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                ("Are you sure you want to sign out?"),
                style: TextStyle(
                  fontSize: 20,
                  // color: Colors.cyan[700],
                  // fontWeight: FontWeight.bold
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        'No',
                        style: TextStyle(fontSize: 20, color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Yes',
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                      onPressed: () async {
                        await authService.signOut();
                        Navigator.pop(context); // close popup

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => NewIntroFlow())));
                      },
                    ),
                  ],
                ),
              ],
            );
          });
    });
  }
}

class ActivatePortalButton extends StatelessWidget {
  String shortDynamicLink;

  ActivatePortalButton({String shortDynamicLink}) {
    this.shortDynamicLink = shortDynamicLink;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
        child: GestureDetector(
      onTap: () {
        CustomAlertDialogDoubleChoiceWithAsset
            .showCustomAlertDialogDoubleChoiceWithAsset(
                "Soshi Portal",
                "assets/images/misc/NFCTemp.png", // To be replaced with NFC activating gif
                "Activate!",
                "Done", () {
          Navigator.pop(context);
          print("NFC writer pops up");
          showModalBottomSheet(
              constraints:
                  BoxConstraints(minWidth: width / 1.1, maxWidth: width / 1.1),
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
                return NFCWriter(height, width, this.shortDynamicLink);
              });

          // showModalBottomSheetApp(builder: NFCWriter(height, width, user.shortDynamicLink));

          // Call NFC writer and write user.shortDynamicLink
        }, () {
          Navigator.pop(context);
        }, context, height, width);
      },
      child: Container(
          height: height / 15,
          width: width / 2.1,
          child: Card(
            // color: Colors.grey.shade800,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Activate Soshi Portal",
                    style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: width / 30),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    CupertinoIcons.info_circle,
                    size: width / 20,
                  )
                ],
              ),
            ),
          )),
    ));
  }
}

class DeleteProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // primary: Colors.black,
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
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              Text("Delete Account",
                  style: TextStyle(
                      // color: Colors.cyan[300],
                      fontWeight: FontWeight.bold)),
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
                        // color: Colors.cyan[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      ("Are you sure you want to delete your profile? This cannot be undone."),
                      style: TextStyle(
                          fontSize: 20,
                          // color: Colors.cyan[700],
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
                              String soshiUsername = DataEngine.soshiUsername;

                              DatabaseService databaseService =
                                  new DatabaseService(
                                      currSoshiUsernameIn: soshiUsername);
                              await databaseService.deleteProfileData();

                              // wipe profile data in firestore
                              AuthService authService = new AuthService();
                              Navigator.of(context).pop();
                              await authService
                                  .deleteProfile(); // delete user account from firebase
                              // LocalDataService.wipeSharedPreferences(); // clear local user data
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

/* Widget to build the display name textfields */
// class DisplayNameTextFields extends StatefulWidget {
//   @override
//   _DisplayNameTextFieldsState createState() => _DisplayNameTextFieldsState();
// }

// class _DisplayNameTextFieldsState extends State<DisplayNameTextFields> {
//   String firstName = LocalDataService.getLocalFirstName();
//   String lastName = LocalDataService.getLocalLastName();
//   TextEditingController firstNameController = new TextEditingController();
//   TextEditingController lastNameController = new TextEditingController();
//   FocusNode firstNameFN = new FocusNode();
//   FocusNode lastNameFN = new FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     firstNameController.text = LocalDataService.getLocalFirstName();
//     firstNameController.selection = TextSelection.fromPosition(TextPosition(offset: firstNameController.text.length));
//     lastNameController.text = LocalDataService.getLocalLastName();
//     lastNameController.selection = TextSelection.fromPosition(TextPosition(offset: lastNameController.text.length));

//     String soshiUsername = LocalDataService.getLocalUsernameForPlatform("Soshi");
//     DatabaseService dbService = new DatabaseService(currSoshiUsernameIn: soshiUsername);

//     // firstNameFN.addListener(() {
//     //   if (!firstNameFN.hasFocus) {
//     //     if (firstNameController.text.length > 0 &&
//     //         firstNameController.text.length <= 12) {
//     //       LocalDataService.updateFirstName(firstNameController.text);
//     //       dbService.updateDisplayName(
//     //           firstNameParam: firstNameController.text,
//     //           lastNameParam: lastNameController.text);
//     //     } else {
//     //       displayNameErrorPopUp("First", context);
//     //     }
//     //   }
//     // });

//     // lastNameFN.addListener(() {
//     //   if (!lastNameFN.hasFocus) {
//     //     if (lastNameController.text.length > 0 &&
//     //         lastNameController.text.length <= 12) {
//     //       LocalDataService.updateLastName(lastNameController.text);
//     //       dbService.updateDisplayName(
//     //           firstNameParam: firstNameController.text,
//     //           lastNameParam: lastNameController.text);
//     //     } else {
//     //       displayNameErrorPopUp("Last", context);
//     //     }
//     //   }
//     // });

//     //firstNameController.text = firstName;
//     //lastNameController.text = lastName;

//     return Row(children: <Widget>[
//       Expanded(
//         child: Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: TextField(
//             autocorrect: false,
//             controller: firstNameController,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 15,
//               // color: Colors.cyan[300]
//             ),
//             onSubmitted: (String inputText) {
//               if (inputText.length > 0 && inputText.length <= 12) {
//                 LocalDataService.updateFirstName(firstNameController.text.trim());
//                 LocalDataService.updateLastName(lastNameController.text.trim());

//                 dbService.updateDisplayName(firstNameParam: firstNameController.text.trim(), lastNameParam: lastNameController.text.trim());
//                 print(firstName + lastName);
//               } else {
//                 Popups.displayNameErrorPopUp("First", context);
//               }
//             },
//             decoration: InputDecoration(
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: Colors.grey[600],
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: Colors.cyan[300],
//                 ),
//               ),
//               prefixIcon: Icon(
//                 Icons.person,
//                 color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
//               ),
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               label: Text("First"),
//               labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[400]),
//               // fillColor: Colors.grey[850],
//               hintText: "First Name",
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ),
//       Expanded(
//         child: Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: TextField(
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 15,
//               color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
//             ),
//             controller: lastNameController,
//             onSubmitted: (String text) {
//               if (text.length > 0 && text.length <= 12) {
//                 LocalDataService.updateLastName(lastNameController.text.trim());
//                 LocalDataService.updateFirstName(firstNameController.text.trim());

//                 dbService.updateDisplayName(firstNameParam: firstNameController.text.trim(), lastNameParam: lastNameController.text.trim());
//                 print(firstName + lastName);
//               } else {
//                 Popups.displayNameErrorPopUp("Last", context);
//               }
//             },
//             decoration: InputDecoration(
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: Colors.grey[600],
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: Colors.cyan[300],
//                 ),
//               ),
//               prefixIcon: Icon(
//                 Icons.person,
//                 color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
//               ),
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               label: Text("Last"),
//               labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[400]),
//               //fillColor: Colors.grey[850],
//               hintText: "Last Name",
//               hintStyle: TextStyle(color: Colors.black, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ),
//     ]);
//   }
// }

/* Widget to return the amount of connections someone has */
class ReturnNumConnections extends StatefulWidget {
  @override
  _ReturnNumConnectionsState createState() => _ReturnNumConnectionsState();
}

class _ReturnNumConnectionsState extends State<ReturnNumConnections> {
  int connectionsCount = DataEngine.globalUser.friends.length;
  @override
  Widget build(BuildContext context) {
    if (connectionsCount.toString() == "1") {
      return Text("1 friend",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            letterSpacing: 2.0,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ));
    }
    return Text(connectionsCount.toString() + " friends",
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          letterSpacing: 2.0,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ));
  }
}

class ShareButton extends StatelessWidget {
  double size;
  String soshiUsername;
  String groupId;
  String shortDynamicLink;

  ShareButton(
      {this.size, this.soshiUsername, this.groupId, this.shortDynamicLink});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(shape: CircleBorder()),
      onPressed: () {
        if (groupId == null) {
          Share.share(this.shortDynamicLink,
              subject: DataEngine.globalUser.firstName +
                  " " +
                  DataEngine.globalUser.lastName +
                  "'s Soshi Contact Card");
        } else {
          Share.share(
            "https://strippedsoshi.page.link" + groupId,
          );
        }
      },
      child: Icon(Icons.share, size: size),
    );
  }
}

class CustomThreeInOut extends StatefulWidget {
  const CustomThreeInOut({
    Key key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 500),
    this.delay = const Duration(milliseconds: 50),
    this.controller,
  })  : assert(
            !(itemBuilder is IndexedWidgetBuilder && color is Color) &&
                !(itemBuilder == null && color == null),
            'You should specify either a itemBuilder or a color'),
        super(key: key);

  final Color color;
  final double size;
  final IndexedWidgetBuilder itemBuilder;
  final Duration duration;
  final Duration delay;
  final AnimationController controller;

  @override
  _CustomThreeInOutState createState() => _CustomThreeInOutState();
}

class _CustomThreeInOutState extends State<CustomThreeInOut>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  List<Widget> _widgets;

  Timer _forwardTimer;

  double _lastAnim = 0;

  @override
  void initState() {
    super.initState();

    // Create a extra element which is used for the show/hide animation.
    _widgets = List.generate(
      4,
      (i) => SizedBox.fromSize(
        size: Size.square(widget.size * 0.5),
        child: _itemBuilder(i),
      ),
    );

    _controller = widget.controller ??
        AnimationController(vsync: this, duration: widget.duration);

    _controller.forward();

    _controller.addListener(() {
      if (_lastAnim > _controller.value) {
        setState(() => _widgets.insert(0, _widgets.removeLast()));
      }

      _lastAnim = _controller.value;

      if (_controller.isCompleted) {
        _forwardTimer =
            Timer(widget.delay, () => _controller?.forward(from: 0));
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
      _controller = null;
    }

    _forwardTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size(widget.size * 2, widget.size),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _widgets
              .asMap()
              .map((index, value) {
                Widget innerWidget = value;

                if (index == 0) {
                  innerWidget = _wrapInAnimatedBuilder(innerWidget);
                } else if (index == 3) {
                  innerWidget = _wrapInAnimatedBuilder(
                    innerWidget,
                    inverse: true,
                  );
                }

                return MapEntry<int, Widget>(index, innerWidget);
              })
              .values
              .toList(),
        ),
      ),
    );
  }

  AnimatedBuilder _wrapInAnimatedBuilder(
    Widget innerWidget, {
    bool inverse = false,
  }) =>
      AnimatedBuilder(
        animation: _controller,
        child: innerWidget,
        builder: (context, inn) {
          final value = inverse ? 1 - _controller.value : _controller.value;
          return SizedBox.fromSize(
            size: Size.square(widget.size * 0.5 * value),
            child: Opacity(child: inn, opacity: value),
          );
        },
      );

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder(context, index)
      : DecoratedBox(
          decoration:
              BoxDecoration(color: widget.color, shape: BoxShape.circle));
}

///CircularProfileAvatar allows developers to implement circular profile avatar with border,
/// overlay, initialsText and many other features which simplifies developer's job.
/// It is an alternative to Flutter's CircleAvatar Widget.
class CircularProfileAvatar extends StatefulWidget {
  CircularProfileAvatar(this.imageUrl,
      {this.initialsText = const Text(''),
      this.cacheImage = true,
      this.radius = 50.0,
      this.borderWidth = 0.0,
      this.borderColor = Colors.white,
      this.backgroundColor = Colors.white,
      this.elevation = 0.0,
      this.showInitialTextAbovePicture = false,
      this.onTap,
      this.foregroundColor = Colors.transparent,
      this.placeHolder,
      this.errorWidget,
      this.imageBuilder,
      this.animateFromOldImageOnUrlChange,
      this.progressIndicatorBuilder,
      this.child,
      this.imageFit = BoxFit.cover});

  /// sets radius of the avatar circle, [borderWidth] is also included in this radius.
  /// default value is 0.0
  final double radius;

  /// sets shadow of the circle,
  /// default value is 0.0
  final double elevation;

  /// sets the borderWidth of the circile,
  /// default value is 0.0
  final double borderWidth;

  /// The color with which to fill the border of the circle.
  /// default value [Colors.white]
  final Color borderColor;

  /// The color with which to fill the circle.
  /// default value [Colors.white]
  final Color backgroundColor;

  /// sets the [foregroundColor] of the circle, It only works if [showInitialTextAbovePicture] is set to true.
  /// [foregroundColor] doesn't include border of the circle.
  final Color foregroundColor;

  /// it takes a URL of the profile image.
  final String imageUrl;

  /// Sets the initials of user's name.
  final Text initialsText;

  /// Displays initials above profile picture if set to true, You can set [foregroundColor] value as well if [showInitialTextAbovePicture]
  /// is set to true.
  final bool showInitialTextAbovePicture;

  /// Cache the image against [imageUrl] in app memory if set true. it is true by default.
  final bool cacheImage;

  /// sets onTap gesture.
  final GestureTapCallback onTap;

  /// Widget displayed while the target [imageUrl] is loading, works only if [cacheImage] is true.
  final PlaceholderWidgetBuilder placeHolder;

  /// Widget displayed while the target [imageUrl] failed loading, works only if [cacheImage] is true.
  final LoadingErrorWidgetBuilder errorWidget;

  /// Widget displayed while the target [imageUrl] is loading, works only if [cacheImage] is true.
  final ProgressIndicatorBuilder progressIndicatorBuilder;

  /// Optional builder to further customize the display of the image.
  final ImageWidgetBuilder imageBuilder;

  /// When set to true it will animate from the old image to the new image
  /// if the url changes.
  final bool animateFromOldImageOnUrlChange;

  /// Setting child will hide every other widget [initialsText] and profile picture against [imageUrl].
  /// Best use case is passing [AssetImage] as profile picture. You can pass [imageUrl] as empty string if you want to set child value.
  final Widget child;

  /// How to inscribe the image into the space allocated during layout.
  /// Set the [BoxFit] value as you want.
  final BoxFit imageFit;

  @override
  _CircularProfileAvatarState createState() => _CircularProfileAvatarState();
}

class _CircularProfileAvatarState extends State<CircularProfileAvatar> {
  Widget _initialsText;

  @override
  Widget build(BuildContext context) {
    _initialsText = Center(child: widget.initialsText);
    return GestureDetector(
      onTap: widget.onTap,
      child: Material(
        type: MaterialType.circle,
        elevation: widget.elevation,
        color: widget.borderColor,
        child: Container(
            height: widget.radius * 2,
            width: widget.radius * 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(
                  width: widget.borderWidth, color: widget.borderColor),
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(widget.radius)),
                child: widget.child == null
                    ? Stack(
                        fit: StackFit.expand,
                        children: widget.imageUrl.isEmpty
                            ? <Widget>[_initialsText]
                            : widget.showInitialTextAbovePicture
                                ? <Widget>[
                                    profileImage(),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: widget.foregroundColor,
                                        borderRadius: BorderRadius.circular(
                                            widget.radius),
                                      ),
                                    ),
                                    _initialsText,
                                  ]
                                : <Widget>[
                                    _initialsText,
                                    profileImage(),
                                  ],
                      )
                    : child(),
              ),
            )),
      ),
    );
  }

  Widget child() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Container(
        height: widget.radius * 2,
        width: widget.radius * 2,
        child: widget.child,
      ),
    );
  }

  Widget profileImage({bool circular = true}) {
    return widget.cacheImage
        ? ClipRRect(
            borderRadius: circular
                ? BorderRadius.circular(widget.radius)
                : BorderRadius.zero,
            child: ((widget.imageUrl != null) &&
                    widget.imageUrl != "null" &&
                    widget.imageUrl != null)
                ? CachedNetworkImage(
                    fit: widget.imageFit,
                    imageUrl: widget.imageUrl,
                    errorWidget: widget.errorWidget,
                    placeholder: widget.placeHolder,
                    imageBuilder: widget.imageBuilder,
                    progressIndicatorBuilder: widget.progressIndicatorBuilder,
                    useOldImageOnUrlChange:
                        widget.animateFromOldImageOnUrlChange ?? false,
                  )
                : Image.asset(
                    'assets/images/misc/default_pic.png',
                    fit: widget.imageFit,
                  ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: ((widget.imageUrl != null) && widget.imageUrl != "null")
                ? Image.network(
                    widget.imageUrl,
                    fit: widget.imageFit,
                  )
                : Image.asset(
                    'assets/images/misc/default_pic.png',
                    fit: widget.imageFit,
                  ));
  }
}

class SoshiAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        // Status bar color
        statusBarColor: Colors.transparent,

        // Status bar brightness (optional)
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
      leadingWidth: 100,
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      //     child: ElevatedButton(
      //       onPressed: () {
      //         URL.launchURL("sms:" + "5713351885");
      //       },
      //       style: ElevatedButton.styleFrom(
      //           // primary: Theme.of(context).primaryColor,
      //           //shadowColor: Colors.grey[900],
      //           shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.all(Radius.circular(15.0)))),
      //       child: Row(
      //         children: [
      //           Column(
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               Text("Send",
      //                   style: TextStyle(
      //                       fontSize: 10,
      //                       fontWeight: FontWeight.bold,
      //                       letterSpacing: 1)),
      //               Text("feedback!",
      //                   style: TextStyle(
      //                       fontSize: 10,
      //                       fontWeight: FontWeight.bold,
      //                       letterSpacing: 1)),
      //             ],
      //           ),
      //           // Icon(
      //           //   Icons.feedback,
      //           //   color: Colors.cyan[300],
      //           //   size: 10,
      //           // ),
      //         ],
      //       ),

      //       // Icon(Icons.person_rounded,
      //       //     color: Colors.cyan[300], size: 10.0),
      //     ),
      //   ),
      // ],
      elevation: 5,
      shadowColor: Colors.cyan,
      title: Padding(
        padding: EdgeInsets.zero,
        child: Image.asset(
          "assets/images/SoshiLogos/SoshiBubbleLogo.png",
          // Theme.of(context).brightness == Brightness.light
          //     ? "assets/images/SoshiLogos/soshi_logo_black.png"
          //     : "assets/images/SoshiLogos/soshi_logo.png",

          height: Utilities.getHeight(context) / 17,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      centerTitle: true,
    );
  }
}

class PassionBubble extends StatelessWidget {
  String passionString;
  String passionEmoji;

  PassionBubble(this.passionString, this.passionEmoji);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Text(
                  passionEmoji,
                  style: TextStyle(fontSize: width / 20),
                ),
              ),
              Container(
                //color: Colors.green,
                width: width / 6,
                child: AutoSizeText(
                  passionString,
                  textAlign: TextAlign.center,
                  maxLines: 1, //passion.name.contains(" ") ? 2 : 1,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 25),
                  minFontSize: 1,
                ),
              ),
            ],
          ),
          // child: Container(
          //   width: width / 4.5,
          //   height: height / 30,
          //   decoration: BoxDecoration(color: Colors.blue),
          //   child: AutoSizeText(
          //     passionEmoji + passionString,
          //     // style: TextStyle(fontSize: width / 28),
          //   ),
          // ),
        ));
  }
}

class ProfilePicBackdrop extends StatelessWidget {
  String url;
  double height, width;

  ProfilePicBackdrop(this.url, {@required this.height, @required this.width});

  @override
  Widget build(BuildContext context) {
    if (url != null && url != "null") {
      return Image.network(
        url,
        fit: BoxFit.fill,
        height: height,
        width: width,
      );
    } else {
      return Image.asset("assets/images/misc/default_pic.png");
    }
  }
}

class SMButton extends StatelessWidget {
  String soshiUsername, platform, username;
  double size;
  SoshiUser userObject;
  String phoneFromUserObject;
  String emailFromUserObject;

  SMButton(
      {this.soshiUsername, this.platform, this.username, this.size = 70.0});

  getUserData() async {
    userObject = await DataEngine.getUserObject(
        firebaseOverride: true, friendOverride: soshiUsername);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // splashColor: Colors.cyan[300],
      splashRadius: 55.0,
      icon: Image.asset(
        "assets/images/SMLogos/" + platform + "Logo.png",
      ),
      onPressed: () async {
        Analytics.logAccessPlatform(platform);
        if (platform == "Contact") {
          DialogBuilder(context).showLoadingIndicator();

          double width = MediaQuery.of(context).size.width;

          Uint8List profilePicBytes;

          try {
            await getUserData(); // Get user object based on SOSHI Username

            // Get phone number and email for easy handling
            emailFromUserObject =
                userObject.getUsernameGivenPlatform(platform: "Email");
            phoneFromUserObject =
                userObject.getUsernameGivenPlatform(platform: "Phone");

            // Try to load profile pic from url
            await http
                .get(Uri.parse(userObject.photoURL))
                .then((http.Response response) {
              profilePicBytes = response.bodyBytes;
            });
          } catch (e) {
            // if url is invalid, use default profile pic
            ByteData data =
                await rootBundle.load("assets/images/misc/default_pic.png");
            profilePicBytes = data.buffer.asUint8List();
          }
          Contact newContact = new Contact(
              givenName: userObject.firstName,
              familyName: userObject.lastName,
              emails: [
                Item(label: "Email", value: emailFromUserObject),
              ],
              phones: [
                Item(label: "Cell", value: phoneFromUserObject),
              ],
              avatar: profilePicBytes);
          await askPermissions(context);

          await ContactsService.addContact(newContact);

          DialogBuilder(context).hideOpenDialog();

          Popups.showContactAddedPopup(
              context,
              width,
              userObject.photoURL,
              userObject.firstName,
              userObject.lastName,
              phoneFromUserObject,
              emailFromUserObject);
        } else if (platform == "Cryptowallet") {
          Clipboard.setData(ClipboardData(
            text: username.toString(),
          ));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
              'Wallet address copied to clipboard!',
              textAlign: TextAlign.center,
            ),
          ));
        } else {
          print("Launching $username");
          URL.launchURL(
              URL.getPlatformURL(platform: platform, username: username));
        }
      },
      iconSize: size,
    );
  }
}

class CupertinoBackButton extends StatelessWidget {
  Function onPressed;
  Color color = Colors.grey;

  CupertinoBackButton({this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 15,
      onPressed: () {
        onPressed != null ? onPressed() : Navigator.of(context).pop();
      },
      icon: Icon(CupertinoIcons.back, color: color),
    );
  }
}

class SoshiUsernameText extends StatelessWidget {
  double fontSize;
  String username;
  bool isVerified;
  SoshiUsernameText(this.username,
      {@required this.fontSize, @required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: [
        Text("@" + username,
            style: TextStyle(
              color: Colors.grey,
              fontSize: fontSize,
            )),
        Visibility(
          visible: isVerified != null && isVerified != false,
          child: Row(
            children: [
              SizedBox(
                width: fontSize / 10,
              ),
              Image.asset(
                "assets/images/misc/verified.png",
                width: fontSize,
                height: fontSize,
              ),
            ],
          ),
        )
      ],
    ));
  }
}


// class AddedMeButton extends StatelessWidget {
//   double size;
//   String soshiUsername;
//   DatabaseService databaseService;

//   AddedMeButton({this.size = 30.0, this.soshiUsername, this.databaseService});

//   Future<List<Friend>> generateAddedMeList(
//       DatabaseService databaseService) async {
//     List<dynamic> addedMeList;
//     try {
//       addedMeList = await databaseService.getAddedMeList(soshiUsername);
//     } catch (e) {
//       addedMeList = [];
//       print(e);
//     }
//     List<Friend> addedMeListFriend = [];

//     for (String user in addedMeList) {
//       Map userData = await databaseService.getUserFile(user);
//       Friend friend = new Friend(
//           fullName: userData["Name"]["First"] + " " + userData["Name"]["Last"],
//           soshiUsername: userData["Usernames"]["Soshi"],
//           photoURL: userData["Photo URL"]);
//       addedMeListFriend.add(friend);
//     }
//     print(addedMeListFriend.toString());
//     return addedMeListFriend;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//           primary: Constants.buttonColorDark, shape: CircleBorder()),
//       onPressed: () {
//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                   insetPadding: EdgeInsets.all(0.0),
//                   backgroundColor: Colors.grey[900],
//                   contentPadding:
//                       EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                   ),
//                   content: Container(
//                     height: 300,
//                     width: 200,
//                     child: FutureBuilder(
//                         future: generateAddedMeList(databaseService),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.done) {
//                             List<Friend> addedMeList = snapshot.data;
//                             Friend friend;
//                             return Container(
//                               height: 200,
//                               width: 150,
//                               child: addedMeList.isNotEmpty
//                                   ? ListView.builder(
//                                       shrinkWrap: true,
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       // separatorBuilder: (BuildContext context, int i) {
//                                       // return Padding(padding: EdgeInsets.all(0.0));
//                                       // },
//                                       itemBuilder:
//                                           (BuildContext context, int i) {
//                                         friend = addedMeList[i];
//                                         return Padding(
//                                           padding: const EdgeInsets.fromLTRB(
//                                               10.0, 5, 10, 10),
//                                           child: ListTile(
//                                               onTap: () async {
//                                                 Popups.showUserProfilePopup(
//                                                     context,
//                                                     soshiUsername:
//                                                         friend.soshiUsername,
//                                                     refreshScreen:
//                                                         () {}); // show friend popup when tile is pressed
//                                               },
//                                               leading: ProfilePic(
//                                                   radius: 30,
//                                                   url: friend.photoURL),

//                                               // CircleAvatar(
//                                               //   radius: 35.0,
//                                               //   backgroundImage: NetworkImage(friend.photoURL),
//                                               // ),
//                                               title: Column(
//                                                 children: <Widget>[
//                                                   Text(friend.fullName,
//                                                       style: TextStyle(
//                                                           color:
//                                                               Colors.cyan[600],
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontSize: 20)),
//                                                   Text(
//                                                     "@" + friend.soshiUsername,
//                                                     style: TextStyle(
//                                                         color: Colors.grey[500],
//                                                         fontSize: 15,
//                                                         fontStyle:
//                                                             FontStyle.italic),
//                                                   ),
//                                                 ],
//                                               ),
//                                               tileColor: Colors.grey[900],
//                                               selectedTileColor:
//                                                   Constants.buttonColorLight,
//                                               contentPadding:
//                                                   EdgeInsets.all(10),
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(15),
//                                                   side: BorderSide(
//                                                       width: 2,
//                                                       color: Colors.blueGrey)),
//                                               trailing: Row(
//                                                 children: [
//                                                   IconButton(
//                                                       icon: Icon(
//                                                           Icons.check_circle),
//                                                       color: Colors.green),
//                                                   IconButton(
//                                                     icon: Icon(
//                                                       Icons.delete,
//                                                       size: 30,
//                                                       color: Colors.white,
//                                                     ),
//                                                     color: Colors.black,
//                                                     onPressed: () {
//                                                       showDialog(
//                                                           context: context,
//                                                           builder: (BuildContext
//                                                               context) {
//                                                             return AlertDialog(
//                                                               shape: RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.all(
//                                                                           Radius.circular(
//                                                                               40.0))),
//                                                               backgroundColor:
//                                                                   Colors.blueGrey[
//                                                                       900],
//                                                               title: Text(
//                                                                 "Remove Friend",
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                             .cyan[
//                                                                         600],
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold),
//                                                               ),
//                                                               content: Text(
//                                                                 ("Are you sure you want to decline " +
//                                                                     friend
//                                                                         .fullName +
//                                                                     " as a friend?"),
//                                                                 style: TextStyle(
//                                                                     fontSize:
//                                                                         20,
//                                                                     color: Colors
//                                                                             .cyan[
//                                                                         700],
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold),
//                                                               ),
//                                                               actions: <Widget>[
//                                                                 Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .spaceEvenly,
//                                                                   children: <
//                                                                       Widget>[
//                                                                     TextButton(
//                                                                       child:
//                                                                           Text(
//                                                                         'No',
//                                                                         style: TextStyle(
//                                                                             fontSize:
//                                                                                 20),
//                                                                       ),
//                                                                       onPressed:
//                                                                           () {
//                                                                         Navigator.pop(
//                                                                             context);
//                                                                       },
//                                                                     ),
//                                                                     TextButton(
//                                                                       child:
//                                                                           Text(
//                                                                         'Yes',
//                                                                         style: TextStyle(
//                                                                             fontSize:
//                                                                                 20,
//                                                                             color:
//                                                                                 Colors.red),
//                                                                       ),
//                                                                       onPressed:
//                                                                           () {
//                                                                         // remove from added me list
//                                                                         databaseService
//                                                                             .removeFromAddedMeList(friend.soshiUsername);
//                                                                         Navigator.pop(
//                                                                             context);
//                                                                       },
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ],
//                                                             );
//                                                           });
//                                                     },
//                                                     // shape: RoundedRectangleBorder(
//                                                     //     borderRadius: BorderRadius.circular(60.0)),

//                                                     //itemBuilder: (BuildContext context) {
//                                                     //return [
//                                                     // PopupMenuItem(
//                                                     //     child: IconButton(
//                                                     //         icon: Icon(Icons.delete),
//                                                     //         color: Colors.white,
//                                                     //         iconSize: 40,
//                                                     //         splashColor: Colors.cyan,
//                                                     //         // style: ElevatedButton.styleFrom(
//                                                     //         //     primary: Colors.cyan[800]),
//                                                     //         // Text(
//                                                     //         //   "Remove Friend",
//                                                     //         //   style: TextStyle(color: Colors.black),
//                                                     //         // ),
//                                                     //         onPressed: () async {
//                                                     //           Navigator.pop(context);
//                                                     //           await LocalDataService.removeFriend(
//                                                     //               friendsoshiUsername: friend.soshiUsername);
//                                                     //           databaseService.removeFriend(friendsoshiUsername: friend.soshiUsername);
//                                                     //           refreshFriendScreen();
//                                                     //         }))
//                                                     //   ];
//                                                     // }
//                                                   ),
//                                                 ],
//                                               )),
//                                         );
//                                       },
//                                       itemCount: (addedMeList == null)
//                                           ? 1
//                                           : addedMeList.length,
//                                       padding:
//                                           EdgeInsets.fromLTRB(5.0, 0, 5.0, 5.0))
//                                   : Padding(
//                                       padding: const EdgeInsets.fromLTRB(
//                                           0, 20, 0, 15),
//                                       child: Center(
//                                         child: Column(
//                                           children: <Widget>[
//                                             Text(
//                                               "You're up to date! No one new has added you.",
//                                               style: TextStyle(
//                                                   color: Colors.cyan[300],
//                                                   fontSize: 20,
//                                                   fontStyle: FontStyle.italic,
//                                                   letterSpacing: 2),
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: ElevatedButton(
//                                                 child: Container(
//                                                   child: Row(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                   ),
//                                                 ),
//                                                 style:
//                                                     Constants.ButtonStyleDark,
//                                                 onPressed: () async {},
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                             );
//                           } else {
//                             return Center(
//                                 child: CircularProgressIndicator.adaptive());
//                           }
//                         }),
//                   ));
//             });
//       },
//       child: Icon(Icons.person_add, color: Colors.cyan[300], size: size),
//     );
//   }
// }