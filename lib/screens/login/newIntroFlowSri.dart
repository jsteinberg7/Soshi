import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
    print("reanimating with current apge: " + currentPage.toString());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Colors.grey[850],
        centerTitle: true,
        title: Container(
          child: Image.asset(
            "assets/images/SoshiLogos/soshi_logo2.png",
            width: 200,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
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
                  message: "Share socials with 1 tap!",
                ),
                IntroSingleScreen(
                  message: "Connect with your community through groups",
                ),
                IntroSingleScreen(
                  message: "Get rewarded for engaging with your community",
                )
              ],
            ),
          ),
          // SizedBox(height: 10),
          SmoothPageIndicator(
            controller: controller, // PageController
            count: 3,
            effect: WormEffect(
                activeDotColor: Colors.cyan, dotColor: Colors.grey), // your preferred effect
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: GestureDetector(
              onTap: () async {
                print("Move to next screen - smooth animation");

                if (currentPage != 2) {
                  await controller.animateToPage(currentPage + 1,
                      duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                } else {
                  // After the 3 intro screens are done, push to registration onboarding process
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return Scaffold(body: RegisterScreen());
                  // }));
                  SuperController superController = new SuperController();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Scaffold(
                        body: NewRegisterFlow(
                      superController,
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
    return Container(
        // color: Colors.red,
        child: Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Big Image here
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            // height: MediaQuery.of(context).size.height - 500,
            // width: MediaQuery.of(context).size.height - 200,
            // {PLACE IMAGE HERE}
            height: 400,
            width: 400,
            // color: Colors.grey,

            child: Image.asset("assets/images/onboarding/intro_1.png"),
          ),
        ),
        // SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Text(
            this.message,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ));
  }
}
