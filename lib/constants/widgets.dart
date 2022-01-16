import 'dart:async';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return CircularProfileAvatar(
      url,
      placeHolder: (b, c) {
        return Image.asset('assets/images/SoshiLogos/soshi_icon.png');
      },
      borderColor: Colors.transparent,
      borderWidth: 3,
      elevation: 5,
      radius: radius,
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
        new DatabaseService(soshiUsernameIn: soshiUsername);
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
  int connectionsCount = LocalDataService.getLocalFriendsListCount();
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

class SpinKitThreeInOut extends StatefulWidget {
  const SpinKitThreeInOut({
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
  _SpinKitThreeInOutState createState() => _SpinKitThreeInOutState();
}

class _SpinKitThreeInOutState extends State<SpinKitThreeInOut>
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
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      "assets/images/SoshiLogos/soshi_icon_marble.png")),
              shape: BoxShape.circle));
}
