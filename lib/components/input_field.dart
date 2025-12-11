
import 'package:expense_tracker/components/text_field_container.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const InputField({
    super.key, 
    required this.hintText, 
    required this.icon, 
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
        color: Colors.white
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[350]
          ),
          border: InputBorder.none,
          suffixIcon: Icon(
            icon, 
            color: Colors.white,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25)
          ),
      ),
    );
  }
}
