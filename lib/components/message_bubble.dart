import 'dart:io';

import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  static const _defaultImage = 'assets/images/avatar.png';
  final ChatMessage message;
  final bool belongsToCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.belongsToCurrentUser,
  });

  Widget _showUserImage(String imageUrl) {
    ImageProvider? provider;
    final uri = Uri.parse(imageUrl);

    if (uri.path.contains(_defaultImage)) {
      provider = const AssetImage(_defaultImage);
    } else if (uri.scheme.contains('http')) {
      provider = NetworkImage(uri.toString());
    } else {
      provider = FileImage(File(uri.toString()));
    }

    return CircleAvatar(
      backgroundImage: provider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return Stack(
      children: [
        Row(
          mainAxisAlignment: belongsToCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              width: 180,
              child: Material(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: belongsToCurrentUser
                      ? const Radius.circular(12)
                      : const Radius.circular(0),
                  bottomRight: belongsToCurrentUser
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
                ),
                color: belongsToCurrentUser
                    ? Colors.grey.shade300
                    : Theme.of(context).colorScheme.primary,
                child: InkWell(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: belongsToCurrentUser
                        ? const Radius.circular(12)
                        : const Radius.circular(0),
                    bottomRight: belongsToCurrentUser
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                  onLongPress: belongsToCurrentUser
                      ? () {
                          showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Tem Certeza?'),
                              content: const Text('Quer deletar a mensagem?'),
                              actions: [
                                TextButton(
                                  child: const Text('Não'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Sim'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop(true);
                                  },
                                ),
                              ],
                            ),
                          ).then(
                            (value) async {
                              if (value == true) {
                                try{
                                  final resp = await ChatService().delete(message.id);
                                  msg.showSnackBar(
                                    SnackBar(
                                      content: Text(resp),
                                    ),
                                  );
                                } catch(error) {
                                  msg.showSnackBar(
                                    SnackBar(
                                      content: Text(error.toString()),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        }
                      : null,
                  splashColor: const Color.fromARGB(255, 0, 0, 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: belongsToCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: belongsToCurrentUser
                              ? const EdgeInsets.only(left: 10)
                              : const EdgeInsets.only(right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                message.userName,
                                style: TextStyle(
                                  color: belongsToCurrentUser
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('hh:mm').format(message.createdAt),
                                style: TextStyle(
                                  color: belongsToCurrentUser
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          message.text,
                          style: TextStyle(
                            color: belongsToCurrentUser
                                ? Colors.black
                                : Colors.white,
                          ),
                          textAlign: belongsToCurrentUser
                              ? TextAlign.end
                              : TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: belongsToCurrentUser ? null : 165,
          right: belongsToCurrentUser ? 165 : null,
          child: _showUserImage(message.userImageUrl),
        ),
      ],
    );
  }
}
