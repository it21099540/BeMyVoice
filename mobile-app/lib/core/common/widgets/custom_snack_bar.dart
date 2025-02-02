import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget {
  final String message;
  final bool isError;

  CustomSnackBar({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
  }
}
