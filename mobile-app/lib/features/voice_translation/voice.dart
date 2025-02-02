import 'dart:convert';
import 'dart:io';

import 'package:bemyvoice/core/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class VoiceTranslationScreen extends StatefulWidget {
  const VoiceTranslationScreen({super.key});

  @override
  State<VoiceTranslationScreen> createState() => _VoiceTranslationScreenState();
}

class _VoiceTranslationScreenState extends State<VoiceTranslationScreen> {
  WebSocketChannel? _channel;
  String finalWord = ''; // Holds the final translated text
  String currentCharacter = ''; // Holds the current detected character
  int occurrenceCounter = 0; // Counter to detect repeated characters
  final TextEditingController _controller =
      TextEditingController(); // For editable text box

  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  bool isPlaying = false;
  bool isPaused = false;
  String? audioFilePath; // Store audio file path for playing

  Future<void> openCameraForSignLanguage() async {
    connectWebSocket(); // Connect to WebSocket when opening the camera
    // Logic for opening the camera (trigger this with your preferred method)
  }

  void connectWebSocket() {
    final mlIP = dotenv.env['MLIP']?.isEmpty ?? true
        ? dotenv.env['DEFAULT_MLIP']
        : dotenv.env['MLIP'];
    final wsUrl = 'ws://$mlIP:8001/ws/predict';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel?.stream.listen(
      (message) {
        print('Raw WebSocket message received: $message');

        if (message.startsWith('data: ')) {
          message = message.substring(6); // Strip the "data: " prefix
        }

        try {
          final parsedData = json.decode(message);
          print('Parsed Data: $parsedData'); // Add debug print
          updatePresentCharacter(parsedData);
        } catch (e) {
          print('Error decoding message: $e');
        }
      },
      onDone: () {
        print('WebSocket closed');
      },
      onError: (error) {
        print('WebSocket error: $error');
        disconnectWebSocket();
      },
    );
  }

  void updatePresentCharacter(Map<String, dynamic> parsedData) {
    setState(() {
      if (parsedData.containsKey('Final characters')) {
        List<dynamic> finalCharactersData = parsedData['Final characters'];

        print('Final characters received: $finalCharactersData');

        final String finalText = finalCharactersData.map((char) {
          return char == "SPACE" ? " " : char.toString();
        }).join();

        print('Final text: $finalText');

        _controller.text = finalText;
      } else {
        print('No Final characters found in parsedData');
      }
    });
  }

  Future<void> sendTextToSpeechRequest(String text) async {
    try {
      final mlIP = dotenv.env['MLIP']?.isEmpty ?? true
          ? dotenv.env['DEFAULT_MLIP']
          : dotenv.env['MLIP'];
      final url =
          Uri.parse('http://$mlIP:8001/text_to_speech_return?text=$text');

      final response = await http.post(url);
      if (response.statusCode == 200) {
        final parsedData = json.decode(response.body);
        if (parsedData.containsKey('audio_file')) {
          final audioPath = parsedData['audio_file']['path'];
          print('Audio file path: $audioPath');
          audioFilePath = audioPath; // Save the audio file path for playback
        } else {
          print('No audio file returned.');
        }
      } else {
        print('Failed to get audio: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending text to speech request: $e');
    }
  }

  void playAudio() async {
    if (audioFilePath != null && !isPlaying) {
      await _audioPlayer.play(DeviceFileSource(audioFilePath!));
      setState(() {
        isPlaying = true;
        isPaused = false;
      });
    }
  }

  void pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      isPlaying = false;
      isPaused = true;
    });
  }

  void resumeAudio() async {
    await _audioPlayer.resume();
    setState(() {
      isPlaying = true;
      isPaused = false;
    });
  }

  void stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      isPaused = false;
    });
  }

  void disconnectWebSocket() {
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    disconnectWebSocket();
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Voice Translation'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Button to Start Prediction
            ElevatedButton(
              onPressed: openCameraForSignLanguage,
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Set button color
                padding: EdgeInsets.symmetric(vertical: 16), // Set padding
              ),
              child: Text(
                'Start Prediction',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            // Editable Text Box for Prediction Result
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Prediction result will be displayed here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Button to Send Text for Speech Synthesis
            ElevatedButton(
              onPressed: () async {
                final text = _controller.text;
                await sendTextToSpeechRequest(text);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Set button color
                padding: EdgeInsets.symmetric(vertical: 16), // Set padding
              ),
              child: Text(
                'Generate Speech',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            // Audio Controls
            if (audioFilePath != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: isPlaying ? pauseAudio : playAudio,
                    iconSize: 36,
                  ),
                  IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: stopAudio,
                    iconSize: 36,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
