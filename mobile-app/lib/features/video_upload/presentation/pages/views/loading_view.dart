import 'package:flutter/material.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';

class LoadingView extends StatelessWidget {
  const LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppPalette.primaryColor),
      ),
    );
  }
}
