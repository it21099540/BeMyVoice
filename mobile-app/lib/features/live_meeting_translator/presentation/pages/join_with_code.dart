import 'package:bemyvoice/core/common/widgets/custom_app_bar.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:bemyvoice/features/live_meeting_translator/presentation/pages/video_call.dart';
import 'package:flutter/material.dart';
import 'package:bemyvoice/core/common/entities/user.dart' as currentUser;

class JoinWithCode extends StatefulWidget {
  final currentUser.User user;
  const JoinWithCode({super.key, required this.user});

  @override
  _JoinWithCodeState createState() => _JoinWithCodeState();
}

class _JoinWithCodeState extends State<JoinWithCode> {
  final TextEditingController _meetingCodeController = TextEditingController();

  @override
  void dispose() {
    _meetingCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Join a meeting'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: _meetingCodeController,
              decoration: InputDecoration(
                hintText: 'Enter meeting code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Join with a personal link name',
              style: TextStyle(
                color: AppPalette.primaryColor,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: widget.user.displayName),
              decoration: InputDecoration(
                hintText: widget.user.displayName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: AppPalette.primaryGradient,
              ),
              child: MaterialButton(
                onPressed: () {
                  final meetingCode = _meetingCodeController.text.trim();
                  if (meetingCode.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCall(
                          channelName: meetingCode,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid meeting code'),
                        backgroundColor: AppPalette.primaryColor,
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Join',
                      style: TextStyle(
                        color: AppPalette.textSecondaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'If you received an invitation link, tap on the link to join the meeting',
              style: TextStyle(
                color: AppPalette.textPrimaryColor
                    .withOpacity(0.5), // Adjusts the opacity
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
