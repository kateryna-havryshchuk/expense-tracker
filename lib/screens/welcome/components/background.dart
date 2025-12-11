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
    return SizedBox(
      height: size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 90,
            right:90,
            child: Image.asset(
              "assets/images/circle1.png",
              width: size.width * 0.3
            )
          ),
          Positioned(
            top: 130,
            child: Image.asset(
              "assets/images/logo.png",
              width: size.width * 0.3
            )
          ),
            Positioned(
            bottom: 380,
            right: 230,
            child: Image.asset(
              "assets/images/tab1.png",
              width: size.width * 0.3
              ),
            ),
          Positioned(
            bottom: 380,
            right: 130,
            child: Image.asset(
              "assets/images/tab2.png",
              width: size.width * 0.3
              ),
            ),
           Positioned(
            bottom: 380,
            right: 30,
            child: Image.asset(
              "assets/images/tab3.png",
              width: size.width * 0.3
            )
          ),
          Positioned(
            bottom: 190,
            left:30,
            child: Image.asset(
              "assets/images/circle2.png",
              width: size.width * 0.4
            )
          ),
          child,
        ]
      )
    );
  }
}