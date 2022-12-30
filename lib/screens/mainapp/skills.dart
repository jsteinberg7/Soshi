import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:soshi/screens/mainapp/skillsPage.dart';
import 'package:soshi/services/dataEngine.dart';

class SkillTileList extends StatefulWidget {
  ValueNotifier profileScreenRefresher;
  SkillTileList({Key key, ValueNotifier profileScreenRefresher})
      : super(key: key);

  @override
  State<SkillTileList> createState() => _SkillTileListState();
}

class _SkillTileListState extends State<SkillTileList> {
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
                .map((int pIndex) =>
                    makeSkillTile(DataEngine.globalUser.skills[pIndex], pIndex))
                .toList()));
  }

  pushAndUpdateSkills(Skill replace, int pIndex) async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: ((context) => SkillsPage(
                  alreadySelected: DataEngine.globalUser.skills,
                )))).then((value) async {
      if (value != null) {
        DataEngine.globalUser.skills[pIndex] = Skill(name: value);
        DataEngine.applyUserChanges(
            user: DataEngine.globalUser, cloud: true, local: true);
        setState(() {});
        if (widget.profileScreenRefresher != null) {
          widget.profileScreenRefresher.notifyListeners();
        }
      }
    });
  }

  Widget makeSkillTile(Skill skill, int pIndex) {
    return skill != Defaults.emptySkill
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.grey[850],
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)))),
            onPressed: () async {
              pushAndUpdateSkills(skill, pIndex);
            },
            child: Container(
                // color: Colors.green,
                height: MediaQuery.of(context).size.width / 18,
                width: MediaQuery.of(context).size.width / 4.5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    skill.name,
                    textAlign: TextAlign.center,
                    maxLines: 1, //passion.name.contains(" ") ? 2 : 1,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 27),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                // child: AutoSizeText(
                //   skill.name,
                //   textAlign: TextAlign.center,
                //   maxLines: 1, //passion.name.contains(" ") ? 2 : 1,
                //   style:
                //       TextStyle(fontSize: MediaQuery.of(context).size.width / 25),
                //   minFontSize: 1,
                // ),
                ),
          )
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                primary: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)))),
            onPressed: () async {
              pushAndUpdateSkills(skill, pIndex);
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
