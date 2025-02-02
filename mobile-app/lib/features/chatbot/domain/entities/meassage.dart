import 'package:image_picker/image_picker.dart';

class Message {
  final String text;
  final XFile? attachment;
  final bool isUser;

  Message({required this.text, this.attachment, required this.isUser});
}
