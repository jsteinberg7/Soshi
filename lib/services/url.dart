import 'package:url_launcher/url_launcher.dart';
import 'package:soshi/services/localData.dart';

// Basic wrapper for url services (all methods are static)
abstract class URL {
  // open browser to specified url target
  static void launchURL(String url) async {
    try {
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
    } catch (e) {
      // to avoid app crash
      print(e);
    }
  }

  // return custom url for platform and username
  // note: some platforms use a system not invloving usernames
  // (Linkedin, Facebook, Tiktok use a numbering system)
  static String getPlatformURL({String platform, String username}) {
    username = username.trim(); // remove whitespaces
    if (username[0] == '@') {
      username = username.replaceFirst('@', '');
    }
    if (platform == "Instagram") {
      return "https://www.instagram.com/" + username + "/?hl=en";
    } else if (platform == "Snapchat") {
      return "https://www.snapchat.com/add/" + username;
    } else if (platform == "Twitter") {
      return "https://mobile.twitter.com/" + username;
    } else if (platform == "Linkedin") {
      String linkedInLink;
      username.contains("https://")
          ? linkedInLink = username
          : linkedInLink = "https://" + username;
      return linkedInLink;
    } else if (platform == "Facebook") {
      String facebookLink;
      username.contains("https://")
          ? facebookLink = username
          : facebookLink = "https://" + username;
      return facebookLink;
    } else if (platform == "Reddit") {
      return "https://www.reddit.com/user/" + username + "/";
    } else if (platform == "Tiktok") {
      String tiktokLink;
      username.contains("https://")
          ? tiktokLink = username
          : tiktokLink = "https://" + username;
      return tiktokLink;
    } else if (platform == "Discord") {
      return "https://discordapp.com/users/" + username + "/";
    } else if (platform == "Phone") {
      return 'sms:' + username;
    } else if (platform == "Email") {
      return 'mailto:' + username;
    } else if (platform == "Spotify") {
      return "https://open.spotify.com/user/" + username;
    } else if (platform == "Venmo") {
      return "https://venmo.com/" + username;
    } else if (platform == "Contact") {
      // launch .vcf file
      return username;
    }
  }
}