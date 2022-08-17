import 'package:flutter/cupertino.dart';
import 'package:soshi/screens/login/newRegisterFlowSri.dart';

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

class ScreenChecker {
  Map status;

  ScreenChecker() {
    status = {
      InputType.EMAIL: false,
      InputType.ALL_PASSWORDS: false,
      InputType.ALL_NAMES: false,
      InputType.PASSWORD: false,
      InputType.SOSHI_USERNAME: false
    };
  }

  markScreenDone({@required InputType inputType}) {
    status[inputType] = true;
  }

  markScreenInvalid({@required InputType inputType}) {
    status[inputType] = false;
  }

  isValidScreen({@required InputType inputType}) {
    return status[inputType];
  }
}
