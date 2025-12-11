import 'package:expense_tracker/components/rounded_button.dart';
import 'package:expense_tracker/screens/auth/signin_screen.dart';
import 'package:expense_tracker/screens/auth/singup_screen.dart';
import 'package:flutter/material.dart';
import 'background.dart';

class Body extends StatelessWidget{
  const Body({super.key});
  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.3),
          Text(
            "SmartExpense",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
          Text(
            "Track expenses, build wealth",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.grey),
          ),
          SizedBox(height: size.height * 0.2),
           Text(
            "Welcome to Smart Finance",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
          SizedBox(width: size.width * 0.1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Take control of your expenses with intelligent tracking, insightful analytics, and personalized budgeting tools",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 30),
          RoundedButton(
            text: "Get Started ->",
            press: () {Navigator.push(context, MaterialPageRoute(builder: (context){return SignUpScreen();},),);},
            textColor: Colors.white,
          ),
          const SizedBox(height: 16),
          RoundedButton(
            text: "I already have an account",
            press: () {Navigator.push(context, MaterialPageRoute(builder: (context){return SignInScreen();},),);},
            colorStart: Colors.white,
            colorEnd: Colors.white,
            textColor: Colors.black,
          ),
          ],
        )
    );
  }
}
