import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassionsUtility {
  PassionsUtility({this.passionOptions, this.emojiLookup});

  List passionOptions = [
    'baseball',
    'coding',
    'basketball',
    'dance',
    'hockey',
    'video games',
    'food'
  ];

  Map emojiLookup = {
    'baseball': '⚾',
    'coding': '💻',
    'basketball': '🏀',
    'dance': '💃',
    'hockey': '🏑',
    'video games': '🎮',
    'food': '😋',
    'swimming': '🏊‍♀️',
    'running': '🏃‍♀️',
    'cars': '🚗',
    'movies': '🎥'
  };

  String getEmoji(String passion) {
    return emojiLookup[passion] ?? "";
  }
}

class PassionsPage extends StatefulWidget {
  // List presetEmojis = ["basketball", "hockey"];
  List presetEmojis;

  PassionsPage({Key key, @required this.presetEmojis}) : super(key: key);

  @override
  State<PassionsPage> createState() => _PassionsPageState();
}

class _PassionsPageState extends State<PassionsPage> {
  List renderPassions = [];
  TextEditingController controller = new TextEditingController();
  final ValueNotifier controlsGridView = ValueNotifier("GRIDVIEW_CONTROLLER");
  PassionsUtility passionsUtility = new PassionsUtility();

  fetchFirebasePassions() async {
    controller.clear();
    print("🔥🔥🔥🔥🟢 getting firebase passion data [fresh]");
    // await FirebaseFirestore.instance
    //     .collection("metadata")
    //     .doc("passionData")
    //     .update({'all_passions_list': emojiLookup});

    DocumentSnapshot dsnap = await FirebaseFirestore.instance
        .collection('metadata')
        .doc('passionData')
        .get();
    Map allPassionData = dsnap.get('all_passions_list');

    passionsUtility.emojiLookup = allPassionData;
    passionsUtility.passionOptions = allPassionData.keys.toList();

    renderPassions = allPassionData.keys.toList();
    print("ALLLLLL" + renderPassions.toString());

    for (int i = 0; i < widget.presetEmojis.length; i++) {
      if (widget.presetEmojis[i].containsKey("passion_name")) {
        print('❌ removing ${widget.presetEmojis[i]['passion_name']}');
        renderPassions.remove(widget.presetEmojis[i]['passion_name']);
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("filtered_passions", jsonEncode(renderPassions));
  }

  applyFilters() async {
    List passions = List.from(passionsUtility.passionOptions);
    print("all passions ${passions}");

    List finalFiltered = [];

    String cleanController = controller.text.toUpperCase().trim();
    for (int i = 0; i < passions.length; i++) {
      String curr = passions[i];
      if (curr.toUpperCase().contains(cleanController)) {
        finalFiltered.add(passions[i]);
      }
    }

    renderPassions = finalFiltered;
    print("passions after filtering: ${finalFiltered}");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("filtered_passions", jsonEncode(finalFiltered));
  }

  @override
  Widget build(BuildContext context) {
    print("Current passions: ${renderPassions}");
    return Container(
      // height: 400,
      // width: MediaQuery.of(context).size.width - 300,
      child: FutureBuilder(
          future: fetchFirebasePassions(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              // return SpinKitChasingDots(color: Colors.cyan, size: 80);
              return Container();
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: Text("Select your Passions"),
                  leading: IconButton(
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
                          TextField(
                            controller: controller,
                            // autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Type to search passions",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (newValue) async {
                              print("----> apply filters with ${newValue}");
                              await applyFilters();
                              controlsGridView.notifyListeners();
                            },
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: ValueListenableBuilder(
                                valueListenable: controlsGridView,
                                builder: (context, value, _) {
                                  return RenderPassionList(
                                      passionsUtility: passionsUtility);
                                }),
                          )
                        ],
                      )),
                ),
              );
            }
          })),
    );
  }
}

class RenderPassionList extends StatelessWidget {
  RenderPassionList({Key key, @required this.passionsUtility})
      : super(key: key);

  List renderPassions;
  PassionsUtility passionsUtility;

  fetchRenderList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("filtered_passions") != false) {
      renderPassions = jsonDecode(prefs.getString("filtered_passions"));
    }
  }

  @override
  Widget build(BuildContext context) {
    print("[✔] rebuilding gridView now!");

    return FutureBuilder(
        future: fetchRenderList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Icon(Icons.sync);
          } else {
            return GridView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return index == renderPassions.length
                      ? InkWell(
                          onTap: () {
                            print("just tapped passion: NONE!");
                            // String SoshiUsername = LocalDataService.getLocalUsername();
                            // DatabaseService DS = new DatabaseService(currSoshiUsernameIn: LocalDataService.getLocalUsername());
                            // DS.updateUserPassions(LocalDataService.getLocalUsername(), newPassions)
                            Navigator.pop(context, {
                              // 'passion_emoji': passionsUtility.getEmoji(renderPassions[index]),
                              // 'passion_name': renderPassions[index],
                              'valid': false
                            });
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("❌", style: TextStyle(fontSize: 35)),
                                  Text("Empty", style: TextStyle(fontSize: 14))
                                ]),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            print(
                                "just tapped passion: ${renderPassions[index]}");
                            // String SoshiUsername = LocalDataService.getLocalUsername();
                            // DatabaseService DS = new DatabaseService(currSoshiUsernameIn: LocalDataService.getLocalUsername());
                            // DS.updateUserPassions(LocalDataService.getLocalUsername(), newPassions)
                            Navigator.pop(context, {
                              'passion_emoji': passionsUtility
                                  .getEmoji(renderPassions[index]),
                              'passion_name': renderPassions[index],
                            });
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                      passionsUtility
                                          .getEmoji(renderPassions[index]),
                                      style: TextStyle(fontSize: 35)),
                                  Text(renderPassions[index],
                                      style: TextStyle(fontSize: 14))
                                ]),
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
                itemCount: renderPassions.length + 1);
          }
        });
  }
}
