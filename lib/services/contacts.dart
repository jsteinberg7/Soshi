import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';

class VCard {
  String soshiUsername, firstName, lastName, phone, email;
  Contact contact;
  VCard(
      {String soshiUsernameIn,
      String firstNameIn,
      String lastNameIn,
      String phoneIn,
      String emailIn,
      Contact contactIn}) {
    this.soshiUsername = soshiUsernameIn;
    this.firstName = firstNameIn;
    this.lastName = lastNameIn;
    this.phone = phoneIn;
    this.email = emailIn;
    this.contact = contactIn;
    if (contact != null) {
      firstName = contact.givenName;
      lastName = contact.familyName;
      phone = contact.phones.first.value;
      email = contact.emails.first.value;
    }
  }

  // Save formatted vCard to file and return file
  Future<File> generateVcf(filename) async {
    String contents = this._toString();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename.vcf');
    file.writeAsStringSync(contents);
    return file;
  }

  // Generate vCard string
  String _toString() {
    return "BEGIN:VCARD\nVERSION:3.0\nFN;CHARSET=UTF-8:$firstName $lastName\nN;CHARSET=UTF-8:$lastName;$firstName;;;\nEMAIL;CHARSET=UTF-8;type=HOME,INTERNET:$email\nTEL;TYPE=CELL,VOICE:$phone\nEND:VCARD";
  }
}

Future<void> askPermissions(BuildContext context) async {
  PermissionStatus permissionStatus = await _getContactPermission();
  if (permissionStatus != PermissionStatus.granted) {
    _handleInvalidPermissions(permissionStatus, context);
  }
}

Future<PermissionStatus> _getContactPermission() async {
  PermissionStatus permissionStatus = await Permission.contacts.request();
  return permissionStatus;
}

void _handleInvalidPermissions(
    PermissionStatus permissionStatus, BuildContext context) {
  if (permissionStatus == PermissionStatus.denied) {
    final snackBar = SnackBar(content: Text('Access to contact data denied'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
    final snackBar =
        SnackBar(content: Text('Contact data not available on device'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
