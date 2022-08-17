import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soshi/services/dataEngine.dart';

class PassionsPage extends StatelessWidget {
  List<Passion> alreadySelected;

  PassionsPage({Key key, @required this.alreadySelected});

  List<Passion> renderPassions = [];
  TextEditingController searchController = TextEditingController();
  ValueNotifier controlsGridView = ValueNotifier("GRIDVIEW_CONTROLLER");

  List<Passion> original = [];

  // Need to pull passion data here. If you want latest set "firebaseOverride" to true;
  syncFirebasePassions() async {
    original = await DataEngine.getAvailablePasions(firebaseOverride: false);
    renderPassions = List.of(original);
    // Removing passions we already have selected from renderList
    renderPassions.removeWhere((element) {
      return alreadySelected.contains(element);
    });
    // searchController.clear();
  }

  applyFilters() {
    // Need to filter out Passions each searchText change.
    renderPassions = List.of(original);
    print("before applyFilters ==> ${renderPassions.length}");

    if (searchController.text == "") {
      return;
    }

    renderPassions.removeWhere((Passion element) {
      return element.name.toUpperCase().contains(searchController.text.toUpperCase()) == false;
    });

    print("after applyFilters ==> ${renderPassions.length}");
  }

  @override
  Widget build(BuildContext context) {
    print("Current passions: ${renderPassions}");
    return FutureBuilder(
        future: syncFirebasePassions(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container();
          } else {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                elevation: .5,
                title: Text(
                  "Select your Passions",
                  style: TextStyle(
                    letterSpacing: 1,
                    fontSize: MediaQuery.of(context).size.width / 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                        TextFormField(
                          controller: searchController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 20),
                            hintText: "Type to search passions",
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
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
                                return RenderPassionList(renderPassions: renderPassions);
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

class RenderPassionList extends StatelessWidget {
  List<Passion> renderPassions;

  RenderPassionList({Key key, @required this.renderPassions}) : super(key: key);

  empty() async {
    print("remove this FutureBuilder!");
    print(renderPassions);
  }

  @override
  Widget build(BuildContext context) {
    print("[✔] rebuilding gridView now!");

    return GridView.builder(
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              print("👆 just tapped passion: ${renderPassions[index]}");
              Navigator.pop(context, renderPassions[index]);
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text(renderPassions[index].emoji, style: TextStyle(fontSize: 35)),
                Text(renderPassions[index].name, style: TextStyle(fontSize: 14))
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
        itemCount: renderPassions.length);
  }
}
