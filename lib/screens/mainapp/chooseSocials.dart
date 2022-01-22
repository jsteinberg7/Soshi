import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/screens/mainapp/qrCode.dart';
import 'package:soshi/services/contacts.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';

// ignore: must_be_immutable
class ChooseSocialsCard extends StatefulWidget {
  @override
  String platformName, soshiUsername;
  Function() refreshScreen;
  ChooseSocialsCard(
      {String platformName, String soshiUsername, Function refreshScren}) {
    this.platformName = platformName;
    this.soshiUsername = soshiUsername;
    this.refreshScreen = refreshScreen;
  }

  _ChooseSocialsCardState createState() => _ChooseSocialsCardState();
}

class _ChooseSocialsCardState extends State<ChooseSocialsCard> {
  DatabaseService databaseService;
  String currSoshiUsername, platformName;
  var isSwitched = false;

  //var value = false;

  @override
  void initState() {
    super.initState();
    currSoshiUsername = widget.soshiUsername;
    platformName = widget.platformName;
    databaseService =
        new DatabaseService(currSoshiUsernameIn: currSoshiUsername);
    isSwitched = Queue.choosePlatformsQueue.contains(platformName);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        setState(() {
          isSwitched = !isSwitched;
        });
        if (isSwitched == true) {
          if (!Queue.choosePlatformsQueue.contains(platformName)) {
            Queue.choosePlatformsQueue.add(platformName);
          }
        } else {
          Queue.choosePlatformsQueue.remove(platformName);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: isSwitched
                ? BorderSide(color: Colors.cyanAccent[100])
                : BorderSide.none),
        elevation: 20,
        color: Colors.grey[800],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 5, 15),
          child: Row(
            children: <Widget>[
              Image.asset('assets/images/SMLogos/' + platformName + 'Logo.png',
                  height: width / 5, width: width / 5),
              SizedBox(width: width / 30),
              Image.asset(
                'assets/images/SMWriting/' + platformName + 'Writing.png',
                height: (width * .31) / 1.5,
                width: (width * .69) / 1.5,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  value: isSwitched,
                  checkColor: Colors.cyan,
                  activeColor: Colors.white,
                  onChanged: (bool value) {
                    setState(() {
                      isSwitched = !isSwitched;
                      if (!Queue.choosePlatformsQueue.contains(platformName)) {
                        Queue.choosePlatformsQueue.add(platformName);
                      } else {
                        Queue.choosePlatformsQueue.remove(platformName);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChooseSocials extends StatefulWidget {
  @override
  _ChooseSocialsState createState() => _ChooseSocialsState();

  Function refreshProfile;
  ChooseSocials({Function refreshFunction}) {
    this.refreshProfile = refreshFunction;
  }
}

class _ChooseSocialsState extends State<ChooseSocials> {
  Function refreshProfile;
  DatabaseService databaseService;

  @override
  void dispose() {
    Queue.choosePlatformsQueue.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    refreshProfile = widget.refreshProfile;
  }

  @override
  Widget build(BuildContext context) {
    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");
    databaseService = new DatabaseService(currSoshiUsernameIn: soshiUsername);
    // List<String> choosePlatformsQueue = [];
    List<String> choosePlatforms = LocalDataService.getLocalChoosePlatforms();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Platform",
          style: TextStyle(
              color: Colors.cyan[200],
              fontSize: 25,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        backgroundColor: Colors.grey[850],
        centerTitle: true,
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: RaisedButton(
          //style: ElevatedButton.styleFrom(side: BorderSide(width: 5.0, color: Colors.red,)),
          //color: Colors.grey[500],
          elevation: 20,
          onPressed: () async {
            // Navigator.pop(context);
            DialogBuilder(context).showLoadingIndicator();
            //DialogBuilder(context).hideOpenDialog();

            // if platform has username, turn switch on
            for (String platform in Queue.choosePlatformsQueue) {
              String username =
                  LocalDataService.getLocalUsernameForPlatform(platform);
              if (username != null && username.length > 3) {
                // turn switch on
                await LocalDataService.updateSwitchForPlatform(
                    platform: platform, state: true);
                await databaseService.updatePlatformSwitch(
                    platform: platform, state: true);
              }
            }

            await LocalDataService.addPlatformsToProfile(
                Queue.choosePlatformsQueue);
            // check if contact card is being added
            if (Queue.choosePlatformsQueue.contains("Contact")) {
              await databaseService.updateContactCard();
            }
            // Navigator.pop(context);
            // Navigator.pop(context);
            refreshProfile();
            LocalDataService.removeFromChoosePlatforms(
                Queue.choosePlatformsQueue);
            databaseService.addPlatformsToProfile(Queue.choosePlatformsQueue);
            databaseService
                .removeFromChoosePlatforms(Queue.choosePlatformsQueue);
          },
          padding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: Colors.cyan[400])),
          color: Colors.grey[300],
          child: Text(
            'Add to profile',
            style: TextStyle(
              //color: Color(0xFF527DAA),
              color: Colors.black,
              letterSpacing: 2,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 110),
        child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: new ChooseSocialsCard(
                    platformName: choosePlatforms[index],
                    soshiUsername: soshiUsername),
              );
            },
            itemCount: choosePlatforms.length),
      ),
    );
  }
}

abstract class Queue {
  static List<String> choosePlatformsQueue = [];
  static List<String> filteredChoosePlatformsQueue = [];
}
