import 'package:flutter/material.dart';

class SettingSectionHeader extends StatelessWidget {
  final String title;
  const SettingSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0, left: 20.0, bottom: 12.0),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}