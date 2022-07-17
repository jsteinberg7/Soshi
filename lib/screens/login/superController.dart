import 'package:flutter/cupertino.dart';

class SuperController {
  TextEditingController email;
  TextEditingController passwordOldAcc;
  TextEditingController passwordNew;
  TextEditingController passwordNewConfirm;
  TextEditingController soshiUsername;
  TextEditingController firstName;
  TextEditingController lastName;

  SuperController() {
    email = new TextEditingController();
    passwordOldAcc = new TextEditingController();
    passwordNew = new TextEditingController();
    passwordNewConfirm = new TextEditingController();
    soshiUsername = new TextEditingController();
    firstName = new TextEditingController();
    lastName = new TextEditingController();
  }
}
