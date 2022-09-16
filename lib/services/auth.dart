import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/dataEngine.dart';
import 'package:soshi/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

/*
Provides various methods for user sign in, registration, and sign out
*/
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User> get user {
    return _auth.authStateChanges();
  }

  // sign in with email and password
  Future signInWithEmailAndPassword({String emailIn, String passwordIn, BuildContext contextIn, @required Function refreshIn}) async {
    try {
      UserCredential loginResult = await _auth.signInWithEmailAndPassword(email: emailIn, password: passwordIn); // signs user in, initiates login

      User user = loginResult.user;
      log("SOSHI USERNAME UPDATE: " + user.uid);

      await FirebaseFirestore.instance.collection("emailToUsername").doc(emailIn).get().then((value) async {
        String soshiUsername = value.get("soshiUsername");

        await DataEngine.freshSetup(soshiUsername: soshiUsername);
      });

      Analytics.setUserAttributes(userId: user.uid);
      Analytics.logSignIn('email');

      print("✅ successfully logged into account! ${emailIn}");
      return user;
    } catch (e) {
      print("❌ LOGIN ERROR");

      print("Login Error: " + e.toString());

      // return e.toString();
      return "Incorrect password, try again";
    }

    //return a pop up or some shit
  }

  // sign in with Google
  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    String soshiUsername = null;

    // Trigger the authentication flow

    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    try {
      // check if user already exists with email
      soshiUsername = DataEngine.soshiUsername.toLowerCase().trim();
      Analytics.logSignIn('google');
    } catch (e) {
      debugPrint(e);
    }

    if (soshiUsername == null) {
      // if user doesn't exist, create new user
      // create new user
      // set username to part of google email before @
      soshiUsername = googleUser.email.split('@')[0];

      // use username to create user file
      DatabaseService databaseService = new DatabaseService(currSoshiUsernameIn: soshiUsername);
      await databaseService.createUserFile(
          username: soshiUsername.toLowerCase().trim(),
          email: googleUser.email,
          first: googleUser.displayName.split(" ")[0],
          last: googleUser.displayName.split(" ")[1]);

      if (await canLaunch(googleUser.photoUrl)) {
        // import photo from google
        databaseService.updateUserProfilePictureURL(googleUser.photoUrl);
      }
      Analytics.logSignUp('google');
    }

    // initialize shared preferences
    // await LocalDataService.initializeSharedPreferences(
    //     currSoshiUsername: soshiUsername);

    // LocalDataService.initializeSharedPreferences(soshiUsername: googleUser.displayName);
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // register new user with email and password
  dynamic registerWithEmailAndPassword({
    String email,
    String username,
    String password,
    String first,
    String last,
    BuildContext contextIn,
  }) async {
    try {
      DatabaseService databaseService = DatabaseService(currSoshiUsernameIn: username);
      if (await databaseService.isUsernameTaken(username)) {
        throw new ErrorDescription("Username is taken, try another one");
      }

      await DataEngine.freshSetup(soshiUsername: username);

      await databaseService.createUserFile(username: username, email: email, first: first, last: last);
      print("file created");

      print("shared prefs initialized");
      UserCredential registerResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = registerResult.user;
      // refreshIn();
      print("✅ successfully created new account! ${email}");

      print("◀◀◀ username ${username}\n email ${email} \n password ${password} \n ${first} \n ${last} ◀◀◀");

      return user;
    } catch (e) {
      print("❌ Error unable to create new account, returning error");
      print(e.toString());
      return e.toString();
      // return null;
    }
  }

  // sign user out of app
  Future<void> signOut() async {
    // wipe local data
    // LocalDataService.wipeSharedPreferences();
    // LocalDataService.updateFirstLaunch(true);

    Analytics.logSignOut();
    return await _auth.signOut();
  }

  Future<void> deleteProfile() async {
    return await _auth.currentUser.delete();
  }
}
