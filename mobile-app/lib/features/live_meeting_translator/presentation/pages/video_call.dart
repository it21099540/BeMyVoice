import 'dart:convert';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VideoCall extends StatefulWidget {
  final String channelName;

  VideoCall({required this.channelName});

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  late final AgoraClient _client;
  bool _loading = true;
  String tempToken = "";
  String predictedLetters = ""; // State variable for predicted letters
  String speechToTextResult = ""; // State variable for speech-to-text result
  WebSocketChannel? _channel;

  String currentCharacter = '';
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();
  late stt.SpeechToText _speechToText;
  bool isListening = false;
  String text = "Press the button & start speaking";

  bool showSpeechToText = false; // Flag to toggle views

  @override
  void initState() {
    super.initState();
    getToken();
    startFetchingPredictions(); // Start fetching predictions from Firebase
    _speechToText = stt.SpeechToText();
    _requestMicrophonePermission();
  }

  Future<void> startPrediction() async {
    connectWebSocket(); // Connect to WebSocket for predictions
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
      print('Microphone permission granted: ${status.isGranted}');
    }
  }

  Future<void> _toggleAgoraAudioStream(bool enable) async {
    if (enable) {
      await _client.engine?.enableLocalAudio(true);
    } else {
      await _client.engine?.enableLocalAudio(false);
    }
  }

  void _captureVoice() async {
    if (!isListening) {
      // Stop Agora audio stream before starting speech recognition
      await _toggleAgoraAudioStream(false);

      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              text = result.recognizedWords;
              speechToTextResult =
                  result.recognizedWords; // Save result to state
            });
          },
          listenFor: Duration(seconds: 30),
          localeId: 'en_US',
        );
      }
    } else {
      setState(() => isListening = false);
      _speechToText.stop();

      // Re-enable Agora audio stream when speech recognition is stopped
      _toggleAgoraAudioStream(true);
    }
  }

  void connectWebSocket() {
    final mlIP = dotenv.env['MLIP']?.isEmpty ?? true
        ? dotenv.env['DEFAULT_MLIP']
        : dotenv.env['MLIP'];
    final wsUrl = 'ws://$mlIP:8001/ws/predict';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel?.stream.listen(
      (message) {
        if (message.startsWith('data: ')) {
          message = message.substring(6);
        }

        try {
          final parsedData = json.decode(message);
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
    if (parsedData.containsKey('Final characters')) {
      List<dynamic> finalCharactersData = parsedData['Final characters'];
      final String finalText = finalCharactersData.map((char) {
        return char == "SPACE" ? " " : char.toString();
      }).join();

      setState(() {
        predictedLetters = finalText; // Update predicted letters state
      });

      // Save the finalText and speechToTextResult to Firebase
      _databaseReference
          .child('predictions/${widget.channelName}/signPrediction')
          .set(finalText);
      _databaseReference
          .child('predictions/${widget.channelName}/speechToText')
          .set(speechToTextResult);
    }
  }

  void startFetchingPredictions() {
    _databaseReference
        .child('predictions/${widget.channelName}')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          final Map<String, dynamic> dataMap = data as Map<String, dynamic>;
          predictedLetters = dataMap['signPrediction']?.toString() ??
              ''; // Update predicted letters from database
          speechToTextResult = data['speechToText']?.toString() ??
              ''; // Update speech-to-text result from database
        });
      }
    });
  }

  void disconnectWebSocket() {
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }

  Future<void> getToken() async {
    final mlIP = dotenv.env['MLIP']?.isEmpty ?? true
        ? dotenv.env['DEFAULT_MLIP']
        : dotenv.env['MLIP'];
    try {
      String link =
          "http://$mlIP:8080/access_token?channelName=${widget.channelName}";

      Response _response = await get(Uri.parse(link));

      if (_response.statusCode == 200) {
        Map data = jsonDecode(_response.body);
        setState(() {
          tempToken = data["token"];
        });

        // Initialize AgoraClient
        _client = AgoraClient(
          agoraConnectionData: AgoraConnectionData(
            appId: "24f4c431d3794e6c8748cc410d44ce1e",
            tempToken: tempToken,
            channelName: widget.channelName,
          ),
          enabledPermission: [Permission.camera, Permission.microphone],
        );

        await _client.initialize();

        Future.delayed(Duration(seconds: 1)).then(
          (value) => setState(() => _loading = false),
        );
      } else {
        print("Failed to fetch token: ${_response.statusCode}");
      }
    } catch (e) {
      print('Error fetching token or initializing Agora: $e');
    }
  }

  @override
  void dispose() {
    disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  AgoraVideoViewer(client: _client),
                  AgoraVideoButtons(client: _client),
                  // Positioned the floating buttons at the top-right corner
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          onPressed: startPrediction,
                          child: Icon(Icons.play_arrow, color: Colors.white),
                          backgroundColor: AppPalette.primaryColor,
                          tooltip: 'Start Prediction',
                        ),
                        SizedBox(height: 16), // Spacing between buttons
                        FloatingActionButton(
                          onPressed: _captureVoice,
                          child: Icon(
                            isListening ? Icons.mic_off : Icons.mic,
                            color: Colors.white,
                          ),
                          backgroundColor: AppPalette.primaryColor,
                          tooltip: isListening
                              ? 'Stop Listening'
                              : 'Start Listening',
                        ),
                      ],
                    ),
                  ),
                  // The rest of your UI remains unchanged
                  Positioned(
                    bottom: 150,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ToggleButtons(
                            fillColor: Colors.deepPurple.shade600,
                            selectedColor: Colors.white,
                            borderColor: Colors.deepPurple,
                            selectedBorderColor: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                            isSelected: [!showSpeechToText, showSpeechToText],
                            onPressed: (int index) {
                              setState(() {
                                showSpeechToText = index == 1;
                              });
                            },
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text("Sign Predictions",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text("Speech to Text",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            showSpeechToText
                                ? speechToTextResult
                                : predictedLetters,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
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
