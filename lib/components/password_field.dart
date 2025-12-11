
import 'package:expense_tracker/components/text_field_container.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final ValueChanged<String> onChange;
  const PasswordField({
    super.key, 
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: true,
        onChanged: onChange,
        style: const TextStyle(
          color: Colors.white
        ),
        decoration: InputDecoration(
          hintText: "Password",
          hintStyle: TextStyle(
            color: Colors.grey[350],
          ),
          suffixIcon: Icon(
            Icons.visibility, 
            color: Colors.white,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
