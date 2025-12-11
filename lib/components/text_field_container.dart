
import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({
    super.key, 
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
