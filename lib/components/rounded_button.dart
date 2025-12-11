import 'package:expense_tracker/core/widgets/themes/app_colors.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final Color colorStart;
  final Color colorEnd;
  final Color textColor;
  final FontWeight fontWeight;
  final double width;
  const RoundedButton({
    super.key, 
    required this.text, 
    required this.press, 
    this.colorStart = bluePrimaryColor,
    this.colorEnd = violetPrimaryColor,
    this.textColor = Colors.black, 
    this.fontWeight = FontWeight.bold, 
    this.width = 0.0
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container (
      width: width == 0.0 ? size.width * 0.8 : width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorStart, colorEnd],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5, 
            offset: const Offset(0, 3)
          )
        ]
      ),
      child: ClipRRect(
        child: FilledButton(
          onPressed: press,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            )
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.black.withValues(alpha: 0.1);
                }
                return null;
              },
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor, 
              fontSize: 16,
              fontWeight: fontWeight, 
              ),
          ),
        ),
      ),
    );
  }
}

