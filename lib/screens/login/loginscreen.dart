import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Importing packages and certain files
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:soshi/screens/login/register.dart';
import 'package:soshi/screens/mainapp/resetPassword.dart';
import 'package:soshi/services/auth.dart';
import 'loginstyle.dart';
import 'package:soshi/constants/constants.dart';
import 'package:the_validator/the_validator.dart';
import 'package:soshi/screens/login/loading.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();

  Function changeIsRegisteringState;
  Function refreshWrapper;

  LoginScreen({@required Function toggleScreen, @required refresh}) {
    this.changeIsRegisteringState = toggleScreen;
    this.refreshWrapper = refresh;
  }
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;

  final AuthService _authService =
      AuthService(); // Authentication service for connecting Firebase

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final emailKey = GlobalKey<FormState>();
  final passwordKey = GlobalKey<FormState>();

  bool showEnabled = false;

/* This widget is building the Email Box where users enter their email associated with their Soshi account */
  Widget _buildEmailTF() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Email',
            style: TextStyle(
                // color: Colors.cyan[600],
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Form(
              key:
                  emailKey, // This is the emailKey that is used to validate that the user is entering a valid email
              child: TextFormField(
                textInputAction: TextInputAction.next,
                autofillHints: [AutofillHints.email],
                validator: FieldValidator.email(
                    message:
                        "Invalid Email format"), // The validator package uses this to confirm a valid email
                controller:
                    _emailController, // Controllers are used as basically a text cursor, a way to input text from the keyboard
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  // color: Colors.white,
                  fontFamily: 'OpenSans',
                ),

                onChanged: (text) {
                  setState(() {});
                },

                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        // color: Colors.white
                        ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan),
                  ), //border: InputBorder.,
                  contentPadding: EdgeInsets.only(top: 14.0),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  hintText: 'Enter your Email',
                  // hintStyle:
                  // kHintTextStyle,
                ),
              ),
            ),
          ),
          //),
        ],
      ),
    );
  }

/* This widget is building the Password Box where users enter their password associated with their Soshi account */
  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: TextStyle(
              // color: Colors.cyan[600],
              fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Form(
            key: passwordKey,
            child: TextFormField(
              validator: FieldValidator.password(
                  // Validating that the password is a minimum of 8 characters
                  minLength: 8,
                  errorMessage: "Minimum of 8 characters"),
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(
                // color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              onChanged: (text) {
                setState(() {});
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      // color:
                      // Colors.white
                      ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
                hintText: 'Enter your Password',
                // hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }

/* This Widget creates the "Forgot password" button that redirects the user to the forgot password screen */
  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // On pressed attribute is where you declare what happens when you press the button
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ResetPassword(); // Returning the ResetPassword screen
          }));
        },
        child: Text('Forgot Password?',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[700]
                    : Colors.grey[500],
                fontWeight: FontWeight.bold)),
      ),
    );
  }

/* This widget creates the Log in button which basically validates that the email and password match a pair in Firebase */
  Widget _buildLoginBtn() {
    setState(() {
      showEnabled = EmailValidator.validate(this._emailController.text) &&
              this._passwordController.text.length >= 8
          ? true
          : false;
    });
    return Container(
      height: 120,
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        // elevation: 20,
        onPressed: () async {
          // Checking to see if email and password are a pair in Firebase when button is clicked
          if (emailKey.currentState.validate() &&
              passwordKey.currentState.validate()) {
            setState(() {
              loading = true;
            });
            User loginResult = await _authService.signInWithEmailAndPassword(
                emailIn: _emailController.text,
                passwordIn: _passwordController.text,
                contextIn: context,
                refreshIn: widget.refreshWrapper);
            // added in update to avoid infinite loading
            // if (Platform.isAndroid) {
            //   // Navigator.pop(context);
            // }
            // used to pop off loading screen
            

            // acknowledge login attempt
            if (loginResult == null) {
              setState(() {
                loading = false;
              });
            }
          }
        },
        style: showEnabled
            ? ElevatedButton.styleFrom(
                primary: Colors.cyanAccent,
                side: BorderSide(color: Colors.cyan[400], width: 2),
                elevation: 20,
                padding: const EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              )
            : ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 168, 169, 169),
                side: BorderSide(color: Colors.black54, width: 2),
                elevation: 20,
                padding: const EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),

        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LOGIN',
                style: TextStyle(
                  color: Colors.black,
                  letterSpacing: 2,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
              ),
              // LottieBuilder.asset(
              //   "assets/images/animations/rightArrow.json",
              //   height: 20,
              //   width: 20,
              // )

              // Lottie.asset("assets/images/animations/rightArrow.json")
              // OverflowBox(
              //     maxWidth: 100,
              //     minHeight: 10,
              //     child: SizedBox(width: 300, height: 50, child: Lottie.network("https://assets4.lottiefiles.com/packages/lf20_6UVhfF.json")))

              showEnabled
                  ? SizedBox(
                      // height: 50,
                      width: 100,
                      child: OverflowBox(
                        minHeight: 170,
                        maxHeight: 170,
                        child: Lottie.network(
                          "https://assets4.lottiefiles.com/packages/lf20_6UVhfF.json",
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

/* This widget is to be used in the future when we have the ability to sign in with Google, facebook, and whatnot */
  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            // color: Colors.cyan[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        //SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Text('Sign in with',
              style: TextStyle(
                  // color:
                  // Colors.cyan[600],
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  /* Button for signing in with external service */
  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

/* This widget is to be used in the future, goes hand in hand with the previous 2 widgets of signing in with other media */
  Widget _buildSocialBtnRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // _buildSocialBtn(
          //   () async => await _authService.signInWithText(contextIn: context),
          //   AssetImage(
          //     'assets/images/SMLogos/FacebookLogo.png',
          //   ),
          // ),
          _buildSocialBtn(
            // sign in with google
            () async {
              setState(() {
                loading = true;
              });

              dynamic loginResult =
                  await _authService.signInWithGoogle(context);

              // acknowledge login attempt
              if (loginResult == null) {
                setState(() {
                  loading = false;
                });
              }
            },
            AssetImage('assets/images/SMLogos/GoogleLogo.png'),
          ),
        ],
      ),
    );
  }

/* This widget creates a button that redirects the user to the sign up screen */
  Widget _buildSignupBtn() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text('Don\'t have an Account?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Icon(
            Icons.arrow_forward_sharp,
            size: 20,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          ElevatedButton(
            onPressed: () {
              widget.changeIsRegisteringState(true);
            },
            child: Text(
              "Register!",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 20,
              side: BorderSide(color: Colors.cyan[400]),
              primary: Colors.cyanAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ]);
  }

  // // used to pop off loading screen
  // void refresh() {
  //   setState(() {});
  // }

/* This is the build of the screen, basically using all the previous widgets to create our full fleshed log in screen */
  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : AnnotatedRegion<SystemUiOverlayStyle>(
            // Specifies the style to use for the system overlays that are visible
            value: SystemUiOverlayStyle.light,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: <Widget>[
                  Container(
                      //color: Colors.grey[850],
                      ),
                  Container(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 35.0,
                        vertical: 15.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                // color: Colors.cyan[600],
                                fontFamily: 'OpenSans',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: _buildEmailTF(),
                          ),
                          _buildPasswordTF(),
                          _buildForgotPasswordBtn(),
                          _buildLoginBtn(),
                          //_buildSignInWithText(), // Keep this commented for future use
                          //_buildSocialBtnRow(context),
                          _buildSignupBtn(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
