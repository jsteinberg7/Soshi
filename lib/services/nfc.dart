import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:soshi/services/database.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'dataEngine.dart';


class NFCLinker extends StatefulWidget {
  double height, width;

  NFCLinker(this.height, this.width);
  @override
  State<NFCLinker> createState() => _NFCLinkerState();
}

class _NFCLinkerState extends State<NFCLinker> {
  double height, width;
  String displayText, animationUrl;
  @override
  void initState() {
    super.initState();
    this.height = widget.height;
    this.width = widget.width;

    displayText = "Scanning for tags...";
    animationUrl =
        "https://assets8.lottiefiles.com/packages/lf20_maxyrepx.json";
    searchAndLink();
  }

  @override
  void dispose() {
    super.dispose();
    NfcManager.instance.stopSession();
  }

  ValueNotifier nfcReaderValue = new ValueNotifier(null);

  Future<void> searchAndLink() async {
    await ndefRead(); // scan for tags
    nfcReaderValue.addListener(() async {
      String tagLink = nfcReaderValue.value;

      print("Value changed: " + tagLink ?? "null");
      if (tagLink != null) {
        List<String> params = tagLink.split("/");
        if (params.contains("id")) {
          String id = params.last;
          print(id);
          if (await DatabaseService.isValidNfcId(id) &&
              (await DatabaseService.getUsernameFromNfcId(id) == null)) {
            await DatabaseService.updateNfcId(id, DataEngine.soshiUsername);
          }
        }
      }
    });
  }

  Future<void> ndefRead() async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      Ndef n = Ndef.from(tag);
      // extract message from tag
      var payload = n.cachedMessage.records[0].payload;
      // convert to string
      var message = String.fromCharCodes(payload);
      print("message: ");
      print(message);

      nfcReaderValue.value = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = widget.height;
    width = widget.width;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              width: width / 1.1,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              height: 250,
              // color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 150,
                    child: Lottie.network(
                      animationUrl,
                    ),
                  ),
                  Text(
                    displayText,
                    style: TextStyle(color: Colors.black, fontSize: 25.0),
                  ),
                ],
              )),
          SizedBox(
            height: height / 50,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              height: height / 15,
              width: width / 1.1,
              child: Center(
                child: Text("Close",
                    style: TextStyle(
                        color: Colors.blue, fontSize: widget.width / 22)),
              ),
            ),
          ),
          SizedBox(height: height / 40)
        ],
      ),
    );
  }
}

class NFCWriter extends StatefulWidget {
  double height, width;
  String soshiLink;
  NFCWriter(this.height, this.width, this.soshiLink);

  @override
  State<NFCWriter> createState() => _NFCWriterState();
}

class _NFCWriterState extends State<NFCWriter> {
  String displayText, animationUrl;
  double height, width;
  String soshiLink;
  @override
  void initState() {
    super.initState();
    this.height = widget.height;
    this.width = widget.width;
    this.soshiLink = widget.soshiLink;
    displayText = "Scanning for tags...";
    animationUrl =
        "https://assets8.lottiefiles.com/packages/lf20_maxyrepx.json";
    ndefWrite();
  }

  Future<bool> ndefWrite() async {
    print("writing");
    NfcManager.instance.startSession(
      alertMessage:
          "Touch and hold the Soshi Portal to the top of your iPhone :)", // this is a parameter for iOS only

      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          NfcManager.instance.stopSession(
              errorMessage:
                  "Portal is not compatible or has already been written to :(");
          return false;
        }

        NdefMessage message = NdefMessage([
          NdefRecord.createUri(Uri.parse(soshiLink)),
        ]);

        try {
          await ndef.write(message);

          //setState(() {
          displayText = "Success!";
          animationUrl =
              "https://assets1.lottiefiles.com/packages/lf20_s2lryxtd.json";
          //}); //setState is being called wrong so its wrirting to the tag successfully but showing error message

          await Future.delayed(
              Duration(seconds: 0)); // wait a sec before stopping session
          NfcManager.instance.stopSession();
          return true;
        } catch (e) {
          print(e.toString());
          NfcManager.instance.stopSession(
              errorMessage: "Please re-try activating Soshi Portal.");
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
    return Container();

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
