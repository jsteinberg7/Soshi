// import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// import 'package:introduction_screen/introduction_screen.dart';
// import 'package:lottie/lottie.dart';

// class IntroPlay extends StatefulWidget {
//   @override
//   _IntroPlayState createState() => _IntroPlayState();

//   Function refreshApp;

//   IntroPlay({@required Function refresh}) {
//     this.refreshApp = refresh;
//   }
// }

// class _IntroPlayState extends State<IntroPlay> {
//   @override
//   Widget build(BuildContext context) {
//     Color setTextColor =
//         MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black;
//     print("[!] changin text color now!" + setTextColor.toString());

//     return Scaffold(
//         body: Container(
//       // color: Colors.white,
//       child: NeumorphicTheme(
//         themeMode: ThemeMode.light, //or dark / system
//         darkTheme: NeumorphicThemeData(
//           baseColor: Color(0xff333333),
//           accentColor: Colors.green,
//           lightSource: LightSource.topLeft,
//           depth: 4,
//           intensity: 0.3,
//         ),
//         // theme: NeumorphicThemeData(
//         //   baseColor: Color(0xffDDDDDD),
//         //   accentColor: Colors.cyan,
//         //   lightSource: LightSource.topLeft,
//         //   depth: 6,
//         //   intensity: 0.5,
//         // ),
//         child: IntroductionScreen(
//           // color: Colors.white,
//           globalBackgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
//               ? Colors.grey[850]
//               : Colors.grey[50],

//           pages: [
//             PageViewModel(
//               titleWidget: Text(
//                 "Welcome to Soshi!",
//                 style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: setTextColor),
//               ),
//               // body: "All your social media in 1 place!",
//               bodyWidget: Text(
//                 "All your social media in 1 place!",
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: setTextColor,
//                     fontStyle: FontStyle.italic),
//               ),
//               image: Center(
//                   child: Lottie.network(
//                       "https://assets10.lottiefiles.com/private_files/lf30_lttvuxbp.json",
//                       height: 250,
//                       fit: BoxFit.contain)),
//             ),
//             PageViewModel(
//               titleWidget: Text(
//                 "Easily share with QR code",
//                 style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: setTextColor),
//               ),
//               bodyWidget: Text(
//                 "All your socials in a single QR code",
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: setTextColor,
//                     fontStyle: FontStyle.italic),
//               ),
//               image: Center(
//                 // child: Image.network("https://domaine.com/image.png", height: 175.0),
//                 child: Lottie.network("https://assets9.lottiefiles.com/packages/lf20_q30c1wrm.json",
//                     height: 350, fit: BoxFit.contain),
//               ),
//             ),
//             PageViewModel(
//               titleWidget: Text(
//                 "Make new friends!",
//                 style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: setTextColor),
//               ),
//               bodyWidget: Text(
//                 "Keep the conversation going",
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: setTextColor,
//                     fontStyle: FontStyle.italic),
//               ),
//               image: Center(
//                 child: Lottie.network("https://assets2.lottiefiles.com/packages/lf20_uge1w2vt.json",
//                     height: 250),
//               ),
//             ),
//             PageViewModel(
//               titleWidget: Text(
//                 "Make \$ with a switch",
//                 style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: setTextColor),
//               ),
//               bodyWidget: Text(
//                 "Get comissions to advertise businesses",
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: setTextColor,
//                     fontStyle: FontStyle.italic),
//               ),
//               image: Center(
//                 // https://assets5.lottiefiles.com/packages/lf20_OdVhgq.json
//                 // https://assets5.lottiefiles.com/packages/lf20_ep1tn2ew.json
//                 child: Lottie.network("https://assets5.lottiefiles.com/packages/lf20_OdVhgq.json",
//                     height: 250),
//               ),
//             )
//           ],
//           dotsDecorator:
//               DotsDecorator(size: Size(15, 15), activeColor: Colors.cyan, activeSize: Size(30, 30)),
//           showDoneButton: true,

//           done: Icon(Icons.check_circle_rounded, size: 70, color: Colors.cyan),

//           next: Icon(Icons.arrow_circle_right_rounded, size: 70, color: Colors.cyan),
//           onDone: () {
//             // When done button is pressed
//             // widget.refreshApp();
//             // Navigator.push(context, MaterialPageRoute(builder: (context) {
//             //   return Scaffold(body: RegisterScreen());
//             // }));
//           },
//           // showNextButton: true,

//           // showSkipButton: true,
//           // skip: const Text("Skip"),
//         ),
//       ),
//     ));
//   }
// }
