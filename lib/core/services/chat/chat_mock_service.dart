import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:chat/core/models/chat_user.dart';
import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/services/chat/chat_firebase_service.dart';
import 'package:chat/core/services/chat/chat_service.dart';

class ChatMockService implements ChatService {
  static final List<ChatMessage> _msgs = [
    // ChatMessage(
    //   id: '1',
    //   text: 'Bom dia',
    //   createdAt: DateTime.now(),
    //   userId: '123',
    //   userName: 'Bia',
    //   userImageURL: 'assets/images/avatar.png',
    // ),
    // ChatMessage(
    //   id: '2',
    //   text: 'Bom dia. Teremos reunião hoje?',
    //   createdAt: DateTime.now(),
    //   userId: '456',
    //   userName: 'Ana',
    //   userImageURL: 'assets/images/avatar.png',
    // ),
    // ChatMessage(
    //   id: '3',
    //   text: 'Sim, pode ser agora!',
    //   createdAt: DateTime.now(),
    //   userId: '123',
    //   userName: 'Bia',
    //   userImageURL: 'assets/images/avatar.png',
    // ),
  ];
  static MultiStreamController<List<ChatMessage>>? _controller;
  static final _msgsStream = Stream<List<ChatMessage>>.multi((controller) {
    _controller = controller;
    controller.add(_msgs);
  });

  Future<String?> uploadChatImage(File? image, String imageName) async {}

  @override
  Stream<List<ChatMessage>> messagesStream() {
    return _msgsStream;
  }

  @override
  Future<ChatMessage> save(String text, TypeMessage type, ChatUser user) async {
    final newMessage = ChatMessage(
      id: Random().nextDouble().toString(),
      text: text,
      createdAt: DateTime.now(),
      userId: user.id,
      userName: user.name,
      userImageUrl: user.imageUrl,
      type: type,
    );
    _msgs.add(newMessage);
    _controller?.add(_msgs.reversed.toList());
    return newMessage;
  }
  @override
  Future<void> delete(ChatMessage message, TypeMessage type) async {
    _msgs.remove(_msgs.where((msg) => msg.id == message.id));
  }
}
