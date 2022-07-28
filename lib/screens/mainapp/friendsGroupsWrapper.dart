/*
A wrapper a around friendScreen and groupScreen
*/
import 'package:flutter/cupertino.dart';
import 'package:soshi/screens/mainapp/friendScreen.dart';
import 'package:soshi/screens/mainapp/groupScreen.dart';

import '../../constants/utilities.dart';

class FriendsGroupsWrapper extends StatefulWidget {
  @override
  State<FriendsGroupsWrapper> createState() => _FriendsGroupsWrapperState();
}

class _FriendsGroupsWrapperState extends State<FriendsGroupsWrapper> {
  int currPage;
  @override
  void initState() {
    super.initState();
    currPage = 0;
  }

  @override
  Widget build(BuildContext context) {
    double height = Utilities.getHeight(context);
    double width = Utilities.getWidth(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
              child: Column(
            children: [
              Container(
                width: width / 1.5,
                height: height / 15,
                child: CupertinoSlidingSegmentedControl(
                  children: {
                    0: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Friends',
                        // style: TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                    1: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Groups',
                        // style: TextStyle(color: CupertinoColors.white),
                      ),
                    )
                  },
                  onValueChanged: (value) {
                    setState(() {
                      currPage = value;
                    });
                  },
                  groupValue: currPage,
                ),
              ),
              Container(
                height: height / 1.25,
                child: currPage == 0 ? FriendScreen() : GroupScreenComingSoon(),
              )
            ],
          )),
        ),
      ),
    );
  }
}
