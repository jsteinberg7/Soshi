import 'package:flutter/material.dart';
import 'package:soshi/screens/mainapp/passionsPage.dart';
import 'package:soshi/services/dataEngine.dart';

class PassionTileList extends StatefulWidget {
  PassionTileList({Key key}) : super(key: key);

  @override
  State<PassionTileList> createState() => _PassionTileListState();
}

class _PassionTileListState extends State<PassionTileList> {
  SoshiUser user;

  loadDataEngine() async {
    user = await DataEngine.getUserObject(firebaseOverride: true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadDataEngine(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Text("loading passions now...");
          } else {
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0, 1, 2].map((int pIndex) => makePassionTile(user.passsions[pIndex], pIndex)).toList());
          }
        });
  }

  pushAndUpdatePassions(Passion replace, int pIndex) async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: ((context) => PassionsPage(
                  alreadySelected: user.passsions,
                )))).then((value) async {
      print(value.toString());

      if (value != null) {
        user.passsions[pIndex] = value;
        await DataEngine.applyUserChanges(user: user, cloud: true, local: true);
        setState(() {});
      }
    });
  }

  Widget makePassionTile(Passion passion, int pIndex) {
    return passion != Defaults.emptyPassion
        ? ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15)))),
            onPressed: () async {
              pushAndUpdatePassions(passion, pIndex);
            },
            icon: Text(
              passion.emoji,
              style: TextStyle(fontSize: 15),
            ),
            label: Text(
              passion.name,
              style: TextStyle(fontSize: 15),
            ))
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                primary: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15)))),
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
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white, fontSize: 15),
            ));
  }
}
