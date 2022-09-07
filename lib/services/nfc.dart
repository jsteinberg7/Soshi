import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'localData.dart';

class NFCWriter extends StatefulWidget {
  double height, width;
  String shortDynamicLink;
  NFCWriter(this.height, this.width, this.shortDynamicLink);

  @override
  State<NFCWriter> createState() => _NFCWriterState();
}

class _NFCWriterState extends State<NFCWriter> {
  String displayText, animationUrl, shortDynamicLink;
  double height, width;
  @override
  void initState() {
    super.initState();
    this.height = widget.height;
    this.width = widget.width;
    this.shortDynamicLink = widget.shortDynamicLink;
    displayText = "Scanning for tags...";
    animationUrl =
        "https://assets8.lottiefiles.com/packages/lf20_maxyrepx.json";
    ndefWrite();
  }

  Future<bool> ndefWrite() async {
    print("writing");
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          NfcManager.instance.stopSession(errorMessage: ":(");
          return false;
        }

        NdefMessage message = NdefMessage([
          NdefRecord.createUri(Uri.parse(shortDynamicLink)),
        ]);

        try {
          await ndef.write(message);

          setState(() {
            displayText = "Success!";
            animationUrl =
                "https://assets1.lottiefiles.com/packages/lf20_s2lryxtd.json";
          });
          await Future.delayed(
              Duration(seconds: 1)); // wait a sec before stopping session
          NfcManager.instance.stopSession();
          await Future.delayed(
              Duration(seconds: 1)); // close popup after 2 seconds
          Navigator.pop(context);
          return true;
        } catch (e) {
          NfcManager.instance.stopSession(
              errorMessage:
                  "Portal is not compatible or has already been written to :(");
          return false;
        }
      },
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    print("writing");
    Navigator.of(context).pop();

    //it");
    // return Container(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.end,
    //     children: [
    //       Container(
    //           width: width / 1.1,
    //           decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.all(Radius.circular(25.0))),
    //           height: 250,
    //           // color: Colors.white,
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //             children: [
    //               Container(
    //                 height: 150,
    //                 child: Lottie.network(
    //                   animationUrl,
    //                 ),
    //               ),
    //               Text(
    //                 displayText,
    //                 style: TextStyle(color: Colors.black, fontSize: 25.0),
    //               ),
    //             ],
    //           )),
    //       SizedBox(
    //         height: height / 50,
    //       ),
    //       GestureDetector(
    //         onTap: () {
    //           Navigator.pop(context);
    //         },
    //         child: Container(
    //           decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.all(Radius.circular(15.0))),
    //           height: height / 15,
    //           width: width / 1.1,
    //           child: Center(
    //             child: Text("Close",
    //                 style: TextStyle(
    //                     color: Colors.blue, fontSize: widget.width / 22)),
    //           ),
    //         ),
    //       ),
    //       SizedBox(height: height / 40)
    //     ],
    //   ),
    // );
  }
}
