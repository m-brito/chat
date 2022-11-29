import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audio_session/audio_session.dart';
import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/services/auth/auth_service.dart';
import 'package:chat/core/services/chat/chat_firebase_service.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:permission_handler/permission_handler.dart';

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
  File? _audio;
  bool isAudioRecording = false;
  bool _showWidgetAudio = false;
  final _recorder = FlutterSoundRecorder();
  final theSource = AudioSource.microphone;

  FlutterSoundRecorder? _recordingSession;
  final recordingPlayer = AssetsAudioPlayer();
  final testRecordingPlayer = AssetsAudioPlayer();
  String? pathToAudio;
  String _timerText = '00:00:00';
  bool _playAudio = false;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

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

    if (pickedImage != null) {
      setState(() {
        _typeMessage = TypeMessage.Image;
        _image = File(pickedImage.path);
      });
      final imageName = '${Random().nextDouble().toString()}.jpg';
      final imageUrl =
          await ChatFirebaseService().uploadChatImage(_image, imageName);

      setState(() {
        _message = imageUrl ?? 'image';
      });

      await _sendMessage();

      // widget.onImagePick(_image!);
    }
  }

  Future<void> _sendAudio() async {
    await _stopAudioRecording();
    setState(() {
      _typeMessage = TypeMessage.Audio;
      _audio = File(pathToAudio!);
    });
    final audioName = '${Random().nextDouble().toString()}.wav';
    final audioUrl = await ChatFirebaseService().uploadChatAudio(_audio, audioName);

    setState(() {
      _message = audioUrl ?? 'audio';
    });

    await _sendMessage();
    await _audioCanceled();
  }

  Future<void> initRecorder() async {
    pathToAudio = '/sdcard/Download/temp.wav';
    _recordingSession = FlutterSoundRecorder();
    await _recordingSession!.openRecorder(
        // focus: AudioFocus!.requestFocusAndStopOthers,
        // category: SessionCategory!.playAndRecord,
        // mode: SessionMode!.modeDefault,
        // device: AudioDevice!.speaker
        );

    await _recordingSession!
        .setSubscriptionDuration(Duration(milliseconds: 10));
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future<void> _audioRecording() async {
    setState(() {
      isAudioRecording = true;
      _showWidgetAudio = true;
    });
    Directory directory = Directory(path.dirname(pathToAudio!));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession!.openRecorder();
    await _recordingSession!.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
    StreamSubscription _recorderSubscription =
        _recordingSession!.onProgress!.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds,
          isUtc: true);
      var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
      setState(() {
        _timerText = timeText.substring(0, 8);
      });
    });
    _recorderSubscription.cancel();
  }

  Future<String?> _stopAudioRecording() async {
    //_recordingSession.closeAudioSession();
    setState(() {
      isAudioRecording = false;
    });
    _recordingSession!.closeRecorder();
    return await _recordingSession!.stopRecorder();
  }

  Future<void> _playAudioRecord() async {
    print(pathToAudio);
    setState(() {
      _playAudio = true;
    });
    recordingPlayer.open(
      Audio.file(pathToAudio!),
      autoStart: true,
      showNotification: true,
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
    // testRecordingPlayer.open(
    //   Audio.network("https://cdns-preview-e.dzcdn.net/stream/c-eae119c6444ec44a9fd315938b52ea8e-6.mp3"),
    //   autoStart: true,
    //   showNotification: true,
    // );
  }

  Future<void> _pauseAudioRecord() async {
    print(pathToAudio);
    setState(() {
      _playAudio = false;
    });
    recordingPlayer.stop();
  }

  Future<void> _audioCanceled() async {
    await _recordingSession!.stopRecorder();
    _recordingSession!.closeRecorder();
    setState(() {
      _showWidgetAudio = false;
    });
    initRecorder();
  }

  @override
  Widget build(BuildContext context) {
    return !_showWidgetAudio
        ? Row(
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
                onPressed: _message.trim().isEmpty
                    ? () async {
                        _audioRecording();
                      }
                    : _sendMessage,
                icon: Icon(_message.trim().isEmpty ? Icons.mic : Icons.send),
              ),
            ],
          )
        : Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 241, 241, 241)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StreamBuilder<RecordingDisposition>(
                    builder: (context, snapshot) {
                      final duration = snapshot.hasData
                          ? snapshot.data!.duration
                          : Duration.zero;
                      String twoDigits(int n) => n.toString().padLeft(2, '0');
                      final twoDigitsMinutes =
                          twoDigits(duration.inMinutes.remainder(60));
                      final twoDigitsSeconds =
                          twoDigits(duration.inSeconds.remainder(60));

                      return Text(
                        '$twoDigitsMinutes:$twoDigitsSeconds',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      );
                    },
                    stream: _recordingSession!.onProgress,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _audioCanceled,
                        icon: const Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: _showWidgetAudio
                            ? isAudioRecording
                                ? () async {
                                    _stopAudioRecording();
                                  }
                                : !_playAudio
                                    ? () async {
                                        await _playAudioRecord();
                                      }
                                    : () async {
                                        _pauseAudioRecord();
                                      }
                            : () {},
                        icon: isAudioRecording
                            ? const Icon(Icons.stop)
                            : !_playAudio
                                ? const Icon(Icons.play_arrow)
                                : const Icon(Icons.pause),
                      ),
                      IconButton(
                        onPressed: _sendAudio,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
