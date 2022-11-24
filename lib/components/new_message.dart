import 'dart:io';
import 'dart:math';

import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/models/chat_user.dart';
import 'package:chat/core/services/auth/auth_service.dart';
import 'package:chat/core/services/chat/chat_firebase_service.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  String _message = '';
  final _messageController = TextEditingController();
  TypeMessage _typeMessage = TypeMessage.Text;
  File? _image;

  Future<ChatMessage?> _sendMessage() async {
    final user = AuthService().currentUser;

    if (user != null) {
      final result = await ChatService().save(_message, _typeMessage, user);
      _messageController.clear();
      setState(() => _message = '');
      return result;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 150,
    );

    if(pickedImage != null) {
      setState(() {
        _typeMessage = TypeMessage.Image;
        _image = File(pickedImage.path);
      });
      final imageName = '${Random().nextDouble().toString()}.jpg';
      final imageUrl = await ChatFirebaseService().uploadChatImage(_image, imageName);

      setState(() {
        _message = imageUrl ?? 'image';
      });

      await _sendMessage();

      // widget.onImagePick(_image!);
    }
  }

  Future<void> _sendAudio() async {}

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: _messageController,
              onChanged: (msg) {
                setState(() => _message = msg);
                setState(() => _typeMessage = TypeMessage.Text);
              },
              onSubmitted: (_) {
                if (_message.trim().isNotEmpty) {
                  _sendMessage();
                }
              },
              decoration:
                  const InputDecoration(labelText: 'Enviar mensagem...'),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.filter),
        ),
        IconButton(
          onPressed: () => _pickImage(ImageSource.camera),
          icon: const Icon(Icons.camera_alt),
        ),
        IconButton(
          onPressed: _message.trim().isEmpty ? _sendAudio : _sendMessage,
          icon: Icon(_message.trim().isEmpty ? Icons.mic : Icons.send),
        ),
      ],
    );
  }
}
