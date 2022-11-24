import 'dart:io';

import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/models/chat_user.dart';
import 'package:chat/core/services/chat/chat_firebase_service.dart';
import 'package:chat/core/services/chat/chat_mock_service.dart';

abstract class ChatService {
  Stream<List<ChatMessage>> messagesStream();

  Future<ChatMessage?> save(String text, TypeMessage type, ChatUser user);
  Future<String?> uploadChatImage(File? image, String imageName);
  Future<dynamic> delete(ChatMessage message, TypeMessage type);

  factory ChatService() {
    // return ChatMockService();
    return ChatFirebaseService();
  }
}