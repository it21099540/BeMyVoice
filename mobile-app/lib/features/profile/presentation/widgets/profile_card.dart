import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class ProfileCardWidget extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final void Function()? onTap;

  const ProfileCardWidget({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
    super.key,
  });

  @override
  State<ProfileCardWidget> createState() => _ProfileCardWidgetState();
}

class _ProfileCardWidgetState extends State<ProfileCardWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () {}, // Trigger onTap if provided
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppPalette.secondaryColor,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(widget.icon, color: AppPalette.primaryColor),
                SizedBox(width: 10),
                Text(
                  widget.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppPalette.textPrimaryColor),
                ),
                Expanded(
                  child: Text(
                    widget.value,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
