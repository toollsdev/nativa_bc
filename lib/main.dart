import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'audio_handler.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handler = await AudioService.init(
    builder: () => RadioAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'radio_channel',
      androidNotificationChannelName: 'Rádio ao Vivo',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MyApp(audioHandler: handler));
}

class MyApp extends StatelessWidget {
  final AudioHandler audioHandler;
  const MyApp({required this.audioHandler, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nativa BC',
      theme: ThemeData.light(),
      home: HomePage(audioHandler: audioHandler),
    );
  }
}