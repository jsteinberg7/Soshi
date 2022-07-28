import 'package:flutter/material.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';

import '../../constants/widgets.dart';

// ignore: must_be_immutable
class ChooseSocialsCard extends StatefulWidget {
  String platformName, soshiUsername;

  ChooseSocialsCard({this.platformName, this.soshiUsername});

  _ChooseSocialsCardState createState() => _ChooseSocialsCardState();
}

class _ChooseSocialsCardState extends State<ChooseSocialsCard> {
  DatabaseService databaseService;
  String currSoshiUsername, platformName;
  var isSwitched = false;

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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: isSwitched
                    ?
                    //BorderSide(color: Colors.cyanAccent[100])
                    //BorderSide(color: Colors.white)
                    BorderSide.none
                    : BorderSide.none),
            elevation: 5,
            //color: Colors.grey[8,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.grey[850],
            child: Padding(
              // padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: 60,
                  ),
                  // SizedBox(width: width / 30),
                  Image.asset(
                    'assets/images/SMWriting/' + platformName + 'Writing.png',
                    height: (width * .31) / 1.8,
                    width: (width * .69) / 1.8,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        side: BorderSide(width: 1, color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        value: isSwitched,
                        checkColor: Colors.cyan[400],
                        activeColor: Colors.cyan[400],
                        onChanged: (bool value) {
                          setState(() {
                            isSwitched = !isSwitched;
                            if (!Queue.choosePlatformsQueue
                                .contains(platformName)) {
                              Queue.choosePlatformsQueue.add(platformName);
                            } else {
                              Queue.choosePlatformsQueue.remove(platformName);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            // alignment: Alignment.centerLeft,
            left: 0,
            top: 0,
            child: Image.asset(
                'assets/images/SMLogos/' + platformName + 'Logo.png',
                height: width / 4.5,
                width: width / 4.5),
          ),
        ],
      ),
    );
  }
}

class ChooseSocials extends StatefulWidget {
  @override
  _ChooseSocialsState createState() => _ChooseSocialsState();
}

class _ChooseSocialsState extends State<ChooseSocials> {
  DatabaseService databaseService;
  int numberSelected = 0;

  @override
  void dispose() {
    Queue.choosePlatformsQueue.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    numberSelected = 0;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    String soshiUsername =
        LocalDataService.getLocalUsernameForPlatform("Soshi");
    databaseService = new DatabaseService(currSoshiUsernameIn: soshiUsername);
    // List<String> choosePlatformsQueue = [];
    List<String> choosePlatforms = LocalDataService.getLocalChoosePlatforms();
    return Scaffold(
      appBar: AppBar(
        leading: CupertinoBackButton(),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: width / 150),
            child: TextButton(
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent)),
              child: Text(
                "Done",
                style: TextStyle(color: Colors.blue, fontSize: width / 23),
              ),
              onPressed: () async {
                DialogBuilder dialogBuilder = new DialogBuilder(context);
                dialogBuilder.showLoadingIndicator();

                /* this accounts for the edge case where there is a platform that 
            is in both profile platforms and choose socials. (only seen on emula)
            */
                for (int i = 0; i < Queue.choosePlatformsQueue.length; i++) {
                  if (LocalDataService.getLocalProfilePlatforms()
                      .contains(Queue.choosePlatformsQueue[i])) {
                    Queue.filteredChoosePlatformsQueue
                        .add(Queue.choosePlatformsQueue[i]);
                    Queue.choosePlatformsQueue
                        .remove(Queue.choosePlatformsQueue[i]);
                  }
                }
                LocalDataService.removeFromChoosePlatforms(
                    Queue.filteredChoosePlatformsQueue);

                // if platform has username, turn switch on
                for (String platform in Queue.choosePlatformsQueue) {
                  String username =
                      LocalDataService.getLocalUsernameForPlatform(platform);
                  if (username != null && username.length != 0) {
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
                dialogBuilder.hideOpenDialog(); // disable loading indicator

                // MAYBE NEED TO NOTIFY PROFILE LISTENER HERE!!!!

                Navigator.maybePop(context); // return to profile screen
                LocalDataService.removeFromChoosePlatforms(
                    Queue.choosePlatformsQueue);
                databaseService
                    .addPlatformsToProfile(Queue.choosePlatformsQueue);
                databaseService
                    .removeFromChoosePlatforms(Queue.choosePlatformsQueue);

                Navigator.pop(context);
              },
            ),
          )
        ],
        elevation: .5,

        title: Text(
          "Add Platforms",
          style: TextStyle(
            // color: Colors.cyan[200],
            letterSpacing: 1,
            fontSize: width / 18,
            fontWeight: FontWeight.bold,
            //fontStyle: FontStyle.italic
          ),
        ),
        // backgroundColor: Colors.grey[850],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: ChooseSocialsCard(
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
