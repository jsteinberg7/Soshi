import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    TextEditingController resetPasswordEmailController =
        new TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text(
          "Forgot Password",
          style: TextStyle(
              color: Colors.cyan[200],
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        backgroundColor: Colors.grey[800],
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
                  "To reset password, please enter your email",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.cyan[600]),
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
                          labelStyle:
                              TextStyle(color: Colors.blueGrey, fontSize: 15)),
                      controller: resetPasswordEmailController,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                      textAlign: TextAlign.left,
                      //obscureText: _obscureTextCurrent,
                    )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: FractionallySizedBox(
                  widthFactor: .7,
                  //heightFactor: .1,
                  child: RaisedButton(
                      elevation: 20,
                      color: Colors.grey[500],
                      padding: EdgeInsets.all(10),
                      onPressed: () async {
                        await auth.sendPasswordResetEmail(
                            email: resetPasswordEmailController.text.trim());
                        Navigator.of(context).pop();

                        // if (resetPasswordEmailController.text ==
                        //     Provider.of<User>(context, listen: true).email) {
                        //   return Scaffold(
                        //     body: Text("good"),
                        //   );
                        //   //carry on
                        // } else {
                        //   return Scaffold(body: Text("bad"));
                        //   //error message
                        // }
                        // if email controller equals the users' account email, proceed to confirmation email -> proceed to actually send email
                        // if email controller does not equal users's account email, show text that it's wrong
                      },
                      //   // var userController ==
                      //   //     locator.get<currentPassword>();
                      //   //var userController =

                      //   //checkCurrentPasswordValid = checkCurrentPassword();

                      //   if (_formKey.currentState.validate()) {
                      //     Navigator.pop(context);
                      //   }
                      // },
                      splashColor: Colors.cyan[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Text(
                        "Send Request",
                        style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
