import 'package:flutter/material.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:soshi/services/localData.dart';

import '../../constants/widgets.dart';

// ignore: must_be_immutable
class ChooseSocialsCard extends StatefulWidget {
  SoshiUser user;
  String platformName;

  ChooseSocialsCard({@required this.user, @required this.platformName});

  _ChooseSocialsCardState createState() => _ChooseSocialsCardState();
}

class _ChooseSocialsCardState extends State<ChooseSocialsCard> {
  @override
  void initState() {
    // isSwitched = widget.user.lookupSocial[widget.platformName].switchStatus;
    super.initState();
  }

  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        setState(() {
          isSwitched = !isSwitched;
          widget.user.lookupSocial[widget.platformName].isChosen = true;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),

            elevation: 5,
            //color: Colors.grey[8,
            color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey[700],
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
                    'assets/images/SMWriting/' + widget.platformName + 'Writing.png',
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
                            if (!Queue.choosePlatformsQueue.contains(widget.platformName)) {
                              Queue.choosePlatformsQueue.add(widget.platformName);
                            } else {
                              Queue.choosePlatformsQueue.remove(widget.platformName);
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
            child: Image.asset('assets/images/SMLogos/' + widget.platformName + 'Logo.png',
                height: width / 4.5, width: width / 4.5),
          ),
        ],
      ),
    );
  }
}

class ChooseSocials extends StatefulWidget {
  @override
  _ChooseSocialsState createState() => _ChooseSocialsState();

  SoshiUser user;
  ChooseSocials({@required this.user});
}

class _ChooseSocialsState extends State<ChooseSocials> {
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

    List<String> choosePlatforms = LocalDataService.getLocalChoosePlatforms();
    return Scaffold(
      appBar: AppBar(
        leading: CupertinoBackButton(),

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
                DialogBuilder dialogBuilder = new DialogBuilder(context);
                dialogBuilder.showLoadingIndicator();

                await DataEngine.applyUserChanges(user: widget.user, cloud: true, local: true);

                dialogBuilder.hideOpenDialog(); // disable loading indicator

                Navigator.pop(context);
              },
            ),
          )
        ],
        elevation: .5,

        title: Text(
          "Add Platforms",
          style: TextStyle(
            letterSpacing: 1,
            fontSize: width / 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // backgroundColor: Colors.grey[850],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: ChooseSocialsCard(platformName: choosePlatforms[index], user: widget.user),
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
