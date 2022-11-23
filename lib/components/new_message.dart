import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/services/auth/auth_service.dart';
import 'package:chat/core/services/chat/chat_firebase_service.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  String _message = '';
  final _messageController = TextEditingController();
  bool recording = false;

  Future<void> _sendMessage() async {
    final user = AuthService().currentUser;

    if (user != null) {
      await ChatService().save(_message, TypeMessage.Text, user);
      _messageController.clear();
      setState(() => _message = '');
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
              onChanged: (msg) => setState(() => _message = msg),
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
        const IconButton(
          onPressed: null,
          icon: Icon(Icons.camera_alt),
        ),
        IconButton(
          onPressed: _message.trim().isEmpty ? _sendAudio : _sendMessage,
          icon: Icon(_message.trim().isEmpty ? Icons.mic : Icons.send),
        ),
      ],
    );
  }
}
