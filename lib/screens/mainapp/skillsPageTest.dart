import 'dart:developer';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:soshi/screens/mainapp/skillsPage.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import '../../constants/popups.dart';
import '../../constants/utilities.dart';
import '../../constants/widgets.dart';
import '../../services/contacts.dart';
import '../../services/database.dart';
import '../login/loading.dart';

class SkillsPageTest extends StatefulWidget {
  List<Skill> alreadySelected;

  SkillsPageTest({Key key, @required this.alreadySelected});

  @override
  State<SkillsPageTest> createState() => _SkillsPageTestState();
}

class _SkillsPageTestState extends State<SkillsPageTest> {
  //List<Skill> renderSkills = [];
  List<Skill> totalSkills;
  ValueNotifier controlsGridView = ValueNotifier("GRIDVIEW_CONTROLLER");

  Stream<List<Skill>> getLatestSkillsCollection = (() async* {
    List<Skill> totalSkills = await getLatestSkillData() ?? [];
    yield totalSkills;
    // Call database for list of skills
  })();

  //   applyFilters() {
  //   // Need to filter out Skills each searchText change.
  //   renderSkills = List.of(totalSkills);

  //   if (searchController.text == "") {
  //     return;
  //   }

  //   renderSkills.removeWhere((Skill element) {
  //     return element.name
  //             .toUpperCase()
  //             .contains(searchController.text.toUpperCase()) ==
  //         false;
  //   });

  // }

  @override
  Widget build(BuildContext context) {
    double width = Utilities.getWidth(context);
    TextEditingController skillController = TextEditingController();

    return Container(
        child: StreamBuilder<List<Skill>>(
            stream: getLatestSkillsCollection,
            builder:
                (BuildContext context, AsyncSnapshot<List<Skill>> snapshot) {
              if (snapshot.hasError) {}

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator.adaptive());
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
                            // SizedBox(height: 20),
                            // TextFormField(
                            //   controller: searchController,
                            //   decoration: InputDecoration(
                            //     contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 20),
                            //     hintText: "Type to search skills",
                            //     border: OutlineInputBorder(
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(30))),
                            //   ),
                            //   onChanged: (newValue) {
                            //     print("----> apply filters with ${newValue}");
                            //     applyFilters();
                            //     controlsGridView.notifyListeners();
                            //   },
                            // ),
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  primary: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  padding: EdgeInsets.fromLTRB(50, 0, 50, 0)),
                              child: Text(
                                "Add",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: Utilities.getWidth(context) / 20,
                                    color: Colors.white),
                              ),
                              onPressed: () async {
                                await Popups.customSkillPopup(
                                    context, width, skillController);

                                String skillFromController =
                                    toBeginningOfSentenceCase(
                                        skillController.text.trim());

                                if (skillFromController.length > 0) {
                                  Future.delayed(Duration(milliseconds: 10),
                                      () {
                                    Navigator.pop(context, skillFromController);
                                  });
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: ValueListenableBuilder(
                                  valueListenable: controlsGridView,
                                  builder: (context, value, _) {
                                    return RenderSkillsList(
                                        renderSkills: totalSkills);
                                  }),
                            ),
                          ],
                        )),
                  ),
                );
              }
            }));
  }
}
