import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:my_first_app/search.dart';
//import 'main.dart';

class ResetPassword extends StatefulWidget {
  @override
  @override
  _ResetPassword createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
  var _formKey = GlobalKey<FormState>();
  bool checkCurrentPasswordValid = true;
  final auth = FirebaseAuth.instance;

//var locator;
  @override
  Widget build(BuildContext context) {
    // DatabaseService databaseService = new DatabaseService(
    //     soshiUsernameIn: LocalDataService.getLocalUsernameForPlatform("Soshi"));

    TextEditingController resetPasswordEmailController = new TextEditingController();

    return Scaffold(
      //backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text(
          "Forgot Password",
          style: TextStyle(
              //color: Colors.cyan[200],
              fontSize: 25,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        //backgroundColor: Colors.grey[800],
        centerTitle: true,
      ),
      body: SafeArea(
          child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: Text(
                  "To reset your password, please enter the email associated with your Soshi account.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.cyan[600]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Row(
                  children: <Widget>[
                    Flexible(
                        child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                              //color: Colors.blueGrey,
                              fontSize: 15)),
                      controller: resetPasswordEmailController,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        //color: Colors.white
                      ),
                      textAlign: TextAlign.left,
                      //obscureText: _obscureTextCurrent,
                    )),
                  ],
                ),
              ),
              Constants.makeBlueShadowButton("Send Request", Icons.send, () async {
                String email = resetPasswordEmailController.text.trim().toLowerCase();
                try {
                  await auth.sendPasswordResetEmail(email: email);

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40.0))),
                          //backgroundColor: Colors.blueGrey[900],
                          title: Text(
                            "Email Successfully Sent",
                            style: TextStyle(
                              color: Colors.cyan[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            ("A password reset email has been sent to $email."),
                            style: TextStyle(fontSize: 20, color: Colors.cyan[700], fontWeight: FontWeight.bold),
                          ),
                          actions: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Done',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      });
                } catch (e) {
                  Navigator.of(context).pop();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40.0))),
                          //backgroundColor: Colors.blueGrey[900],
                          title: Text(
                            "Email Could Not Be Sent",
                            style: TextStyle(
                              // color: Colors.cyan[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            ("Please enter a valid email and try again."),
                            style: TextStyle(
                                fontSize: 20,
                                //color: Colors.cyan[700],
                                fontWeight: FontWeight.bold),
                          ),
                          actions: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 15.0),
                              child: TextButton(
                                child: Text(
                                  'Dismiss',
                                  style: TextStyle(fontSize: 20, color: Colors.blue),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        );
                      });
                }
              })
            ],
          ),
        ),
      )),
    );
  }
}
