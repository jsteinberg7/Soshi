// import 'package:soshi/services/database.dart';
// import 'package:soshi/services/localData.dart';

// class InjectionHander {
//   static checkInjections(String soshiUsername, DatabaseService databaseService) {
//     bool soshiPointsInjection = LocalDataService.getInjectionFlag("Soshi Points");

//     if (soshiPointsInjection == false || soshiPointsInjection == null) {
//       LocalDataService.updateInjectionFlag("Soshi Points", true);
//       databaseService.updateInjectionSwitch(soshiUsername, "Soshi Points", true);

//       int numFriends = LocalDataService.getFriendsListCount();
//       LocalDataService.updateSoshiPoints(numFriends * 8);

//       databaseService.updateSoshiPoints(soshiUsername, (numFriends * 8));
//     }

//     bool profilePicFlagInjection = LocalDataService.getInjectionFlag("Profile Pic");
//     print(profilePicFlagInjection.toString());

//     if (profilePicFlagInjection == false || profilePicFlagInjection == null) {
//       if (LocalDataService.getLocalProfilePictureURL() != "null") {
//         LocalDataService.updateInjectionFlag("Profile Pic", true);
//         databaseService.updateInjectionSwitch(soshiUsername, "Profile Pic", true);
//         LocalDataService.updateSoshiPoints(10);

//         databaseService.updateSoshiPoints(soshiUsername, 10);
//       } else {
//         LocalDataService.updateInjectionFlag("Profile Pic", false);
//         databaseService.updateInjectionSwitch(soshiUsername, "Profile Pic", false);
//       }
//     }

//     bool bioFlagInjection = LocalDataService.getInjectionFlag("Bio");
//     if (bioFlagInjection == false || bioFlagInjection == null) {
//       if (LocalDataService.getBio() != "" || LocalDataService.getBio() == null) {
//         LocalDataService.updateInjectionFlag("Bio", true);
//         databaseService.updateInjectionSwitch(soshiUsername, "Bio", true);
//         LocalDataService.updateSoshiPoints(10);

//         databaseService.updateSoshiPoints(soshiUsername, 10);
//       } else {
//         LocalDataService.updateInjectionFlag("Bio", false);
//         databaseService.updateInjectionSwitch(soshiUsername, "Bio", false);
//       }
//     }

//     // For now, just injecting passions flag field
//     LocalDataService.updateInjectionFlag("Passions", false);
//     databaseService.updateInjectionSwitch(soshiUsername, "Passions", false);
//   }
// }
