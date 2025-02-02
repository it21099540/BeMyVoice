import 'package:bemyvoice/core/common/widgets/custom_app_bar.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:bemyvoice/features/live_meeting_translator/presentation/pages/join_with_code.dart';
import 'package:bemyvoice/features/live_meeting_translator/presentation/pages/new_meeting.dart';
import 'package:flutter/material.dart';
import 'package:bemyvoice/core/common/entities/user.dart' as currentUser;

class LiveMeetingTranslatorScreen extends StatefulWidget {
  final currentUser.User user;
  const LiveMeetingTranslatorScreen({super.key, required this.user});

  @override
  State<LiveMeetingTranslatorScreen> createState() =>
      _LiveMeetingTranslatorScreenState();
}

class _LiveMeetingTranslatorScreenState
    extends State<LiveMeetingTranslatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Video Conference'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppPalette.primaryGradient,
                ),
                child: MaterialButton(
                  onPressed: () {
                    navigateWithSlideTransition(
                      context,
                      NewMeetingScreen(), // Replace with your NewMeeting screen
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam,
                        color: AppPalette.textSecondaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'New meeting',
                        style: TextStyle(
                          color: AppPalette.textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: AppPalette.borderColor,
                thickness: 1,
                indent: 10,
                endIndent: 10,
                height: 40,
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppPalette.transparent,
                  border: Border.all(color: AppPalette.primaryColor),
                ),
                child: MaterialButton(
                  onPressed: () {
                    navigateWithSlideTransition(
                      context,
                      JoinWithCode(user: widget.user),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: AppPalette.primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Join with a code',
                        style: TextStyle(
                          color: AppPalette.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Common function to navigate with a slide transition
void navigateWithSlideTransition(BuildContext context, Widget screen) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration:
          const Duration(milliseconds: 500), // Optional: Adjust the duration
    ),
  );
}
