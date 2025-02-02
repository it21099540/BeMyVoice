import 'package:bemyvoice/core/common/entities/user.dart'; // Import your User class
import 'package:bemyvoice/features/chatbot/presentation/pages/chatbot.dart';
import 'package:bemyvoice/features/live_meeting_translator/presentation/pages/live_meeting_translator.dart';
import 'package:bemyvoice/features/profile/presentation/pages/profile.dart';
import 'package:bemyvoice/features/speech/speech.dart';
import 'package:bemyvoice/features/video_upload/presentation/pages/video_upload.dart';
import 'package:bemyvoice/features/voice_translation/voice.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final User? user; // Accept user details as a parameter

  const BottomNavBar({Key? key, this.user}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Define a list of pages with the user parameter passed to ProfileScreen
    final List<Widget> _pages = [
      VideoUploadScreen(),
      VoiceTranslationScreen(),
      ChatBotScreen(),
      LiveMeetingTranslatorScreen(user: widget.user!),
      ProfileScreen(user: widget.user!),
      // SpeechScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: FlashyTabBar(
        animationCurve: Curves.linear,
        selectedIndex: _selectedIndex,
        iconSize: 30,
        showElevation: false,
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: Icon(Icons.video_collection),
            title: Text('Video'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.mic),
            title: Text('Voice'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.chat),
            title: Text('Chat Bot'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.mic),
            title: Text('Live'),
          ),
          FlashyTabBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
          ),
          // FlashyTabBarItem(
          //   icon: Icon(Icons.person),
          //   title: Text('Speech'),
          // ),
        ],
      ),
    );
  }
}
