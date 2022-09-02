import 'package:flutter/material.dart';


class BounceContainer extends StatefulWidget {
  Widget child;
  BounceContainer({Key key, Widget child}) : super(key: key);

  @override
  State<BounceContainer> createState() => _BounceContainerState();
}

class _BounceContainerState extends State<BounceContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(  
    decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(100.0),
        // boxShadow: [
        //   BoxShadow(
        //     color: Color(0x80000000),
        //     blurRadius: 12.0,
        //     offset: Offset(0.0, 5.0),
        //   ),
        // ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff33ccff),
            Color(0xffff99cc),
          ],
        )),
    child: widget.child
  );
  }
}
