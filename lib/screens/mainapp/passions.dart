import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:soshi/screens/mainapp/passionsPage.dart';
import 'package:soshi/services/dataEngine.dart';

class PassionTileList extends StatefulWidget {
  SoshiUser user;
  PassionTileList({@required SoshiUser user});

  @override
  State<PassionTileList> createState() => _PassionTileListState();
}

class _PassionTileListState extends State<PassionTileList> {
  SoshiUser user;

  loadDataEngine() async {
    user = await DataEngine.getUserObject(firebaseOverride: false);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return FutureBuilder(
        future: loadDataEngine(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else {
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0, 1, 2]
                    .map((int pIndex) =>
                        makePassionTile(this.user.passions[pIndex], pIndex))
                    .toList());
          }
        });
  }

  pushAndUpdatePassions(Passion replace, int pIndex) async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: ((context) => PassionsPage(
                  alreadySelected: user.passions,
                )))).then((value) async {
      print(value.toString());

      if (value != null) {
        user.passions[pIndex] = value;
        await DataEngine.applyUserChanges(user: user, cloud: true, local: true);
        setState(() {});
      }
    });
  }

  Widget makePassionTile(Passion passion, int pIndex) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return passion != Defaults.emptyPassion
        ? ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
            onPressed: () async {
              pushAndUpdatePassions(passion, pIndex);
            },
            icon: Text(
              passion.emoji,
              style: TextStyle(fontSize: width / 20),
            ),
            label: Container(
              //color: Colors.green,
              width: width / 7,
              child: AutoSizeText(
                passion.name,
                textAlign: TextAlign.center,
                maxLines: 1, //passion.name.contains(" ") ? 2 : 1,
                style: TextStyle(fontSize: width / 25),
                minFontSize: 1,
              ),
            ),

            // Text(
            //   passion.emoji,
            //   style: TextStyle(fontSize: width / 25),
            // ),
            // label: Container(
            //   color: Colors.green,
            //   width: width / 6,
            //   child: AutoSizeText(
            //     passion.name,
            //     textAlign: TextAlign.center,
            //     maxLines: 1, //passion.name.contains(" ") ? 2 : 1,
            //     style: TextStyle(fontSize: width / 25),
            //     minFontSize: 1,
            //   ),
            // )
          )
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                primary: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)))),
            onPressed: () async {
              pushAndUpdatePassions(passion, pIndex);
            },
            icon: Text(
              '➕',
              style: TextStyle(fontSize: 15),
            ),
            label: Text(
              "Add",
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 15),
            ));
  }
}
