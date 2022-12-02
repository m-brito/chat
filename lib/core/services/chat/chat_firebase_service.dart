import 'dart:async';
import 'dart:io';
import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/models/chat_user.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'package:chat/exceptions/http_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatFirebaseService implements ChatService {
  @override
  Stream<List<ChatMessage>> messagesStream() {
    final store = FirebaseFirestore.instance;
    final snapshots = store
        .collection('chat')
        .withConverter(
          fromFirestore: _fromFirestore,
          toFirestore: _toFirestore,
        )
        .orderBy('createdAt', descending: true)
        .snapshots();

    return snapshots.map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    });

    // return Stream<List<ChatMessage>>.multi((controller) {
    //   snapshots.listen((snapshot) {
    //     List<ChatMessage> lista = snapshot.docs.map((doc) {
    //       return doc.data();
    //     }).toList();
    //     controller.add(lista);
    //   });
    // });
  }

  Future<String?> uploadChatImage(File? image, String imageName) async {
    if (image == null) return null;

    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('chat_images').child(imageName);
    await imageRef.putFile(image).whenComplete(() {});
    return await imageRef.getDownloadURL();
  }

  Future<String?> uploadChatAudio(File? audio, String audioName) async {
    if (audio == null) return null;

    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('chat_audios').child(audioName);
    await imageRef.putFile(audio).whenComplete(() {});
    return await imageRef.getDownloadURL();
  }

  @override
  Future<ChatMessage?> save(
      String text, TypeMessage type, ChatUser user) async {
    final store = FirebaseFirestore.instance;

    final msg = ChatMessage(
      id: '',
      text: text,
      createdAt: DateTime.now(),
      userId: user.id,
      userName: user.name,
      userImageUrl: user.imageUrl,
      type: type,
    );

    final docRef = await store
        .collection('chat')
        .withConverter(
          fromFirestore: _fromFirestore,
          toFirestore: _toFirestore,
        )
        .add(msg);

    final doc = await docRef.get();
    return doc.data()!;
  }

  @override
  Future<dynamic> delete(ChatMessage message, TypeMessage type) async {
    final store = FirebaseFirestore.instance;
    try {
      final resp = await store.collection('chat').doc(message.id).delete();
      if (type == TypeMessage.Image) {
        final storage = FirebaseStorage.instance;
        String filePath =
            message.text.toString().split('/chat_images%2F')[1].split('?')[0];

        FirebaseStorage.instance.ref().child('chat_images').child(filePath).delete().then((_) {}).catchError((e) {
          throw HttpException(msg: 'Erro ao deletar imagem');
        });
      }
      else if (type == TypeMessage.Audio) {
        final storage = FirebaseStorage.instance;
        String filePath =
            message.text.toString().split('/chat_audios%2F')[1].split('?')[0];

        FirebaseStorage.instance.ref().child('chat_audios').child(filePath).delete().then((_) {}).catchError((e) {
          throw HttpException(msg: 'Erro ao deletar audio');
        });
      }
      return 'Mensagem deletada';
    } catch (error) {
      throw HttpException(msg: 'Erro ao deletar mensagem');
    }
  }

  // ChatMessage => Map<String, dynamic>
  Map<String, dynamic> _toFirestore(
    ChatMessage msg,
    SetOptions? options,
  ) {
    return {
      'text': msg.text,
      'createdAt': msg.createdAt.toIso8601String(),
      'userId': msg.userId,
      'userName': msg.userName,
      'userImageUrl': msg.userImageUrl,
      'type': ChatMessage.typeMessageToString(msg.type),
    };
  }

  // Map<String, dynamic> => ChatMessage
  ChatMessage _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    return ChatMessage(
      id: doc.id,
      text: doc['text'],
      createdAt: DateTime.parse(doc['createdAt']),
      userId: doc['userId'],
      userName: doc['userName'],
      userImageUrl: doc['userImageUrl'],
      type: ChatMessage.stringToTypeMessage(doc['type']),
    );
  }
}
