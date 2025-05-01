import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_service/audio_service.dart';
import 'update_service.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'config/app_config.dart';

class HomePage extends StatefulWidget {
  final AudioHandler audioHandler;
  const HomePage({required this.audioHandler, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<ConnectivityResult> _connectivityStream;
  bool _semConexaoExibido = false;
  late VideoPlayerController _bgController;

  @override
  void initState() {
    super.initState();

    _bgController =
        VideoPlayerController.asset('assets/bg.mp4')
          ..setLooping(true)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              _bgController.play();
            }
          });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdate(context);
      _monitorarConexao();
    });
  }

  void _monitorarConexao() {
    _connectivityStream = Connectivity().onConnectivityChanged;
    _connectivityStream.listen((result) {
      if (!mounted) return;

      final semConexao = result == ConnectivityResult.none;

      if (semConexao && !_semConexaoExibido) {
        _semConexaoExibido = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você está sem conexão. Tente novamente mais tarde!'),
            backgroundColor: Colors.red,
            duration: Duration(days: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      } else if (!semConexao && _semConexaoExibido) {
        _semConexaoExibido = false;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (Platform.isIOS)
            if (_bgController.value.isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _bgController.value.size.width,
                    height: _bgController.value.size.height,
                    child: VideoPlayer(_bgController),
                  ),
                ),
              )
            else
              Container(color: Colors.black)
          else
            Positioned.fill(
              child: Image.asset('assets/fundo.png', fit: BoxFit.cover),
            ),

          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedButton(
                        onTap:
                            () => launchUrlString(
                              AppConfig.whatsapp,
                              mode: LaunchMode.externalApplication,
                            ),
                        child: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                Flexible(
                  fit: FlexFit.loose,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset('assets/logo.png'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedButton(
                              onTap:
                                  () => widget.audioHandler.customAction(
                                    'volumeDown',
                                  ),
                              child: const Icon(
                                Icons.volume_down,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            StreamBuilder<PlaybackState>(
                              stream: widget.audioHandler.playbackState,
                              builder: (_, snap) {
                                final playing = snap.data?.playing ?? false;
                                return AnimatedButton(
                                  onTap:
                                      () =>
                                          playing
                                              ? widget.audioHandler.pause()
                                              : widget.audioHandler.play(),
                                  child: Icon(
                                    playing
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            AnimatedButton(
                              onTap:
                                  () => widget.audioHandler.customAction(
                                    'volumeUp',
                                  ),
                              child: const Icon(
                                Icons.volume_up,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(
                              FontAwesomeIcons.facebook,
                              AppConfig.redesSociais['facebook']!,
                            ),
                            _socialButton(
                              FontAwesomeIcons.instagram,
                              AppConfig.redesSociais['instagram']!,
                            ),
                            _socialButton(
                              FontAwesomeIcons.youtube,
                              AppConfig.redesSociais['youtube']!,
                            ),
                            _socialButton(
                              FontAwesomeIcons.twitter,
                              AppConfig.redesSociais['twitter']!,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tocando diretamente de:\n${AppConfig.cidade}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 16),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _actionButton(
                          icon: FontAwesomeIcons.envelope,
                          url: AppConfig.email,
                        ),
                        const SizedBox(height: 12),
                        _actionButton(
                          icon: FontAwesomeIcons.globe,
                          url: AppConfig.site,
                        ),
                        const SizedBox(height: 12),
                        _actionButton(
                          icon: FontAwesomeIcons.camera,
                          url: AppConfig.camera,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Text(
                      AppConfig.versao,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AnimatedButton(
        onTap: () => launchUrlString(url, mode: LaunchMode.externalApplication),
        child: FaIcon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String url}) {
    return AnimatedButton(
      onTap: () async {
        if (await canLaunchUrlString(url)) {
          await launchUrlString(url, mode: LaunchMode.externalApplication);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o link.')),
          );
        }
      },
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 22,
        child: FaIcon(icon, size: 20, color: Colors.black),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedButton({super.key, required this.child, required this.onTap});

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.reverse();
  void _onTapUp(TapUpDetails details) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(scale: _controller, child: widget.child),
    );
  }
}
