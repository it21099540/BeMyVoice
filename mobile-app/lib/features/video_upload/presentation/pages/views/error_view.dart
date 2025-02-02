import 'package:flutter/material.dart';
import 'package:bemyvoice/core/common/widgets/custom_snack_bar.dart';
import 'package:bemyvoice/core/common/widgets/custom_button.dart';

class ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorView({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSnackBar(
            message: 'Failed to upload video: $errorMessage',
            isError: true,
          ),
          const SizedBox(height: 20),
          CustomButton(
            buttonText: 'Retry',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
