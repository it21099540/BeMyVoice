import 'package:flutter/material.dart';

class AuthDescription extends StatelessWidget {
  final String text;
  const AuthDescription({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0), // Adjust the padding value as needed
      child: Text(
        text,
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
