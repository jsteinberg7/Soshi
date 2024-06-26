import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

// Basic wrapper for url services (all methods are static)
abstract class URL {
  // open browser to specified url target
  static launchURL(String url) async {
    try {
      await launch(url, forceWebView: false, forceSafariVC: false);
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
    if (username != "") {
      if (username[0] == '@') {
        username = username.replaceFirst('@', '');
      }
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
      if (platform.contains("tiktok.com")) {
        username.contains("https://")
            ? tiktokLink = username
            : tiktokLink = "https://" + username;
      } else {
        tiktokLink = "https://www.tiktok.com/@" + username;
      }
      return tiktokLink;
    } else if (platform == "Discord") {
      return "https://discordapp.com/users/" + username + "/";
    } else if (platform == "Phone") {
      return 'sms:' + username;
    } else if (platform == "Email") {
      return 'mailto:' + username;
    } else if (platform == "Spotify") {
      if (username.contains("https://open.spotify.com")) {
        return username;
      }
      return "https://open.spotify.com/user/" + username;
    } else if (platform == "Venmo") {
      if (Platform.isIOS) {
        return "venmo://paycharge?txn=pay&recipients=$username";
      }
      return "https://venmo.com/" + username;
    } else if (platform == "Contact") {
      // launch .vcf file
      return username;
    } else if (platform == "Personal") {
      String personalLink;
      username.contains("https://")
          ? personalLink = username
          : personalLink = "https://" + username;
      return personalLink;
    } else if (platform == "Youtube") {
      String youtubeLink;
      username.contains("https://")
          ? youtubeLink = username
          : youtubeLink = "https://www.youtube.com/channel/" + username;
      return youtubeLink;
    } else if (platform == "AppleMusic") {
      String appleMusicLink;
      username.contains("https://")
          ? appleMusicLink = username
          : appleMusicLink = "https://music.apple.com/us/artist/" + username;
      return appleMusicLink;
    } else if (platform == "Vsco") {
      return "https://vsco.co/" + username;
    } else if (platform == "CashApp") {
      return "https://cash.app/\$" + username;
    } else if (platform == "BeReal") {
      return "https://bere.al/" + username;
    } else if (platform == "OnlyFans") {
      return "https://onlyfans.com/" + username;
    }
  }
}
