import 'package:chat/components/message_bubble.dart';
import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/services/auth/auth_service.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List _date = [];
  showLabelDate(msgs, index) {
    final indexAnterior = index < msgs.length - 1 ? index + 1 : 0;
    String createdAt = DateFormat('dd/MM/yyyy').format(msgs[index].createdAt);
    String hoje = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String label;
    if(createdAt == hoje) {
      label = 'Hoje';
    } else if(createdAt == DateFormat('dd/MM/yyyy').format(DateTime.now().add(const Duration(days: -1)))) {
      label = 'Ontem';
    } else {
      label = createdAt;
    }
    if (DateFormat('dd/MM/yyyy').format(msgs[indexAnterior].createdAt) != createdAt || index == msgs.length - 1) {
      return [
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 241, 241, 241),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    return StreamBuilder<List<ChatMessage>>(
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Sem Dados. Vamos conversar?'));
        } else {
          final msgs = snapshot.data!;
          return ListView.builder(
            reverse: true,
            itemBuilder: (context, index) {
              _date = showLabelDate(msgs, index);
              return Column(
                children: [
                  ..._date,
                  MessageBubble(
                    key: ValueKey(msgs[index].id),
                    message: msgs[index],
                    belongsToCurrentUser: currentUser?.id == msgs[index].userId,
                  ),
                ],
              );
            },
            itemCount: msgs.length,
          );
        }
      },
      stream: ChatService().messagesStream(),
    );
  }
}
