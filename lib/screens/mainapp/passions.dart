import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soshi/screens/mainapp/passionsPage.dart';
import 'package:soshi/services/database.dart';
import 'package:soshi/services/localData.dart';

class PassionTileList extends StatefulWidget {
  const PassionTileList({Key key}) : super(key: key);

  @override
  State<PassionTileList> createState() => _PassionTileListState();
}

class _PassionTileListState extends State<PassionTileList> {
  // List passionsThree = LocalDataService.getPassionsListLocal();
  List passionsThree = [];

  passionsCleanup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // await prefs.setString("passions", jsonEncode([]));

    int len = 0;
    try {
      passionsThree = jsonDecode(prefs.getString("passions"));
      len = passionsThree.length;
    } catch (e) {
      passionsThree = [];
    }

    print("latest passions= ${passionsThree}");
    print("⚠⚠⚠⚠⚠ " + passionsThree.toString());
    for (int i = 0; i < 3 - len; i++) {
      print("[i ${i}] adding !!!!");
      passionsThree.add({'valid': false});
    }
    print('after for loop adding 👆👆👆👆👆 ${passionsThree}');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: passionsCleanup(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Icon(Icons.sync);
          } else {
            return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // children: passionsThree.map((e) => makePassionTile(e)).toList());
                children: [
                  makePassionTile(
                    passionsThree[0],
                    0,
                  ),
                  makePassionTile(
                    passionsThree[1],
                    1,
                  ),
                  makePassionTile(
                    passionsThree[2],
                    2,
                  ),
                ]);
          }
        });
  }

  pushAndUpdatePassions(int index) async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: ((context) => PassionsPage(
                  presetEmojis: this.passionsThree,
                )))).then((value) async {
      print(value.toString());

      if (value != null) {
        passionsThree[index] = value;
        print('after empty add: ${passionsThree}');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("passions", jsonEncode(passionsThree));
        // await LocalDataService.updatePassions(passionsThree);
        String soshiUsername =
            LocalDataService.getLocalUsernameForPlatform("Soshi");
        DatabaseService dbService =
            new DatabaseService(currSoshiUsernameIn: soshiUsername);
        await dbService.updateUserPassions(soshiUsername, passionsThree);
        setState(() {});
      }
    });
  }

  Widget makePassionTile(Map passion, int index) {
    return passion.containsKey('passion_name')
        ? ElevatedButton.icon(
            style: ElevatedButton.styleFrom(elevation: 3),
            onPressed: () async {
              pushAndUpdatePassions(index);
            },
            icon: Text(
              // PassionsUtility.getEmoji(passion),
              passion['passion_emoji'].toString(),
              style: TextStyle(fontSize: 15),
            ),
            label: Text(
              passion['passion_name'].toString(),
              style: TextStyle(fontSize: 15),
            ))
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(primary: Colors.black),
            onPressed: () async {
              pushAndUpdatePassions(index);
            },
            icon: Text(
              '❓',
              style: TextStyle(fontSize: 15),
            ),
            label: Text(
              "Empty",
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 15),
            ));
  }
}
