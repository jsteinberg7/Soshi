import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:soshi/constants/utilities.dart';
import 'package:soshi/screens/login/newRegisterFlowSri.dart';
import 'package:soshi/screens/login/superController.dart';

class NewIntroFlow extends StatefulWidget {
  const NewIntroFlow({Key key}) : super(key: key);

  @override
  State<NewIntroFlow> createState() => _NewIntroFlowState();
}

class _NewIntroFlowState extends State<NewIntroFlow> {
  final controller = PageController(initialPage: 0);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    print("reanimating with current page: " + currentPage.toString());
    double width = Utilities.getWidth(context);
    double height = Utilities.getHeight(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Container(
          child: Theme.of(context).brightness == Brightness.light
              ? Image.asset(
                  "assets/images/SoshiLogos/blackSoshiWriting.png",
                  width: Utilities.getWidth(context) / 3,
                )
              : Image.asset(
                  "assets/images/SoshiLogos/whiteSoshiWriting.png",
                  width: Utilities.getWidth(context) / 3,
                ),

          // Image.asset(
          //   "assets/images/SoshiLogos/SoshiBubbleLogo.png",
          //   width: width / 3,
          // ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SizedBox(
            height: height / 60,
          ),
          Expanded(
            child: PageView(
              onPageChanged: (int newPage) {
                setState(() {
                  currentPage = newPage;
                });
              },
              controller: this.controller,
              // physics: const NeverScrollableScrollPhysics(),
              children: [
                IntroSingleScreen(
                  message: "All of you.\nIn one place.",
                  imageUrl: "assets/images/onboarding/mockup1.png",
                ),
                IntroSingleScreen(
                  message: "Your Soshi code.\nYour portal.",
                  imageUrl: "assets/images/onboarding/mockup2.png",
                ),
                IntroSingleScreen(
                  message: "Everyone you meet.\nIn one place.",
                  imageUrl: "assets/images/onboarding/mockup3.png",
                ),
              ],
            ),
          ),
          // SizedBox(height: 10),
          SmoothPageIndicator(
            controller: controller, // PageController
            count: 3,
            effect: WormEffect(
                activeDotColor: Colors.cyan,
                dotColor: Colors.grey), // your preferred effect
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: GestureDetector(
              onTap: () async {
                print("Move to next screen - smooth animation");

                if (currentPage != 2) {
                  await controller.animateToPage(currentPage + 1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                } else {
                  SuperController superController = new SuperController();
                  ScreenChecker screenChecker = new ScreenChecker();

                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Scaffold(
                        body: NewRegisterFlow(
                      superController: superController,
                      screenChecker: screenChecker,
                    ));
                  }));
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                decoration: currentPage == 2
                    ? BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(30)))
                    : BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Padding(
                  // padding: const EdgeInsets.fromLTRB(100, 15, 100, 15),
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                  child: Center(
                    child: this.currentPage == 2
                        ? Text(
                            "Get Started",
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
    );
  }
}

class IntroSingleScreen extends StatelessWidget {
  final String message;
  String imageUrl;

  // IntroSingleScreen({Key key, String message, String imageUrl}) : super(key: key);

  IntroSingleScreen({this.imageUrl, this.message});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
        // color: Colors.red,
        child: Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Big Image here
        Container(
          // height: MediaQuery.of(context).size.height - 500,
          // width: MediaQuery.of(context).size.height - 200,
          height: height / 1.8,
          //width: 500,
          // color: Colors.grey,

          child: Image.asset(imageUrl),
        ),
        // SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
          child: Text(
            this.message.split("\n")[0],
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Text(
            this.message.split("\n")[1],
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ));
  }
}
