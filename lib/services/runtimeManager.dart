import 'package:shared_preferences/shared_preferences.dart';

class RuntimeManager {
  static bool hasLaunched = false;
  static bool completedFirstSwitch = false;
  static bool viewedFriendsScreen = false;

  static sync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hasLaunched = prefs.getBool("hasLaunched");
    completedFirstSwitch = prefs.getBool("completedFirstSwitch");
    viewedFriendsScreen = prefs.getBool("viewedFriendsScreen");
  }
}
