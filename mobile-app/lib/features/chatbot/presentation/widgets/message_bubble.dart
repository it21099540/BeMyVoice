import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:bemyvoice/features/chatbot/domain/entities/meassage.dart';
import 'package:flutter/material.dart';
import 'dart:io'; // Import for File

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppPalette.primaryColor
              : AppPalette.secondaryColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: message.attachment != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.file(
                    File(message.attachment!.path), // Display the image
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  if (message.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                ],
              )
            : Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                  fontSize: 16.0,
                ),
              ),
      ),
    );
  }
}
