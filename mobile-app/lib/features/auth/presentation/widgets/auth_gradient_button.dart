import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AuthGradientButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final IconData? icon;

  const AuthGradientButton({
    required this.buttonText,
    required this.onPressed,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: AppPalette.primaryGradient,
      ),
      child: MaterialButton(
        minWidth: double.infinity,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppPalette.textSecondaryColor,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              buttonText,
              style: TextStyle(
                color: AppPalette.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
