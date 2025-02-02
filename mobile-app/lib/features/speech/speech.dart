import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  bool isListening = false;
  late stt.SpeechToText _speechToText;
  String text = "Press the button & start speaking";
  double confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _requestMicrophonePermission();
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
      print('Microphone permission granted: ${status.isGranted}');
    }
  }

  void _captureVoice() async {
    if (!isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          // Log status changes if needed
          print('onStatus: $status');

          // If the microphone stops listening, reset the state
          if (status == 'notListening' || status == 'done') {
            setState(() {
              isListening = false; // Reset the listening state
            });
          }
        },
        onError: (error) {
          print('onError: $error');
        },
      );
      print('Speech-to-Text is available: $available');
      if (available) {
        setState(() => isListening = true);
        _speechToText.listen(
          onResult: (result) {
            print('Recognized words: ${result.recognizedWords}');
            setState(() {
              text = result.recognizedWords;
              if (result.hasConfidenceRating && result.confidence > 0) {
                confidence = result.confidence;
              }
            });
          },
          listenFor: Duration(seconds: 30), // Listening duration
          localeId: 'en_US', // Set locale for recognition
        );
      }
    } else {
      // If already listening, stop
      setState(() => isListening = false);
      _speechToText.stop();
    }
  }

// Add a method to check and restart listening
  void _checkAndRestartListening() {
    if (!isListening) {
      _captureVoice(); // Restart listening
    }
  }

// Call this method when user starts speaking
  void _onUserStartsSpeaking() {
    _checkAndRestartListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confidence: ${(confidence * 100).toStringAsFixed(1)}%"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: Colors.blue,
        duration: const Duration(milliseconds: 1000),
        repeat: true,
        child: FloatingActionButton(
          backgroundColor: isListening ? Colors.green : Colors.blue,
          onPressed: _captureVoice,
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Successfully copied text"),
                      ),
                    );
                  },
                  child: const Text(
                    "Copy Text",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
