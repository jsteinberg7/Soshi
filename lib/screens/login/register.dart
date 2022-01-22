import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/screens/mainapp/resetPassword.dart';
import 'package:soshi/services/auth.dart';
import 'package:soshi/services/localData.dart';
import 'loginscreen.dart';
import 'package:the_validator/the_validator.dart';

import 'loginstyle.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();

  // call this function when navigating back to login screen
  Function toggleIsRegistering;

  RegisterScreen({Function toggleScreen}) {
    this.toggleIsRegistering = toggleScreen;
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final emailKeyRegister = GlobalKey<FormState>();
  final passwordKeyRegister = GlobalKey<FormState>();
  final firstNameKeyRegister = GlobalKey<FormState>();

  final lastNameKeyRegister = GlobalKey<FormState>();

  final usernameKeyRegister = GlobalKey<FormState>();

  bool loading = false;

  Widget _buildEmailTF() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(
              'Email',
              style: TextStyle(
                  color: Colors.cyan[300], fontWeight: FontWeight.bold),
            ),
          ),
          //alignment: Alignment.centerLeft,
          //decoration: kBoxDecorationStyle,
          //height: 60.0,
          Form(
            key: emailKeyRegister,
            child: TextFormField(
              textInputAction: TextInputAction.next,
              validator: FieldValidator.email(message: "Invalid Email format"),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ), //border: InputBorder.,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.white,
                ),
                hintText: 'Enter your Email',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameTF() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(
              'Username',
              style: TextStyle(
                  color: Colors.cyan[300], fontWeight: FontWeight.bold),
            ),
          ),
          //alignment: Alignment.centerLeft,
          //decoration: kBoxDecorationStyle,
          //height: 60.0,
          Form(
            key: usernameKeyRegister,
            child: TextFormField(
              validator: FieldValidator.password(
                  minLength: 3,
                  maxLength: 15,
                  errorMessage: "3-15 characters allowed"),
              controller: _usernameController,
              //keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ), //border: InputBorder.,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                ),
                hintText: 'Enter your Username',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstNameTF() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(
              'First Name',
              style: TextStyle(
                  color: Colors.cyan[300], fontWeight: FontWeight.bold),
            ),
          ),
          //alignment: Alignment.centerLeft,
          //decoration: kBoxDecorationStyle,
          //height: 60.0,
          Form(
            key: firstNameKeyRegister,
            child: TextFormField(
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              validator: FieldValidator.password(
                  minLength: 1,
                  maxLength: 10,
                  errorMessage: "1-10 characters allowed"),
              controller: _firstNameController,
              //keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ), //border: InputBorder.,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.white,
                ),
                hintText: 'First name',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastNameTF() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(
              'Last Name',
              style: TextStyle(
                  color: Colors.cyan[300], fontWeight: FontWeight.bold),
            ),
          ),
          //alignment: Alignment.centerLeft,
          //decoration: kBoxDecorationStyle,
          //height: 60.0,
          Form(
            key: lastNameKeyRegister,
            child: TextFormField(
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              validator: FieldValidator.password(
                  minLength: 1,
                  maxLength: 15,
                  errorMessage: "1-15 characters allowed"),
              controller: _lastNameController,
              //keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ), //border: InputBorder.,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.white,
                ),
                hintText: 'Last name',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style:
              TextStyle(color: Colors.cyan[600], fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          // child: Container(
          //   alignment: Alignment.centerLeft,
          //   decoration: kBoxDecorationStyle,
          //   height: 60.0,
          child: Form(
            key: passwordKeyRegister,
            child: TextFormField(
              textInputAction: TextInputAction.done,
              validator: FieldValidator.password(
                  minLength: 8, errorMessage: "Minimum of 8 characters"
                  // shouldContainNumber: true,
                  // shouldContainCapitalLetter: true,
                  // shouldContainSmallLetter: true,
                  // shouldContainSpecialChars: true,
                  // errorMessage: "Password must match the required format",
                  // onNumberNotPresent: () { return "Password must contain number"; },
                  // onSpecialCharsNotPresent: () { return "Password must contain special characters"; },
                  // onCapitalLetterNotPresent: () { return "Password must contain capital letters"; }
                  ),

              // (passwordKey) {
              //   if (passwordKey.length < 8) {
              //     return 'Minimum of 8 characters';
              //   }
              //   return null;
              // },
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),

              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),

                //border: InputBorder.none,

                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
                hintText: 'Enter your Password',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ),
        // ),
      ],
    );
  }

  Widget _buildRegisterBtn() {
    bool isAllValid = false;
    return Container(
      padding: EdgeInsets.fromLTRB(0, 30, 0, 25),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            side: BorderSide(color: Colors.cyan[400], width: 2),
            primary: isAllValid ? Colors.cyanAccent : Colors.cyanAccent,
            elevation: 20,
            padding: const EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),

        //elevation: 20.0,
        child: Text(
          'REGISTER',
          style: TextStyle(
            //color: Color(0xFF527DAA),
            color: Colors.black,
            letterSpacing: 2,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        // onFocusChange: (value) {
        //   if (firstNameKeyRegister.currentState.validate() &&
        //       lastNameKeyRegister.currentState.validate() &&
        //       usernameKeyRegister.currentState.validate() &&
        //       emailKeyRegister.currentState.validate() &&
        //       passwordKeyRegister.currentState.validate()) {
        //     isAllValid = true;
        //   }
        // },

        onPressed: () async {
          if (firstNameKeyRegister.currentState.validate() &&
              lastNameKeyRegister.currentState.validate() &&
              usernameKeyRegister.currentState.validate() &&
              emailKeyRegister.currentState.validate() &&
              passwordKeyRegister.currentState.validate()) {
            setState(() {
              loading = true;
            });

            if (_usernameController.text.contains(" ")) {
              String userNameEdited =
                  _usernameController.text.replaceAll(" ", "");
              dynamic user = await _authService.registerWithEmailAndPassword(
                  email: _emailController.text.trim().toLowerCase(),
                  username: userNameEdited.trim().toLowerCase(),
                  password: _passwordController.text.trim(),
                  first: _firstNameController.text.trim(),
                  last: _lastNameController.text.trim(),
                  contextIn: context);
              if (user == null) {
                setState(() {
                  loading = false;
                });
              }
            } else {
              dynamic user = await _authService.registerWithEmailAndPassword(
                  email: _emailController.text.trim().toLowerCase(),
                  username: _usernameController.text.trim().toLowerCase(),
                  password: _passwordController.text.trim(),
                  first: _firstNameController.text.trim(),
                  last: _lastNameController.text.trim(),
                  contextIn: context);
              if (user == null) {
                setState(() {
                  loading = false;
                });
              }
            }
          }
        },
      ),
      // color: Colors.grey[500],
    );
  }

  Widget _buildRegisterWithText() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Text('- OR -',
              style: TextStyle(
                  color: Colors.cyan[300], fontWeight: FontWeight.bold)),
        ),
        Text(
          'Register with',
          style:
              TextStyle(color: Colors.cyan[300], fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
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

  // Widget _buildSocialBtnRow() {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 20.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: <Widget>[
  //         Container(
  //           child: _buildSocialBtn(
  //             () async => await _authService.signInWithFacebook(),
  //             AssetImage(
  //               'assets/images/SMLogos/FacebookLogo.png',
  //             ),
  //           ),
  //         ),
  //         Container(
  //           child: _buildSocialBtn(
  //             () async => await _authService.signInWithGoogle(),
  //             AssetImage(
  //               'assets/images/SMLogos/GoogleLogo.png',
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildLoginBtn() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text('Already have an acoount?',
              style: TextStyle(
                  color: Colors.cyan[300],
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          Icon(
            Icons.arrow_forward_sharp,
            size: 20,
            color: Colors.cyan[200],
          ),
          ElevatedButton(
            onPressed: () {
              widget.toggleIsRegistering(false);
              // Navigator.push(context, MaterialPageRoute(builder: (context) {
              //   return Scaffold(body: RegisterScreen());
              // }));
            },
            child: Text(
              "Login!",
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

  //   return GestureDetector(
  //     onTap: () {
  //       widget.toggleIsRegistering(false);
  //     },
  //     child: RichText(
  //       text: TextSpan(
  //         children: [
  //           TextSpan(
  //               text: 'Already have an account? ',
  //               style: TextStyle(
  //                   color: Colors.cyan[300], fontWeight: FontWeight.bold)),
  //           TextSpan(
  //               text: ' Sign in',
  //               style: TextStyle(
  //                   color: Colors.cyan[300],
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 20)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF61E2D7),
                          Color(0xFF53DACE),
                          Color(0xFF3DC2B7),
                          Color(0xFF28B9AD),
                        ],
                        stops: [0.1, 0.4, 0.7, 0.9],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.grey[850],
                    //height: double.infinity,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.cyan[300],
                                fontFamily: 'OpenSans',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // display first name and last name field side by side
                          Row(
                            children: [
                              Expanded(child: _buildFirstNameTF()),
                              Padding(padding: EdgeInsets.all(7.0)),
                              Expanded(child: _buildLastNameTF())
                            ],
                          ),
                          _buildUsernameTF(),
                          _buildEmailTF(),
                          _buildPasswordTF(),
                          // _buildForgotPasswordBtn(),
                          _buildRegisterBtn(),
                          _buildLoginBtn(),
                          //_buildRegisterWithText(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 150),
                            //child: _buildSocialBtnRow(),
                          ),
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