import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/screens/login/loading.dart';
import 'package:soshi/screens/login/superController.dart';
import 'package:soshi/screens/mainapp/mainapp.dart';
import 'package:soshi/services/auth.dart';

class NewRegisterFlow extends StatefulWidget {
  SuperController superController;

  NewRegisterFlow(SuperController superController) {
    this.superController = superController;
  }

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

    return SafeArea(
      child: Scaffold(
        // appBar: PreferredSize(
        //     //Create "Beta" icon on left
        //     preferredSize: Size(Utilities.getWidth(context), Utilities.getHeight(context) / 16),
        //     child: SoshiAppBar()),
        appBar: AppBar(
          //toolbarHeight: 130,
          elevation: 0,
          centerTitle: true,
          title:

              //  Text(
              //   "Soshi ${currentPage}",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              // ),

              Image.asset(
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
                            duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
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
                      type: InputType.EMAIL, superController: widget.superController),
                  RegisterSingleScreen(
                      type: InputType.ALL_PASSWORDS, superController: widget.superController),
                  RegisterSingleScreen(
                      type: InputType.ALL_NAMES, superController: widget.superController),
                  RegisterSingleScreen(
                    type: InputType.SOSHI_USERNAME,
                    superController: widget.superController,
                    registerError: registerError,
                    registerErrorMessaage: registerErrorMessage,
                  ),
                  RegisterSingleScreen(
                    type: InputType.PASSWORD,
                    userMetaData: this.fetchUserData,
                    superController: widget.superController,
                    registerError: registerError,
                    registerErrorMessaage: registerErrorMessage,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: GestureDetector(
                onTap: () async {
                  print("Move to next screen - smooth animation REGISTER");

                  if (currentPage == 0) {
                    print("[!] email page processing! => ${widget.superController.email.text}");

                    OnboardingLoader.showLoadingIndicator("", context);

                    DocumentSnapshot dRef = await FirebaseFirestore.instance
                        .collection("emailToUsername")
                        .doc(widget.superController.email.text)
                        .get();
                    print("DOC EXISTS? ❓ ${dRef.exists}");
                    if (dRef.exists) {
                      String username = dRef.get("soshiUsername");
                      print(username);
                      DocumentSnapshot dSnap =
                          await FirebaseFirestore.instance.collection("users").doc(username).get();

                      Map fullUserPackage = dSnap.data();
                      setState(() {
                        print("User package == > ${fullUserPackage}");
                        this.fetchUserData = fullUserPackage;
                      });

                      // await controller.animateToPage(4,
                      //     duration: Duration(milliseconds: 0), curve: Curves.easeInOut);

                      await controller.jumpToPage(4);
                    } else {
                      await controller.animateToPage(currentPage + 1,
                          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                    }

                    Navigator.pop(context);
                  } else if (currentPage == 1) {
                    if (widget.superController.passwordNew.text ==
                        widget.superController.passwordNewConfirm.text) {
                      print(
                          "✅password MATCH PASS  ${widget.superController.passwordNew.text} ||| ${widget.superController.passwordNewConfirm.text}");

                      await controller.animateToPage(currentPage + 1,
                          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                    } else {
                      print(
                          "❌ cant move to next, controller diff ${widget.superController.passwordNew.text} ||| ${widget.superController.passwordNewConfirm.text}");
                    }
                  } else if (currentPage == 4) {
                    print("Sign in regularly into account!");

                    OnboardingLoader.showLoadingIndicator("", context);

                    final AuthService _authService = new AuthService();
                    dynamic user = await _authService.signInWithEmailAndPassword(
                        emailIn: widget.superController.email.text,
                        passwordIn: widget.superController.passwordOldAcc.text);

                    await Future.delayed(Duration(seconds: 1));

                    Navigator.pop(context);

                    if (user.runtimeType == String) {
                      print("❌ error caught in runTimetype (SIGN_IN)");
                      setState(() {
                        this.registerError = true;
                        this.registerErrorMessage = user.toString();
                      });
                    } else if (user.runtimeType == User) {
                      setState(() {
                        this.registerError = false;
                      });
                      print("✅ sign-in success: pushing to main dashboard NOW!");

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainApp()),
                      );
                    }
                  } else if (currentPage != 3) {
                    await controller.animateToPage(currentPage + 1,
                        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                  }

                  //
                  else {
                    final AuthService _authService = new AuthService();

                    OnboardingLoader.showLoadingIndicator("", context);

                    dynamic user = await _authService.registerWithEmailAndPassword(
                      email: widget.superController.email.text.trim().toLowerCase(),
                      username: widget.superController.soshiUsername.text
                          .trim()
                          .toLowerCase()
                          .replaceAll(" ", ""),
                      password: widget.superController.passwordNewConfirm.text.trim(),
                      first: widget.superController.firstName.text.trim(),
                      last: widget.superController.lastName.text.trim(),
                      contextIn: context,
                    );
                    print(user);
                    await Future.delayed(Duration(seconds: 2));

                    Navigator.pop(context);
                    if (user.runtimeType == String) {
                      print("❌ error caught in runTimetype");
                      setState(() {
                        this.registerError = true;
                        this.registerErrorMessage = user.toString();
                      });
                    } else if (user.runtimeType == User) {
                      setState(() {
                        this.registerError = false;
                      });
                      print("✅ sign-up success: pushing to main dashboard NOW!");

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return Scaffold(body: MainApp());
                      }));
                    }

                    // After the 3 intro screens are done, push to registration onboarding process
                    // Navigator.push(context, MaterialPageRoute(builder: (context) {
                    //   return Scaffold(body: RegisterScreen());
                    // }));
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
                              style: TextStyle(fontSize: 20, color: Colors.black),
                            )
                          : this.currentPage == 4
                              ? Text(
                                  "Sign in",
                                  style: TextStyle(fontSize: 20, color: Colors.black),
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
  Map userMetaData = {};
  bool registerError = false;
  String registerErrorMessaage = "";

  RegisterSingleScreen(
      {this.type,
      this.superController,
      this.userMetaData,
      this.registerError,
      this.registerErrorMessaage});

  @override
  State<RegisterSingleScreen> createState() => _RegisterSingleScreenState();
}

class _RegisterSingleScreenState extends State<RegisterSingleScreen> {
  String forgotPasswordText = "Forgot password?";
  bool validPassword = true;
  bool validPassword2 = true;
  @override
  Widget build(BuildContext context) {
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);

    return Container(
        // color: Colors.red,
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          this.widget.userMetaData == null
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                  child: Text(
                    getMapData('main_text'),
                    style: TextStyle(
                      fontSize: width / 20,
                      //fontWeight: FontWeight.bold,
                      //color: Colors.grey
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
                                widget.userMetaData['Photo URL'].contains("https")
                            ? Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                                elevation: 5,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    child: Image.network(widget.userMetaData['Photo URL'],
                                        height: 125, width: 125)),
                              )
                            : Icon(Icons.person, size: 80),
                        SizedBox(height: 10),
                        Text(
                          "welcome back,\n${this.widget.userMetaData['Name']['First']}!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          [InputType.ALL_PASSWORDS, InputType.ALL_NAMES].contains(this.widget.type)
              ? Column(
                  children: [
                    makeTextField(
                        getMapData('hint_text').split("%")[0], getMapData('controller_1')),
                    SizedBox(height: 10),
                    makeTextField(
                        getMapData('hint_text').split("%")[1], getMapData('controller_2')),
                    widget.type == InputType.ALL_PASSWORDS &&
                            widget.superController.passwordNew.text != "" &&
                            widget.superController.passwordNewConfirm.text != "" &&
                            widget.superController.passwordNew.text.length >= 8
                        ? widget.superController.passwordNew.text !=
                                widget.superController.passwordNewConfirm.text
                            ? OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                label: Text("Passwords don't match!",
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.grey[850],
                                    )))
                            : OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                ),
                                label: Text(
                                  "Passwords match!",
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.grey[850],
                                  ),
                                ))
                        : Container(),
                    widget.type == InputType.ALL_PASSWORDS &&
                            widget.superController.passwordNew.text.length < 8
                        ? !validPassword
                            ? OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                label: Text("Password must be greater than 8 characters!",
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.grey[850],
                                    )))
                            : Container()
                        : Container()
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 75,
                        child: makeTextField(getMapData('hint_text'), getMapData('controller')),
                      ),

                      // Forgot password functionality
                      widget.type == InputType.PASSWORD
                          ? Row(
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
                                    // Icon(
                                    //     Icons.question_mark_rounded,
                                    //     color: Colors.white,
                                    //     size: 20,
                                    //   ),
                                    label: Text(forgotPasswordText,
                                        style: TextStyle(
                                            color: forgotPasswordText.contains("Sent")
                                                ? Colors.green
                                                : Colors.white))),
                              ],
                            )
                          : Container(),
                      // To show registration errors!
                      [InputType.SOSHI_USERNAME, InputType.PASSWORD].contains(widget.type) &&
                              widget.registerError == true &&
                              getMapData('controller').text != ""
                          ? OutlinedButton.icon(
                              onPressed: () {},
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                              label: Text(widget.registerErrorMessaage))
                          : Container(),
                    ],
                  )),
        ],
      ),
    ));
  }

  TextField makeTextField(String hintText, TextEditingController controller) {
    return TextField(
      keyboardType: hintText == "Email"
          ? TextInputType.emailAddress
          : hintText == "First Name" || hintText == "Last Name"
              ? TextInputType.name
              : null,
      obscureText: hintText == "Password" || hintText == "Confirm password" ? true : false,
      cursorHeight: 28,
      controller: controller,
      inputFormatters: widget.type == InputType.SOSHI_USERNAME
          ? [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))]
          : null,
      onChanged: widget.type == InputType.ALL_PASSWORDS
          ? (String newValue) {
              String pass1 = widget.superController.passwordNew.text;
              String pass2 = widget.superController.passwordNewConfirm.text;

              if (pass1 == pass2 && pass1 != "" && pass2 != "" && pass1.length >= 8) {
                setState(() {
                  validPassword = true;
                });
              } else {
                setState(() {
                  validPassword = false;
                });
              }
            }
          : null,
      style: TextStyle(fontSize: 24),
      decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          hintStyle: TextStyle(fontSize: 20),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
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
        'controller': widget.superController.email
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
