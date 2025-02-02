import 'dart:convert';
import 'dart:io';

import 'package:bemyvoice/core/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:bemyvoice/core/common/widgets/custom_snack_bar.dart';
import 'package:bemyvoice/features/video_upload/presentation/pages/views/error_view.dart';
import 'package:bemyvoice/features/video_upload/presentation/pages/views/loading_view.dart';
import 'package:bemyvoice/features/video_upload/presentation/pages/views/video_player_view.dart';
import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:bemyvoice/features/video_upload/domain/entities/video.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

enum UploadState { initial, loading, success, failure }

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({Key? key}) : super(key: key);

  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _controller;
  Video? _video;
  File? _audio;
  UploadState _uploadState = UploadState.initial;
  String? _errorMessage;
  String? _transcription;

  Future<void> _pickVideo() async {
    setState(() {
      _uploadState = UploadState.loading;
      _errorMessage = null;

      // Clear any previously uploaded audio
      _audio = null;
      _transcription = null; // Clear transcription when a new video is selected
    });

    try {
      final XFile? xfile = await _picker.pickVideo(source: ImageSource.gallery);
      if (xfile != null) {
        final file = File(xfile.path);
        setState(() {
          _video = Video(xfile.path);
          _controller = VideoPlayerController.file(file)
            ..initialize().then((_) {
              if (mounted) {
                setState(() {});
                _controller!.play();
              }
            });
          _uploadState = UploadState.success;
        });
      } else {
        setState(() {
          _uploadState = UploadState.initial;
        });
      }
    } catch (e) {
      setState(() {
        _uploadState = UploadState.failure;
        _errorMessage = e.toString();
      });
    }
  }

  Future<String> _sendAudioToML(File audioFile) async {
    final String mlIP = dotenv.env['MLIP'] ?? '127.0.0.1';
    final url = Uri.parse('http://$mlIP:8000/speech_to_text');

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        'Content-Type': 'multipart/form-data',
        'accept': 'application/json',
      })
      ..files.add(await http.MultipartFile.fromPath(
        'audio_file',
        audioFile.path,
        contentType: MediaType('audio', 'wav'),
      ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decoded = json.decode(responseBody);
        return decoded['transcription'] ?? 'Transcription not found';
      } else {
        throw Exception('Failed to get transcription from ML service');
      }
    } catch (e) {
      _showSnackBar('Error sending audio to ML service: $e', true);
      return 'Error: $e';
    }
  }

  Future<void> _pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _audio = File(result.files.single.path!);

          // Clear any previously uploaded video
          _video = null;
          _controller?.dispose();
          _controller = null;
        });
        _showSnackBar('Audio file selected successfully!', false);

        // Display loading indicator
        setState(() {
          _transcription = 'Loading...'; // Display loading state
          _uploadState = UploadState.loading; // Set upload state to loading
        });

        // Send the audio file to the ML endpoint and get the transcription
        String transcription = await _sendAudioToML(_audio!);
        setState(() {
          _transcription = transcription;
          _uploadState = UploadState.success; // Update upload state to success
        });
        _showSnackBar('Transcription: $transcription', false);
      } else {
        _showSnackBar('Audio selection cancelled', true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _uploadState = UploadState.failure; // Update upload state to failure
      });
      _showSnackBar('Error selecting audio: $_errorMessage', true);
    }
  }

  void _retryUpload() {
    _pickVideo();
  }

  void _showSnackBar(String message, bool isError) {
    final messenger = ScaffoldMessenger.of(context);
    if (messenger.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Upload Media'),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickVideo,
            child: const Icon(Icons.video_call),
            backgroundColor: AppPalette.primaryColor,
            foregroundColor: AppPalette.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _pickAudio,
            child: const Icon(Icons.audiotrack),
            backgroundColor: AppPalette.primaryColor,
            foregroundColor: AppPalette.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_audio != null) _buildAudioFileView(),
          if (_transcription != null)
            TranscriptionResultWidget(transcription: _transcription!),
          SizedBox(height: 16), // Ensure spacing
          _buildUploadStateView(), // Ensure this doesn’t overflow
        ],
      ),
    );
  }

  Widget _buildUploadStateView() {
    switch (_uploadState) {
      case UploadState.loading:
        return const LoadingView();
      case UploadState.success:
        return _video != null
            ? VideoPlayerView(video: _video!)
            : const SizedBox.shrink();
      case UploadState.failure:
        return ErrorView(
          errorMessage: _errorMessage ?? 'Unknown error',
          onRetry: _retryUpload,
        );
      case UploadState.initial:
      default:
        return const SizedBox
            .shrink(); // No initial view since the button is floating
    }
  }

  Widget _buildAudioFileView() {
    if (_audio == null) return const SizedBox.shrink(); // Avoid null errors
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.audiotrack, size: 40, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _audio!.path.split('/').last,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _audio = null;
                _transcription =
                    null; // Clear transcription if audio is removed
              });
            },
          ),
        ],
      ),
    );
  }
}

class TranscriptionResultWidget extends StatelessWidget {
  final String transcription;

  const TranscriptionResultWidget({Key? key, required this.transcription})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.text_snippet, size: 40, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Transcription:',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _buildSignLanguageImages(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSignLanguageImages() {
    return transcription
        .toUpperCase()
        .split('')
        .where((char) =>
            char.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            char.codeUnitAt(0) <=
                'Z'.codeUnitAt(0)) // Filter out non-alphabet characters
        .map((char) => SignLanguageImage(letter: char))
        .toList();
  }
}

class SignLanguageImage extends StatelessWidget {
  final String letter;

  const SignLanguageImage({Key? key, required this.letter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/images/${letter.toUpperCase()}.jpeg';

    return Image.asset(
      assetPath,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
    );
  }
}
