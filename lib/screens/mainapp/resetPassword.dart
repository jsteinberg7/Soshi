import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soshi/constants/constants.dart';
import 'package:soshi/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/utilities.dart';
import '../../constants/widgets.dart';

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

    TextEditingController resetPasswordEmailController =
        new TextEditingController();
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);

    return Scaffold(
      //backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: .5,
        leading: CupertinoBackButton(),
        title: Text(
          "Reset password",
          style: TextStyle(
            // color: Colors.cyan[200],
            letterSpacing: 1,
            fontSize: width / 18,
            fontWeight: FontWeight.bold,
            //fontStyle: FontStyle.italic
          ),
        ),
        // backgroundColor: Colors.grey[850],
        centerTitle: true,

        //backgroundColor: Colors.grey[800],
      ),
      body: SafeArea(
          child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.fromLTRB(width / 25, height / 30, width / 25, 0),
                child: Text(
                    "To reset your password, please enter the email associated with your Soshi account.",
                    style: TextStyle(fontSize: width / 25)),
              ),
              SizedBox(
                height: height / 30,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(width / 25, 0, width / 25, 0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                        child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Email",
                      ),
                      // labelText: "Email",
                      // labelStyle: TextStyle(
                      //     //color: Colors.blueGrey,
                      //     fontSize: 15)),
                      controller: resetPasswordEmailController,
                      style: TextStyle(
                        //ontWeight: FontWeight.bold,
                        fontSize: 15,
                        //color: Colors.white
                      ),
                      textAlign: TextAlign.left,
                      //obscureText: _obscureTextCurrent,
                    )),
                  ],
                ),
              ),
              SizedBox(
                height: height / 40,
              ),
              TextButton(
                  child: Text("Send Request",
                      style: TextStyle(color: Colors.blue)),
                  onPressed: () async {
                    String email =
                        resetPasswordEmailController.text.trim().toLowerCase();
                    try {
                      await auth.sendPasswordResetEmail(email: email);

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40.0))),
                              //backgroundColor: Colors.blueGrey[900],
                              title: Text(
                                "Email Successfully Sent",
                                // style: TextStyle(
                                //   color: Colors.cyan[600],
                                //   fontWeight: FontWeight.bold,
                                // ),
                              ),
                              content: Text(
                                ("A password reset email has been sent to $email"),
                                style: TextStyle(
                                  fontSize: width / 25,
                                ),
                              ),

                              actions: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'Done',
                                        style: TextStyle(
                                            fontSize: width / 25,
                                            color: Colors.blue),
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
                      //Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40.0))),
                              //backgroundColor: Colors.blueGrey[900],
                              title: Text(
                                "Email Could Not Be Sent",
                                style: TextStyle(
                                    // color: Colors.cyan[600],
                                    //fontWeight: FontWeight.bold,
                                    ),
                              ),
                              content: Text(
                                ("Please enter a valid email and try again."),
                                style: TextStyle(
                                  fontSize: width / 25,
                                  //color: Colors.cyan[700],
                                  //fontWeight: FontWeight.bold
                                ),
                              ),
                              actions: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: TextButton(
                                    child: Text(
                                      'Ok',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.blue),
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
