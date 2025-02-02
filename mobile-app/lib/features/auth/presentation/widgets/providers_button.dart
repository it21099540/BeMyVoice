import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class ProviderButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const ProviderButton(
      {required this.icon, required this.text, super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppPalette.primaryColor,
      ),
      child: MaterialButton(
        minWidth: double.infinity,
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppPalette.textSecondaryColor,
              size: 16,
            ),
            SizedBox(width: 10),
            Text(
              text,
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
