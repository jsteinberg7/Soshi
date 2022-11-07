import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soshi/constants/popups.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/constants/widgets.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/screens/login/superController.dart';
import 'package:soshi/screens/mainapp/mainapp.dart';
import 'package:soshi/services/auth.dart';
import 'package:soshi/services/dataEngine.dart';

import '../../services/database.dart';
import '../../services/url.dart';

class NewRegisterFlow extends StatefulWidget {
  SuperController superController;
  ScreenChecker screenChecker;
  NewRegisterFlow(
      {@required this.superController, @required this.screenChecker});

  @override
  State<NewRegisterFlow> createState() => _NewRegisterFlowState();
}

class _NewRegisterFlowState extends State<NewRegisterFlow> {
  final controller = PageController(initialPage: 0);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // TextEditingController _ = new TextEditingController();

  int currentPage = 0;
  Map fetchUserData = {};
  String registerErrorMessage = "";
  bool registerError = true;

  @override
  Widget build(BuildContext context) {
    print("reanimating with current apge: " + currentPage.toString());
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);
    bool validate_ = true;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Image.asset(
            "assets/images/SoshiLogos/SoshiBubbleLogo.png",
            width: width / 3,
          ),
          leading: this.currentPage != 0
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                      onPressed: () async {
                        if (this.currentPage == 4) {
                          await controller.jumpToPage(0);
                        }
                        await controller.animateToPage(currentPage - 1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      icon: Icon(Icons.chevron_left, size: 40)),
                )
              : Container(),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (int newPage) {
                  // run code here to check for existing account using Email
                  setState(() {
                    currentPage = newPage;
                  });
                },
                controller: this.controller,
                // physics: const NeverScrollableScrollPhysics(),
                children: [
                  RegisterSingleScreen(
                      type: InputType.EMAIL,
                      superController: widget.superController,
                      screenChecker: widget.screenChecker), //0
                  RegisterSingleScreen(
                      type: InputType.ALL_PASSWORDS,
                      superController: widget.superController,
                      screenChecker: widget.screenChecker), //1
                  RegisterSingleScreen(
                      type: InputType.ALL_NAMES,
                      superController: widget.superController,
                      screenChecker: widget.screenChecker), //2
                  RegisterSingleScreen(
                      type: InputType.SOSHI_USERNAME,
                      superController: widget.superController,
                      registerError: registerError,
                      registerErrorMessaage: registerErrorMessage,
                      screenChecker: widget.screenChecker), //3
                  RegisterSingleScreen(
                      type: InputType.PASSWORD,
                      userMetaData: this.fetchUserData,
                      superController: widget.superController,
                      registerError: registerError,
                      registerErrorMessaage: registerErrorMessage,
                      screenChecker: widget.screenChecker), //4
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: GestureDetector(
                onTap: () async {
                  // ✅ EMAIL
                  if (currentPage == 0 &&
                      widget.screenChecker
                          .isValidScreen(inputType: InputType.EMAIL)) {
                    String convertedEmail =
                        widget.superController.email.text.trim().toLowerCase();
                    OnboardingLoader.showLoadingIndicator("", context);
                    DocumentSnapshot dRef = await FirebaseFirestore.instance
                        .collection("emailToUsername")
                        .doc(convertedEmail)
                        .get();

                    if (dRef.exists) {
                      String username = dRef.get("soshiUsername");
                      DocumentSnapshot dSnap = await FirebaseFirestore.instance
                          .collection("users")
                          .doc(username)
                          .get();
                      Map fullUserPackage = dSnap.data();
                      setState(() {
                        this.fetchUserData = fullUserPackage;
                      });
                      await controller.jumpToPage(4);
                    } else {
                      await controller.animateToPage(currentPage + 1,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                    }
                    OnboardingLoader.killLoader(context);
                  }
                  // ✅ CREATE NEW PASSWORD
                  else if (currentPage == 1 &&
                      widget.screenChecker
                          .isValidScreen(inputType: InputType.ALL_PASSWORDS)) {
                    if (widget.superController.passwordNew.text ==
                        widget.superController.passwordNewConfirm.text) {
                      await controller.animateToPage(currentPage + 1,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                    } else {
                      print(
                          "❌ cant move to next, controller diff ${widget.superController.passwordNew.text} ||| ${widget.superController.passwordNewConfirm.text}");
                    }
                  }
                  // ✅ REGULAR OLD PASSWORD
                  else if (currentPage == 4) {
                    print("Sign in regularly into account!");

                    OnboardingLoader.showLoadingIndicator("", context);

                    final AuthService _authService = new AuthService();
                    dynamic user =
                        await _authService.signInWithEmailAndPassword(
                            emailIn: widget.superController.email.text
                                .trim()
                                .toLowerCase(),
                            passwordIn:
                                widget.superController.passwordOldAcc.text);

                    // OnboardingLoader.killLoader(context);

                    if (user.runtimeType == String) {
                      OnboardingLoader.killLoader(context);

                      print("❌ error caught in runTimetype (SIGN_IN)");
                      setState(() {
                        this.registerError = true;
                        this.registerErrorMessage = user.toString();
                      });
                    } else if (user.runtimeType == User) {
                      setState(() {
                        this.registerError = false;
                      });
                      print(
                          "✅ sign-in success: pushing to main dashboard NOW!");
                      await DataEngine.initialize();
                      await DataEngine.applyUserChanges(
                          user: DataEngine.globalUser,
                          cloud: true,
                          local: true); // update contact card
                      OnboardingLoader.killLoader(context);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainApp()),
                      );
                    }
                  }
                  // ✅ CREATE FIRST/LAST NAME
                  else if (currentPage == 2 &&
                      widget.screenChecker
                          .isValidScreen(inputType: InputType.ALL_NAMES)) {
                    await controller.animateToPage(currentPage + 1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  }

                  // ✅ FINAL
                  else if (currentPage == 3 &&
                      widget.screenChecker
                          .isValidScreen(inputType: InputType.SOSHI_USERNAME)) {
                    final AuthService _authService = new AuthService();

                    OnboardingLoader.showLoadingIndicator("", context);

                    dynamic user =
                        await _authService.registerWithEmailAndPassword(
                      email: widget.superController.email.text
                          .trim()
                          .toLowerCase(),
                      username: widget.superController.soshiUsername.text
                          .trim()
                          .toLowerCase()
                          .replaceAll(" ", ""),
                      password:
                          widget.superController.passwordNewConfirm.text.trim(),
                      first: widget.superController.firstName.text.trim(),
                      last: widget.superController.lastName.text.trim(),
                      contextIn: context,
                    );

                    // OnboardingLoader.killLoader(context);
                    if (user.runtimeType == String) {
                      OnboardingLoader.killLoader(context);

                      print("❌ error caught in runTimetype");
                      setState(() {
                        this.registerError = true;
                        this.registerErrorMessage = user.toString();
                      });
                    } else if (user.runtimeType == User) {
                      setState(() {
                        this.registerError = false;
                      });
                      print(
                          "✅ sign-up success: pushing to main dashboard NOW!");
                      await DataEngine.initialize();

                      await DataEngine.applyUserChanges(
                          user: DataEngine.globalUser,
                          cloud: true,
                          local: true); // update contact card
                      OnboardingLoader.killLoader(context);

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return MainApp();
                      }));
                    }
                  } else {
                    OnboardingLoader.killLoader(context);

                    log("cannot proceed to next screen sorry!");
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: currentPage == 3 || currentPage == 4
                      ? BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)))
                      : BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    // padding: const EdgeInsets.fromLTRB(100, 15, 100, 15),
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                    child: Center(
                      child: this.currentPage == 3
                          ? Text(
                              "Create Account",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            )
                          : this.currentPage == 4
                              ? Text(
                                  "Sign in",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                )
                              : Text(
                                  "Continue",
                                  style: TextStyle(fontSize: 20),
                                ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterSingleScreen extends StatefulWidget {
  InputType type;
  SuperController superController;
  ScreenChecker screenChecker;

  Map userMetaData = {};
  bool registerError = false;
  String registerErrorMessaage = "";

  RegisterSingleScreen(
      {this.type,
      this.superController,
      this.userMetaData,
      this.registerError,
      this.registerErrorMessaage,
      this.screenChecker});

  @override
  State<RegisterSingleScreen> createState() => _RegisterSingleScreenState();
}

class _RegisterSingleScreenState extends State<RegisterSingleScreen> {
  String forgotPasswordText = "Forgot password?";
  bool validPassword = true;
  bool validEmail = true;

  renderPrivacyPolicy() {
    if (widget.type == InputType.SOSHI_USERNAME ||
        widget.type == InputType.PASSWORD) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 5, 0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //  Text("by creating an account, you agree to sosh")
              TextButton.icon(
                  onPressed: () async {
                    // await Popups.privacyPolicyPopup(context);
                    await URL.launchURL(
                        "https://app.termly.io/document/terms-of-use-for-saas/8b7e6781-e03e-45a3-88e9-d0a8de547d12");
                  },
                  icon: Icon(
                    Icons.privacy_tip,
                    color: Colors.cyan,
                  ),
                  label: Column(
                    children: [
                      Text(
                          "By ${widget.type == InputType.SOSHI_USERNAME ? "creating an account" : "logging in"}, you agree to"),
                      Text(
                        "Soshi's Terms and Conditions",
                        style: TextStyle(
                          color: Colors.grey,
                          // Theme.of(context).brightness == Brightness.light
                          //     ? Colors.grey,
                          //     : Colors.white,
                          //fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  renderInputErrorMessage() {
    String messageText = "";
    bool badMessage = true;
    String pass1 = widget.superController.passwordNew.text;
    String pass2 = widget.superController.passwordNewConfirm.text;

    String first = widget.superController.firstName.text;
    String last = widget.superController.lastName.text;

    if (widget.type == InputType.ALL_PASSWORDS && pass1 != "") {
      if (pass1 != "" && pass2 != "" && pass1.length >= 8) {
        if (pass1 != pass2) {
          messageText = "Passwords don't match!";
        } else {
          messageText = "Passwords match!";
          badMessage = false;
        }
      } else if (pass1.length < 8) {
        messageText = "Password must be greater than 8 characters!";
      }
    } else if (widget.type == InputType.EMAIL &&
        widget.superController.email.text != "") {
      if (EmailValidator.validate(widget.superController.email.text)) {
        messageText = "Valid email";
        badMessage = false;
      } else {
        messageText = "Invalid email";
      }
    } else if (widget.type == InputType.ALL_NAMES) {
      // if (first.length < 2 || last.length < 2) {
      //   messageText = "Name too short";
      //   badMessage = true;
      // }

      if (first != "" && last != "") {
        badMessage = false;
        messageText = "Cool name!";
      }
    } else if (widget.type == InputType.SOSHI_USERNAME) {
      if (widget.superController.soshiUsername.text != "") {
        badMessage = false;
      }
    }

    if (badMessage == false) {
      widget.screenChecker.markScreenDone(inputType: widget.type);
    } else {
      widget.screenChecker.markScreenInvalid(inputType: widget.type);
    }

    if (messageText != "") {
      return TextButton.icon(
          style: TextButton.styleFrom(
              primary: badMessage ? Colors.red : Colors.green),
          onPressed: () {},
          icon: badMessage
              ? Icon(Icons.cancel, color: Colors.red)
              : Icon(Icons.check, color: Colors.green),
          label: Text(messageText,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.grey[850],
              )));
    } else {
      return Container();
    }
  }

  renderAuthErrorMessage() {
    if ([InputType.SOSHI_USERNAME, InputType.PASSWORD].contains(widget.type)) {
      if (widget.registerError == true &&
          getMapData('controller').text != "" &&
          widget.registerErrorMessaage != "") {
        return TextButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            label: Text(widget.registerErrorMessaage));
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  sendResetPassword() {
    if (widget.type == InputType.PASSWORD) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
              onPressed: () async {
                try {
                  setState(() {
                    forgotPasswordText =
                        "Sent to ${widget.superController.email.text}. Resend?";
                  });
                  final FirebaseAuth _auth = FirebaseAuth.instance;
                  await _auth.sendPasswordResetEmail(
                      email: widget.superController.email.text);
                } catch (e) {
                  setState(() {
                    forgotPasswordText = "Unable to send reset email, sorry";
                  });
                }
              },
              icon: forgotPasswordText.contains("Sent")
                  ? Icon(Icons.check, color: Colors.green)
                  : Container(),
              label: Text(forgotPasswordText,
                  style: TextStyle(
                      color: forgotPasswordText.contains("Sent")
                          ? Colors.green
                          : Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white))),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);

    return Container(
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            this.widget.userMetaData == null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                    child: Text(
                      getMapData('main_text'),
                      style: TextStyle(
                        fontSize: width / 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Container(),
            this.widget.userMetaData != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Container(
                      child: Column(
                        children: [
                          widget.userMetaData['Photo URL'] != null &&
                                  widget.userMetaData['Photo URL']
                                      .contains("https")
                              ? ProfilePic(
                                  url: widget.userMetaData['Photo URL'],
                                  radius: 60,
                                )
                              : ProfilePic(
                                  url: "assets/images/misc/default_pic.png",
                                  radius: 60,
                                ),
                          SizedBox(height: 10),
                          Text(
                            "Welcome back,\n${this.widget.userMetaData['Name']['First']}!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 21),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            // Fields that have 2 Text Inputs
            [InputType.ALL_PASSWORDS, InputType.ALL_NAMES]
                    .contains(this.widget.type)
                ? Column(
                    children: [
                      makeTextField(getMapData('hint_text').split("%")[0],
                          getMapData('controller_1')),
                      SizedBox(height: 10),
                      makeTextField(getMapData('hint_text').split("%")[1],
                          getMapData('controller_2')),
                      renderInputErrorMessage(),
                    ],
                  )

                // Fields that only have only one text field input
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 75,
                          child: makeTextField(getMapData('hint_text'),
                              getMapData('controller')),
                        ),

                        renderPrivacyPolicy(),

                        renderInputErrorMessage(),
                        renderAuthErrorMessage(),
                        sendResetPassword()
                        // Forgot password functionality
                      ],
                    )),
          ],
        ),
      ),
    ));
  }

  TextFormField makeTextField(
      String hintText, TextEditingController controller) {
    return TextFormField(
      autofillHints: hintText == "Email" ? [AutofillHints.email] : null,
      keyboardType: hintText == "Email"
          ? TextInputType.emailAddress
          : hintText == "First Name" || hintText == "Last Name"
              ? TextInputType.name
              : null,
      obscureText: hintText == "Password" || hintText == "Confirm password"
          ? true
          : false,
      cursorHeight: 28,
      textCapitalization: TextCapitalization.none,
      controller: controller,
      inputFormatters: widget.type == InputType.EMAIL
          ? [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9_.-@]"))]
          : widget.type == InputType.SOSHI_USERNAME
              ? [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9_.]"))]
              : widget.type == InputType.ALL_NAMES
                  ? [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))]
                  : null,
      // onChanged: widget.type == InputType.ALL_PASSWORDS
      //     ? (String newValue) {
      //         print("🔃 Updating password: " + newValue);
      //         setState(() {});
      //       }
      //     : widget.type == InputType.EMAIL
      //         ? (String newValue) {
      //             print("📧 setting state for email 📧");
      //             setState(() {
      //               validEmail = EmailValidator.validate(newValue);
      //               print("Email valid? ${validEmail}");
      //             });
      //           }
      //         : null,

      onChanged: (value) {
        setState(() {});
      },
      style: TextStyle(fontSize: 24),
      decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          hintStyle: TextStyle(fontSize: 20),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            borderSide: BorderSide(color: Colors.cyan, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          fillColor: Colors.grey,
          focusColor: Colors.grey),
    );
  }

  getMapData(String attribute) {
    Map converter = {
      InputType.EMAIL: {
        'validator': null,
        'hint_text': 'Email',
        'main_text': "Let's get started, what's your email?",
        'controller': widget.superController.email,
        'error_text': "Invalid email"
      },
      InputType.FIRST_NAME: {
        'validator': null,
        'hint_text': 'First Name',
        'main_text': 'Enter your first name',
        'controller_1': widget.superController.firstName
      },
      InputType.LAST_NAME: {
        'validator': null,
        'hint_text': 'Last Name',
        'main_text': 'Enter your last name',
        'controller_2': widget.superController.lastName
      },
      InputType.PASSWORD: {
        'validator': null,
        'hint_text': 'Password',
        'main_text': '',
        'controller': widget.superController.passwordOldAcc
      },
      InputType.SOSHI_USERNAME: {
        'validator': null,
        'hint_text': 'Soshi Username',
        'main_text': 'Pick a Soshi username',
        'controller': widget.superController.soshiUsername
      },
      InputType.ALL_NAMES: {
        'validator': null,
        'hint_text': 'First Name%Last Name',
        'main_text': "What's your name?",
        'controller_1': widget.superController.firstName,
        'controller_2': widget.superController.lastName,
      },
      InputType.ALL_PASSWORDS: {
        'validator': null,
        'hint_text': 'Password%Confirm password',
        'main_text': "Let's secure your Soshi.",
        'controller_1': widget.superController.passwordNew,
        'controller_2': widget.superController.passwordNewConfirm,
        'error_text': "Passwords don't match!"
      }
    };
    return converter[widget.type][attribute];
  }
}

enum InputType {
  EMAIL,
  PASSWORD,
  CONFIRM_PASSWORD,
  SOSHI_USERNAME,
  FIRST_NAME,
  LAST_NAME,
  ALL_NAMES,
  ALL_PASSWORDS
}
