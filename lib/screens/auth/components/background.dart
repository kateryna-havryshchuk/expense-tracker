
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    super.key,
    required this.child,
  });


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
     width: double.infinity,
     height: size.height,
     decoration: BoxDecoration(
     gradient: LinearGradient(
       colors: [Color(0xFF6366F1), Color(0xFF9F66D4) ],
       stops: [0.0, 1.0],
       begin: Alignment.topLeft,
       end: Alignment.centerRight,
     ),
     ),
     child: Stack(
       alignment: Alignment.center,
       children: [
         Positioned(
         top: 30,
           left: 90,
           child: Image.asset(
             "assets/images/circle3.png",
             width: size.width * 0.3
           )
         ),
         Positioned(
           top: 60,
           child: Image.asset(
             "assets/images/logo.png",
             width: size.width * 0.3
           )
         ),
         child,
       ]
     )
    );
  }
}