import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/screens/mainapp/viewGroupPage.dart';
import 'package:soshi/services/localData.dart';

import '../../constants/constants.dart';
import '../../constants/popups.dart';
import '../../services/database.dart';
import 'friendScreen.dart';

class GroupScreen extends StatefulWidget {
  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  DatabaseService databaseService;
  AsyncMemoizer memoizer;
  TextEditingController searchController;
  @override
  void initState() {
    memoizer = new AsyncMemoizer();
    databaseService = new DatabaseService(
        currSoshiUsernameIn: LocalDataService.getLocalUsername());
    searchController = TextEditingController();
    searchController.addListener(() {
      String text = searchController.text;
      if (text.isNotEmpty) {
        // filterList(searchController.text);
      } else {
        // if empty, go back to full list
        setState(() {
          // isSearching = true;
          // formattedFriendsList = List.from(formattedFriendsListOriginal);
        });
      }
    });
    super.initState();
  }

  void refreshGroups() async {
    await getGroups();
    setState(() {});
  }

  Future<dynamic> getGroups() async {
    return this.memoizer.runOnce(() async {
      return await databaseService.getGroupObjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    return Container(
        child: Column(children: [
      FutureBuilder(
          future: getGroups(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  height: height / 2,
                  child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.connectionState == ConnectionState.done) {
              dynamic data = snapshot.data;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: height / 18,
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                            hintText: 'Search \"${[
                              "Terps Football",
                              "Sig Phi",
                              "CMSC330 Group",
                              "JMU Baseball",
                              "Denton Hall",
                              "Juggling Club"
                            ][Random().nextInt(5)]}\"',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            prefixIcon: Icon(
                              Icons.search,
                            ),
                            labelText: "Search groups..."),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
                          child: Text("Groups (${data.length})"),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
                          child: Constants.makeBlueShadowButtonSmall(
                              "Create Group", Icons.group_add, () {
                            showGeneralDialog(
                                transitionDuration: Duration(milliseconds: 200),
                                barrierDismissible: true,
                                context: context,
                                barrierLabel: '',
                                pageBuilder: (context, animation1, animation2) {
                                  return CreateGroupPopup(
                                    width: width,
                                    height: height,
                                    databaseService: databaseService,
                                    refreshGroups: refreshGroups,
                                  );
                                });
                          }),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: height / 1.7,
                    width: width,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Padding(
                            padding: EdgeInsets.all(10.0),
                            child: GroupCard(width: width, group: data[i]));
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text("No groups"));
            }
          })
    ]));
  }
}

class CreateGroupPopup extends StatefulWidget {
  @override
  State<CreateGroupPopup> createState() => _CreateGroupPopupState();

  DatabaseService databaseService;
  double width;
  double height;
  Function refreshGroups;
  CreateGroupPopup(
      {this.width, this.height, this.databaseService, this.refreshGroups});
}

class _CreateGroupPopupState extends State<CreateGroupPopup> {
  TextEditingController groupNameController;
  File picFile;
  double width;
  double height;
  File groupPic;
  @override
  void initState() {
    width = widget.width;
    height = widget.height;
    groupNameController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? null
          : Colors.black,
      elevation: 50,
      insetPadding: EdgeInsets.all(width / 14),
      //insetPadding: EdgeInsets.all(0.0),
      // backgroundColor: Colors.black,
      // contentPadding:
      //     EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(30.0),
      ),
      content: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0))),
          height: height / 2.2,
          // color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: GestureDetector(
                  onTap: () async {
                    DatabaseService dbService = new DatabaseService();

                    // update profile picture on tap
                    // open up image picker
                    final ImagePicker imagePicker = ImagePicker();
                    final PickedFile pickedImage = await imagePicker.getImage(
                        source: ImageSource.gallery, imageQuality: 20);
                    groupPic = await dbService.cropImage(pickedImage.path,
                        cropStyle: CropStyle.rectangle);

                    setState(() {
                      picFile = groupPic;
                    });
                  },
                  child: Stack(
                    children: [
                      RectangularProfilePic(
                        radius: width / 3,
                        url: null,
                        defaultPic: true,
                        file: picFile,
                      ),
                      Positioned(
                          bottom: width / 100,
                          right: width / 100,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              padding: EdgeInsets.all(width / 100),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.black),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
              Container(
                width: width / 1.4,
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          // color: Colors.white
                          ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ), //border: InputBorder.,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(
                      Icons.group,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                    hintText: 'Name your group...',
                    // hintStyle: kHintTextStyle,
                  ),
                  controller: groupNameController,
                ),
              ),
              Constants.makeBlueShadowButton("Create", Icons.add, (() async {
                String id =
                    "${Random().nextInt(1000)}${DateTime.now().millisecondsSinceEpoch}";
                String photoURL;
                if (groupPic != null) {
                  photoURL = await widget.databaseService.uploadProfilePicture(
                      groupPic,
                      groupId: id); // upload pic to Firebase Storage
                }
                await widget.databaseService.createGroup(
                    id: id, name: groupNameController.text, photoURL: photoURL);
                widget.refreshGroups();
                Navigator.pop(context);
              }))
            ],
          )),
    );
  }
}

class Group {
  String id, name, description, photoURL;
  List<dynamic> admin, members;

  Group(
      {this.id,
      this.name,
      this.description,
      this.photoURL,
      this.admin,
      this.members});
}

class GroupCard extends StatelessWidget {
  Group group;
  double width;
  GroupCard({@required width, @required this.group});

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ViewGroupPage(group); // Returning the ResetPassword screen
        }));
      },
      child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), side: BorderSide.none),
          elevation: 5.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: group.id,
                    child: RectangularProfilePic(
                        // radius: width / 12,
                        radius: 100,
                        url: group.photoURL),
                  ),
                  // Icon(Icons.arrow_forward_ios)
                ],
              ),
              Column(
                children: [
                  Text(group.name),
                  SizedBox(width: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people),
                      Text((group.admin.length + group.members.length)
                          .toString()),
                    ],
                  ),
                ],
              )
            ],
          )),
    );
  }
}
