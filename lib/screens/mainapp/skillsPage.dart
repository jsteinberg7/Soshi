import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soshi/services/dataEngine.dart';

class SkillsPage extends StatelessWidget {
  List<Skill> alreadySelected;

  SkillsPage({Key key, @required this.alreadySelected});

  List<Skill> renderSkills = [];
  TextEditingController searchController = TextEditingController();
  ValueNotifier controlsGridView = ValueNotifier("GRIDVIEW_CONTROLLER");

  List<Skill> original = [];

  // Need to pull skills data here. If you want latest set "firebaseOverride" to true;
  syncFirebaseSkill() async {
    original = await DataEngine.getAvailableSkills(firebaseOverride: false);
    renderSkills = List.of(original);
    // Removing skills we already have selected from renderList
    renderSkills.removeWhere((element) {
      return alreadySelected.contains(element);
    });

    //renderSkills.add(Defaults.emptySkill);
    // searchController.clear();
  }

  applyFilters() {
    // Need to filter out Skills each searchText change.
    renderSkills = List.of(original);
    print("before applyFilters ==> ${renderSkills.length}");

    if (searchController.text == "") {
      return;
    }

    renderSkills.removeWhere((Skill element) {
      return element.name
              .toUpperCase()
              .contains(searchController.text.toUpperCase()) ==
          false;
    });

    print("after applyFilters ==> ${renderSkills.length}");
  }

  @override
  Widget build(BuildContext context) {
    print("Current Skills: ${renderSkills}");
    return FutureBuilder(
        future: syncFirebaseSkill(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container();
          } else {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                elevation: .5,
                title: Text(
                  "Select your Skills",
                  style: TextStyle(
                    letterSpacing: 1,
                    fontSize: MediaQuery.of(context).size.width / 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  splashRadius: 1,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(CupertinoIcons.back),
                ),
              ),
              body: Center(
                child: Container(
                    width: MediaQuery.of(context).size.width - 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        TextFormField(
                          controller: searchController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 20),
                            hintText: "Type to search skills",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                          ),
                          onChanged: (newValue) {
                            print("----> apply filters with ${newValue}");
                            applyFilters();
                            controlsGridView.notifyListeners();
                          },
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: ValueListenableBuilder(
                              valueListenable: controlsGridView,
                              builder: (context, value, _) {
                                return RenderSkillsList(
                                    renderSkills: renderSkills);
                              }),
                        )
                      ],
                    )),
              ),
            );
          }
        }));
  }
}

class RenderSkillsList extends StatelessWidget {
  List<Skill> renderSkills;

  RenderSkillsList({Key key, @required this.renderSkills}) : super(key: key);

  empty() async {
    print("remove this FutureBuilder!");
    print(renderSkills);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    print("[✔] rebuilding gridView now!");

    return GridView.builder(
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              print("👆 just tapped skill: ${renderSkills[index].name}");
              Navigator.pop(
                  context, renderSkills[index].name); //renderSkills[index]);
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        // color: Colors.black,
                        width: width / 5,
                        //height: height / 45,
                        child: AutoSizeText(
                          renderSkills[index].name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(fontSize: width / 25),
                          minFontSize: 1,
                          //maxFontSize: width / 10,
                        ),
                      )
                    ]),
              ),
            ),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // number of items per row
          crossAxisCount: 3,
          // vertical spacing between the items
          mainAxisSpacing: 8,
          // horizontal spacing between the items
          crossAxisSpacing: 5,
        ),
        // number of items in your list
        itemCount: renderSkills.length);
  }
}
