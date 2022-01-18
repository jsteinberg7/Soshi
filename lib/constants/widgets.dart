import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    return Container(
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        border: new Border.all(
          color: Colors.cyanAccent,
          width: radius / 30,
        ),
      ),
      child: CircularProfileAvatar(
        url,
        placeHolder: (b, c) {
          return Image.asset('assets/images/SoshiLogos/soshi_icon.png');
        },
        borderColor: Colors.black,
        borderWidth: radius / 20,
        elevation: 5,
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
                firstNameController.text = text;
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
                lastNameController.text = text;
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
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      "assets/images/SoshiLogos/soshi_icon_marble.png")),
              shape: BoxShape.circle));
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

  Widget profileImage() {
    return widget.cacheImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: ((widget.imageUrl != null) && widget.imageUrl != "null")
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
                    'assets/images/SoshiLogos/soshi_icon.png',
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
                    'assets/images/SoshiLogos/soshi_icon.png',
                    fit: widget.imageFit,
                  ));
  }
}
