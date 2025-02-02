import 'package:flutter/material.dart';

class SignLanguageDisplay extends StatelessWidget {
  final String signLanguageTranslation;
  const SignLanguageDisplay({required this.signLanguageTranslation, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          signLanguageTranslation.isNotEmpty
              ? signLanguageTranslation
              : "Sign Language Translation will appear here.",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
    ;
  }
}
