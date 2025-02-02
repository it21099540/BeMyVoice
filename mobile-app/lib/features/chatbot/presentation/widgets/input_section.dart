import 'dart:io';

import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InputSection extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<XFile?> onAttachmentSelected;

  const InputSection({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onAttachmentSelected,
  }) : super(key: key);

  @override
  _InputSectionState createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;

  Future<void> _pickAttachment() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedFile = pickedFile;
    });
    widget.onAttachmentSelected(pickedFile);
  }

  void _removeAttachment() {
    setState(() {
      _selectedFile = null;
    });
    widget.onAttachmentSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedFile != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(_selectedFile!.path),
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2.0,
                  right: 2.0,
                  child: IconButton(
                    icon:
                        Icon(Icons.cancel, color: Colors.red.withOpacity(0.8)),
                    onPressed: _removeAttachment,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                onPressed: _pickAttachment,
                icon: const Icon(Icons.attach_file),
                color: AppPalette.primaryColor,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: () {
                  widget.onSend();
                  setState(() {
                    _selectedFile = null; // Reset file after sending
                  });
                },
                icon: const Icon(Icons.send),
                color: AppPalette.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
