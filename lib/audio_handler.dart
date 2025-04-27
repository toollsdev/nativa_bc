import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  static const _radioUrl = 'https://azura.ez1fm.com/listen/nativa_fm_barra_do_corda/radio.mp3';

  RadioAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // 1) Configure o audio session
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    // 2) Informe os metadados do stream
    mediaItem.add(
      MediaItem(
        id: _radioUrl,
        // título que aparece na lock-screen / notificação
        title: 'Nativa FM 105.9',
        album: 'Rádio ao Vivo',
        artUri: Uri.parse('https://i.imgur.com/g9vWyXM.png'),
      ),
    );

    // 3) Carregue e comece a escutar os eventos de playback
    await _player.setUrl(_radioUrl);
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
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

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
