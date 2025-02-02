import 'package:flutter/material.dart';
import 'package:bemyvoice/core/common/widgets/custom_button.dart';

class InitialView extends StatelessWidget {
  final VoidCallback onPickVideo;

  const InitialView({required this.onPickVideo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No video selected.'),
          const SizedBox(height: 20),
          CustomButton(
            buttonText: 'Pick Video',
            icon: Icons.video_library_outlined,
            onPressed: onPickVideo,
          ),
        ],
      ),
    );
  }
}
