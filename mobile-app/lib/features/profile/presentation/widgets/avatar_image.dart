import 'package:flutter/material.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';

class ProfileImageWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const ProfileImageWidget({
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppPalette.primaryColor,
                width: 2,
              ),
              shape: BoxShape.circle,
              color: Colors.grey,
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 50,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
