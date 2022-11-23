import 'package:chat/core/services/chat/chat_firebase_service.dart';

enum TypeMessage {
  Text,
  Audio,
  Image,
}
class ChatMessage {
  final String id;
  final String text;
  final DateTime createdAt;

  final String userId;
  final String userName;
  final String userImageUrl;
  final TypeMessage type;

  ChatMessage({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.type,
  });

  static typeMessageToString(TypeMessage type) {
    if (type == TypeMessage.Text) {
      return 'text';
    } else if (type == TypeMessage.Image) {
      return 'image';
    } else if (type == TypeMessage.Audio) {
      return 'audio';
    } else {
      return 'text';
    }
  }
  static stringToTypeMessage(String type) {
    if (type == 'text') {
      return TypeMessage.Text;
    } else if (type == 'image') {
      return TypeMessage.Image;
    } else if (type == 'audio') {
      return TypeMessage.Audio;
    } else {
      return TypeMessage.Text;
    }
  }
}
