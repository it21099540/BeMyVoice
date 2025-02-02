import 'dart:math';
import 'package:bemyvoice/core/common/widgets/custom_app_bar.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:bemyvoice/features/live_meeting_translator/presentation/pages/video_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewMeetingScreen extends StatefulWidget {
  const NewMeetingScreen({super.key});

  @override
  State<NewMeetingScreen> createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends State<NewMeetingScreen> {
  late String _meetingId;

  @override
  void initState() {
    super.initState();
    _meetingId = _generateRandomMeetingId();
  }

  // Function to generate a random meeting ID
  String _generateRandomMeetingId() {
    const length = 6; // Define the length of the meeting ID
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'New Meeting'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              'Your meeting is ready',
              style: TextStyle(
                color: AppPalette.primaryColor,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: _meetingId,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    final data = ClipboardData(text: _meetingId);
                    Clipboard.setData(data);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppPalette.primaryColor,
                      ),
                    );
                  },
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
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share,
                      color: AppPalette.textSecondaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Share invite',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCall(
                        channelName: _meetingId,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_call,
                      color: AppPalette.primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Start Call',
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
    );
  }
}
