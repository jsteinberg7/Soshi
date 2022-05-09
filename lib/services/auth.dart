import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:soshi/screens/login/loginscreen.dart';
import 'package:soshi/services/analytics.dart';
import 'package:soshi/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soshi/services/url.dart';
import 'localData.dart';
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
  Future signInWithEmailAndPassword(
      {String emailIn,
      String passwordIn,
      BuildContext contextIn,
      @required Function refreshIn}) async {
    try {
      String soshiUsername =
          await DatabaseService().getSoshiUsernameForLogin(email: emailIn);
      await LocalDataService.initializeSharedPreferences(
          currSoshiUsername: soshiUsername); // sync all local data with cloud
      UserCredential loginResult = await _auth.signInWithEmailAndPassword(
          email: emailIn,
          password: passwordIn); // signs user in, initiates login
      User user = loginResult.user;
      Analytics.setUserAttributes(userId: user.uid);
      Analytics.logSignIn('email');
      refreshIn();
      return user;
    } catch (e) {
      print("Login Error: " + e.toString());
      showDialog(
        context: contextIn,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            backgroundColor: Colors.blueGrey[900],
            title: Text(
              "Invalid Credentials. \n",
              style: TextStyle(
                  color: Colors.cyan[600], fontWeight: FontWeight.bold),
            ),
            content: Text(
              "If needed, you can reset your password.",
              style: TextStyle(
                  color: Colors.cyan[700], fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // body: SnackBar(
      // content: const Text('Invalid Credentials!'),
      // backgroundColor: (Colors.black12),
      // action: SnackBarAction(
      // label: 'dismiss',
      // onPressed: () {},
      // ),
      // ),

// return Scaffold(
      // body: SnackBar(action: ,),
//),

    }

    //return a pop up or some shit
  }

  // sign in with Google
  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    String soshiUsername = null;

    // Trigger the authentication flow

    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    try {
      // check if user already exists with email
      soshiUsername = await DatabaseService()
          .getSoshiUsernameForLogin(email: googleUser.email);
      soshiUsername = soshiUsername.toLowerCase().trim();
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
      DatabaseService databaseService =
          new DatabaseService(currSoshiUsernameIn: soshiUsername);
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
    await LocalDataService.initializeSharedPreferences(
        currSoshiUsername: soshiUsername);

    // LocalDataService.initializeSharedPreferences(soshiUsername: googleUser.displayName);
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // register new user with email and password
  Future<User> registerWithEmailAndPassword(
      {String email,
      String username,
      String password,
      String first,
      String last,
      BuildContext contextIn,
      @required refreshIn}) async {
    try {
      DatabaseService databaseService =
          DatabaseService(currSoshiUsernameIn: username);
      if (await databaseService.isUsernameTaken(username)) {
        throw new ErrorDescription("Username is already in use.");
      }

      await databaseService.createUserFile(
          username: username, email: email, first: first, last: last);
      print("file created");
      await LocalDataService.initializeSharedPreferences(
          currSoshiUsername: username);
      print("shared prefs initialized");
      UserCredential registerResult = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = registerResult.user;
      refreshIn();
      return user;
    } catch (e) {
      showDialog(
          context: contextIn,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0))),
              backgroundColor: Colors.blueGrey[900],
              title: Text(
                "Error",
                style: TextStyle(
                    color: Colors.cyan[600], fontWeight: FontWeight.bold),
              ),
              content: Text(
                e.toString(),
                style: TextStyle(
                    color: Colors.cyan[700], fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Ok',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
      return null;
    }
  }

  // sign user out of app
  Future<void> signOut() async {
    // wipe local data
    LocalDataService.wipeSharedPreferences();
    LocalDataService.updateFirstLaunch(true);
    Analytics.logSignOut();
    return await _auth.signOut();
  }

  Future<void> deleteProfile() async {
    return await _auth.currentUser.delete();
  }
}
