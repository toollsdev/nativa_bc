import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'config/app_config.dart';

class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  static const _radioEndpoint = AppConfig.streamApi;

  RadioAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    mediaItem.add(
      MediaItem(
        id: _radioEndpoint,
        title: AppConfig.tituloPlayer,
        album: 'Rádio ao Vivo',
        artUri: Uri.parse(AppConfig.logoUrl),
      ),
    );

    try {
      final resolved = await http.read(Uri.parse(_radioEndpoint));
      final streamUrl = resolved.trim();
      await _player.setUrl(streamUrl);
    } catch (e) {
      return;
    }

    _player.playbackEventStream.listen(_broadcastState);
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.stop,
          if (_player.playing) MediaControl.pause else MediaControl.play,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _translateProcessingState(_player.processingState),
        playing: _player.playing,
        updatePosition: _player.position,
        speed: _player.speed,
      ),
    );
  }

  AudioProcessingState _translateProcessingState(ProcessingState ps) {
    switch (ps) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async {
    if (_player.processingState == ProcessingState.idle ||
        _player.processingState == ProcessingState.completed) {
      try {
        final resolved = await http.read(Uri.parse(_radioEndpoint));
        final streamUrl = resolved.trim();
        await _player.setUrl(streamUrl);
      } catch (e) {
        return;
      }
    }
    await _player.play();
  }

  @override
  Future<void> pause() => _player.stop();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) {
    switch (name) {
      case 'volumeUp':
        return _player.setVolume((_player.volume + .1).clamp(0.0, 1.0));
      case 'volumeDown':
        return _player.setVolume((_player.volume - .1).clamp(0.0, 1.0));
      default:
        return super.customAction(name, extras);
    }
  }
}