import 'dart:developer';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:soshi/services/dataEngine.dart';

import '../../constants/popups.dart';
import '../../constants/utilities.dart';
import '../../constants/widgets.dart';
import '../../services/contacts.dart';
import '../../services/database.dart';
import '../login/loading.dart';

class SwappedContactsPage extends StatefulWidget {
  @override
  State<SwappedContactsPage> createState() => _SwappedContactsPageState();
}

class _SwappedContactsPageState extends State<SwappedContactsPage> {
  List<SwappedContact> swappedContacts;
  DatabaseService databaseService = new DatabaseService();
  void refreshSwappedContactsScreen() {
    //implement loading icon
    setState(() {
      // initializeFriendsList();
    });
    log('refreshed friends screen');
  }

  Stream<List<SwappedContact>> getLatestSwapInfo = (() async* {
    List<SwappedContact> swappedContacts =
        await SwappedContact.getSwappedContactList(
                DataEngine.globalUser.soshiUsername) ??
            [];

    swappedContacts = new List.from(swappedContacts.reversed);
    yield swappedContacts;

    // Call database for list of swapped friends
  })();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      //   child: ElevatedButton(
      //   onPressed: () async {
      //     SwappedContact.getSwappedContactList(
      //         DataEngine.globalUser.soshiUsername);
      //   },
      // )
      child: StreamBuilder<List<SwappedContact>>(
          stream: getLatestSwapInfo,
          // initialData: swappedContacts,
          builder: (BuildContext context,
              AsyncSnapshot<List<SwappedContact>> snapshot) {
            if (snapshot.hasError) {
              //   // this is if the user file does not have the swappedContacts Field
              //     await databaseService.updateSwappedContactsField();
              //     DataEngine.updateCachedSwappedContactsList(swappedContacts: []);
              //     await DataEngine.applyUserChanges(
              //         user: DataEngine.globalUser, cloud: false, local: true);
              // }
              return Padding(
                padding: EdgeInsets.only(left: width / 10, right: width / 10),
                child: Text(
                  "Share your profile to have people send their information back.",
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) {
              swappedContacts = snapshot.data ?? [];

              return Container(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: swappedContacts.isNotEmpty
                          ? ListView.builder(
                              itemCount: swappedContacts.length,
                              itemBuilder: (context, i) {
                                SwappedContact individualSwappedContact =
                                    swappedContacts[i];
                                if (i >= swappedContacts.length) {
                                  return Container();
                                }
                                return SwappedContactTile(
                                  swappedContact: individualSwappedContact,
                                  swappedContacts: swappedContacts,
                                  refreshSwappedContactsScreen:
                                      refreshSwappedContactsScreen,
                                );
                              },
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  left: width / 10, right: width / 10),
                              child: Text(
                                "Share your profile to have people send their information back!",
                                textAlign: TextAlign.center,
                              ),
                            )));
            } else {
              return Text("You are not supposed to see this :D");
            }
          }),
    );
  }
}

class SwappedContactTile extends StatelessWidget {
  SwappedContact swappedContact;
  DatabaseService databaseService;
  List<SwappedContact> swappedContacts;
  Function refreshSwappedContactsScreen;

  SwappedContactTile(
      {@required this.swappedContact,
      @required this.swappedContacts,
      @required this.refreshSwappedContactsScreen});

  get http => null;

  Widget build(BuildContext context) {
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);

    return Container(
      height: height / 10,
      child: ListTile(
          onTap: () async {
            DialogBuilder(context).showLoadingIndicator();
            String firstName;
            String lastName;
            print(swappedContact.fullName);
            if (swappedContact.fullName.contains(" ")) {
              firstName = swappedContact.fullName.split(" ")[0];
              lastName = swappedContact.fullName.split(" ")[1];
              print(firstName);
              print(lastName);
            } else {
              firstName = swappedContact.fullName;
              lastName = "";
            }
            String email = swappedContact.email;
            String phoneNumber = swappedContact.phoneNumber;

            // Uint8List profilePicBytes;

            // try {
            //   // try to load profile pic from url
            //   // await http
            //   //     .get(Uri.parse(photoUrl))
            //   //     .then(
            //   //         (http.Response response) {
            //   //   profilePicBytes =
            //   //       response.bodyBytes;
            //   // });
            // } catch (e) {
            //   // if url is invalid, use default profile pic
            //   // ByteData data =
            //   //     await rootBundle.load("assets/images/misc/default_pic.png");
            //   // profilePicBytes = data.buffer.asUint8List();
            // }
            Contact newContact = new Contact(
              givenName: firstName,
              familyName: lastName,
              emails: [
                Item(label: "Email", value: email),
              ],
              company:
                  swappedContact.company != "" ? swappedContact.company : null,
              jobTitle: swappedContact.jobTitle != ""
                  ? swappedContact.jobTitle
                  : null,

              phones: [
                Item(label: "Cell", value: phoneNumber),
              ],
              // avatar: profilePicBytes
            );
            await askPermissions(context);

            await ContactsService.addContact(newContact);
            DialogBuilder(context).hideOpenDialog();

            Popups.showContactAddedPopup(
                context,
                width,
                Defaults.defaultProfilePic,
                firstName,
                lastName,
                phoneNumber,
                email);
            //ContactsService.openExistingContact(newContact);

            print("ADDED!");

            // push to page/popup to show information
          },
          leading: Hero(
              tag: swappedContact.fullName,
              child: ProfilePic(
                  radius: width / 14, url: Defaults.defaultProfilePic)),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(swappedContact.fullName,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                      // color: Colors.cyan[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              SizedBox(height: height / 170),
              HeaderTitle(swappedContact.jobTitle, fontSize: 14),
            ],
          ),
          tileColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            // side: BorderSide(width: .5)
          ),
          trailing: IconButton(
              icon: Icon(
                Icons.more_horiz_rounded,
                size: 30,
                // color: Colors.white,
              ),
              // color: Colors.black,
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
                        height: height / 2.8,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(0,
                                                height / 160, 0, height / 100),
                                            child: ProfilePic(
                                              radius: width / 10,
                                              url: Defaults.defaultProfilePic,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                swappedContact.fullName,
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: width / 25,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(),
                                          ListTile(
                                            title: Center(
                                              child: Text(
                                                "Remove Contact",
                                                style: TextStyle(
                                                    fontSize: width / 20,
                                                    color: Colors.red),
                                              ),
                                            ),
                                            onTap: () async {
                                              swappedContacts.removeWhere(
                                                  (SwappedContactObj) =>
                                                      SwappedContactObj
                                                          .nameOfSwappedContactFile ==
                                                      swappedContact
                                                          .nameOfSwappedContactFile); // update cached list
                                              DataEngine
                                                  .updateCachedSwappedContactsList(
                                                      swappedContacts:
                                                          swappedContacts);
                                              DataEngine
                                                  .globalUser.swappedContacts
                                                  .remove(swappedContact
                                                      .nameOfSwappedContactFile); // update string list
                                              DataEngine.applyUserChanges(
                                                  user: DataEngine.globalUser,
                                                  cloud: true,
                                                  local: true);
                                              Navigator.pop(context);

                                              print(DataEngine
                                                  .globalUser.swappedContacts
                                                  .toString());

                                              refreshSwappedContactsScreen();
                                              // run the stream again
                                              //Navigator.pop(context);
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
                                      style: TextStyle(
                                          fontSize: width / 20,
                                          color: Colors.blue),
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
              })),
    );
  }
}
