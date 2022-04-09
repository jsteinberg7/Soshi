import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

abstract class Utilities {
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Open QR scanner, return a String of the scanned content
  static Future<String> scanQR(bool mounted) async {
    // store result of scan
    String barcodeScanResult;

    barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", false, ScanMode.QR);

    if (!mounted) {
      return "";
    }
    // return result
    return barcodeScanResult;
  }
}

// class BarcodeScanner extends StatelessWidget {
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Mobile Scanner')),
//       body: MobileScanner(
//           allowDuplicates: false,
//           onDetect: (barcode, args) {
//             final String code = barcode.rawValue;
//             debugPrint('Barcode found! $code');
//           }),
//     );
//   }
// }
