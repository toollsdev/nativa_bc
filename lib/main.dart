import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'audio_handler.dart';
import 'home_page.dart';
import 'dart:io'; // <--- IMPORTANTE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  late AudioHandler handler;

  if (Platform.isAndroid) {
    // Android: Cria o player direto sem AudioService
    handler = RadioAudioHandler();
  } else {
    // iOS: Usa AudioService normalmente
    handler = await AudioService.init(
      builder: () => RadioAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'radio_channel',
        androidNotificationChannelName: 'Rádio ao Vivo',
        androidNotificationOngoing: true,
      ),
    );
  }

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