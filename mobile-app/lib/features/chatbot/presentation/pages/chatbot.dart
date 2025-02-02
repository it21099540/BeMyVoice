import 'dart:convert';
import 'dart:io';
import 'package:bemyvoice/features/chatbot/domain/entities/meassage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:bemyvoice/core/common/widgets/custom_app_bar.dart';
import 'package:bemyvoice/features/chatbot/presentation/widgets/input_section.dart';
import 'package:bemyvoice/features/chatbot/presentation/widgets/message_bubble.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  XFile? _selectedAttachment;
  String currentCharacter = '';
  int occurrenceCounter = 0;
  String finalWord = '';
  WebSocketChannel? _channel;

  Future<String> getChatbotResponse(String message) async {
    String messageResponse = 'Error occurred';
    final mlIP = dotenv.env['MLIP']?.isEmpty ?? true
        ? dotenv.env['DEFAULT_MLIP']
        : dotenv.env['MLIP'];
    final url = 'http://$mlIP:8001/chatbot/';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'message': message}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        messageResponse = data['response'] ?? 'No response from bot';
      } else {
        messageResponse =
            'Failed to get response from bot: ${response.statusCode}';
      }
    } on SocketException {
      messageResponse = 'No Internet connection';
    } catch (e) {
      messageResponse = 'Error: $e';
    }

    return messageResponse;
  }

  // Future<String> sendFinalWords(List<String> finalWords) async {
  //   String responseMessage = 'Error sending final words';
  //   final mlIP = dotenv.env['MLIP']?.isEmpty ?? true
  //       ? dotenv.env['DEFAULT_MLIP']
  //       : dotenv.env['MLIP'];

  //   // Construct the URL with query parameters
  //   final uri =
  //       Uri.parse('http://$mlIP:8001/final_words').replace(queryParameters: {
  //     'final_words': finalWords,
  //   });

  //   try {
  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         'Accept': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       responseMessage = data['sent'] ?? 'No response from final words API';
  //     } else {
  //       responseMessage = 'Failed to send final words: ${response.statusCode}';
  //     }
  //   } on SocketException {
  //     responseMessage = 'No Internet connection';
  //   } catch (e) {
  //     responseMessage = 'Error: $e';
  //   }

  //   return responseMessage;
  // }

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
        if (message.startsWith('data: ')) {
          message = message.substring(6); // Strip the "data: " prefix
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

  void disconnectWebSocket() {
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty || _selectedAttachment != null) {
      // Update the state to show the user's message in the chat.
      setState(() {
        _messages.add(Message(
          text: text,
          isUser: true,
          attachment: _selectedAttachment,
        ));
        _controller.clear();
        _selectedAttachment = null;

        // Reset finalWord after sending it.
        finalWord = '';
        occurrenceCounter = 0;
        currentCharacter = '';
      });

      // Directly send the user's message to the chatbot endpoint.
      final chatbotResponse = await getChatbotResponse(text);
      setState(() {
        _messages.add(Message(text: chatbotResponse, isUser: false));
      });
    }
  }

  void _handleAttachment(XFile? file) {
    setState(() {
      _selectedAttachment = file;
    });
  }

  @override
  void dispose() {
    disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chatbot',
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: disconnectWebSocket, // Close WebSocket on close
          ),
        ],
      ),
      backgroundColor: AppPalette.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: openCameraForSignLanguage,
                ),
                Expanded(
                  child: InputSection(
                    controller: _controller,
                    onSend: _handleSend,
                    onAttachmentSelected: _handleAttachment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
