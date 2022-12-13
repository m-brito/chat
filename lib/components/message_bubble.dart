import 'dart:ffi';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatefulWidget {
  static const _defaultImage = 'assets/images/avatar.png';
  final ChatMessage message;
  final bool belongsToCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.belongsToCurrentUser,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _playAudio = false;
  bool twoVel = false;
  final recordingPlayer = AssetsAudioPlayer();

  Widget _showUserImage(String imageUrl) {
    ImageProvider? provider;
    final uri = Uri.parse(imageUrl);
    final recordingPlayer = AssetsAudioPlayer();

    if (uri.path.contains(MessageBubble._defaultImage)) {
      provider = const AssetImage(MessageBubble._defaultImage);
    } else if (uri.scheme.contains('http')) {
      provider = NetworkImage(uri.toString());
    } else {
      provider = FileImage(File(uri.toString()));
    }

    return CircleAvatar(
      backgroundImage: provider,
    );
  }

  Future<void> _playAudioRecord(url) async {
    setState(() {
      _playAudio = true;
    });
    recordingPlayer.open(
      Audio.network(url),
      autoStart: true,
      showNotification: true,
      playSpeed: twoVel ? 2 : 1
    );
    recordingPlayer.playerState.listen((event) {
      if (event.name != 'stop') {
        setState(() {
          _playAudio = true;
        });
      } else {
        setState(() {
          _playAudio = false;
        });
      }
    });
  }

  void _alternaVel() {
    setState(() {
      twoVel = !twoVel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return Stack(
      children: [
        Row(
          mainAxisAlignment: widget.belongsToCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              // width: ((message.text.characters.length * 80) < 180) ? message.text.characters.length * 50 : 180,
              width: 180,
              // constraints: BoxConstraints(
              //   maxWidth: MediaQuery.of(context).size.width * 0.8
              // ),
              child: Material(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: widget.belongsToCurrentUser
                      ? const Radius.circular(12)
                      : const Radius.circular(0),
                  bottomRight: widget.belongsToCurrentUser
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
                ),
                color: widget.belongsToCurrentUser
                    ? Colors.grey.shade300
                    : Theme.of(context).colorScheme.primary,
                child: InkWell(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: widget.belongsToCurrentUser
                        ? const Radius.circular(12)
                        : const Radius.circular(0),
                    bottomRight: widget.belongsToCurrentUser
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                  onLongPress: widget.belongsToCurrentUser
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
                                try {
                                  final resp = await ChatService().delete(
                                      widget.message, widget.message.type);
                                  msg.showSnackBar(
                                    SnackBar(
                                      content: Text(resp),
                                    ),
                                  );
                                } catch (error) {
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
                      crossAxisAlignment: widget.belongsToCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: widget.belongsToCurrentUser
                              ? const EdgeInsets.only(left: 10)
                              : const EdgeInsets.only(right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.message.userName,
                                style: TextStyle(
                                  color: widget.belongsToCurrentUser
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('HH:mm')
                                    .format(widget.message.createdAt),
                                style: TextStyle(
                                  color: widget.belongsToCurrentUser
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.message.type == TypeMessage.Text)
                          Text(
                            widget.message.text,
                            style: TextStyle(
                              color: widget.belongsToCurrentUser
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            textAlign: widget.belongsToCurrentUser
                                ? TextAlign.end
                                : TextAlign.start,
                          ),
                        if (widget.message.type == TypeMessage.Image)
                          Image.network(
                            widget.message.text,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        if (widget.message.type == TypeMessage.Audio)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await _playAudioRecord(widget.message.text);
                                },
                                icon: !_playAudio
                                    ? const Icon(Icons.play_arrow)
                                    : const Icon(Icons.pause),
                              ),
                              TextButton(
                                onPressed: _alternaVel,
                                child: Text(
                                  twoVel ? '2x' : '1x',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          )
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
          left: widget.belongsToCurrentUser ? null : 165,
          right: widget.belongsToCurrentUser ? 165 : null,
          child: _showUserImage(widget.message.userImageUrl),
        ),
      ],
    );
  }
}
