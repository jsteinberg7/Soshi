import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:soshi/screens/mainapp/passionsPage.dart';
import 'package:soshi/services/dataEngine.dart';

class PassionTileList extends StatefulWidget {
  ValueNotifier profileScreenRefresher;
  PassionTileList({Key key, ValueNotifier profileScreenRefresher})
      : super(key: key);

  @override
  State<PassionTileList> createState() => _PassionTileListState();
}

class _PassionTileListState extends State<PassionTileList> {
  // loadDataEngine() async {
  //   // user = await DataEngine.getUserObject(firebaseOverride: false);
  //   user = DataEngine.globalUser;
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [0, 1, 2]
                .map((int pIndex) => makePassionTile(
                    DataEngine.globalUser.passions[pIndex], pIndex))
                .toList()));
  }

  pushAndUpdatePassions(Passion replace, int pIndex) async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: ((context) => PassionsPage(
                  alreadySelected: DataEngine.globalUser.passions,
                )))).then((value) async {
      print(value.toString());

      if (value != null) {
        DataEngine.globalUser.passions[pIndex] = value;
        DataEngine.applyUserChanges(
            user: DataEngine.globalUser, cloud: true, local: true);
        setState(() {});
        if (widget.profileScreenRefresher != null) {
          widget.profileScreenRefresher.notifyListeners();
        }
      }
    });
  }

  Widget makePassionTile(Passion passion, int pIndex) {
    return passion != Defaults.emptyPassion
        ? ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)))),
            onPressed: () async {
              pushAndUpdatePassions(passion, pIndex);
            },
            icon: Text(
              passion.emoji,
              style: TextStyle(fontSize: 15),
            ),
            label: Container(
              //color: Colors.green,
              width: MediaQuery.of(context).size.width / 7,
              child: AutoSizeText(
                passion.name,
                textAlign: TextAlign.center,
                maxLines: 1, //passion.name.contains(" ") ? 2 : 1,
                style:
                    TextStyle(fontSize: MediaQuery.of(context).size.width / 25),
                minFontSize: 1,
              ),
            ),
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
