import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_service/audio_service.dart';
import 'update_service.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  final AudioHandler audioHandler;
  const HomePage({required this.audioHandler, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController =
        VideoPlayerController.asset('assets/bg.mp4')
          ..setLooping(true)
          ..initialize().then((_) {
            setState(() {});
            _bgController.play();
          });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdate(context);
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
            // Fundo com imagem (PNG) para Android
            Positioned.fill(
              child: Image.asset(
                'assets/fundo.png', // <- aqui coloca seu .png
                fit: BoxFit.cover,
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                // AppBar customizado
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedButton(
                        onTap:
                            () => launchUrlString(
                              'https://wa.me/559981069341',
                              mode: LaunchMode.externalApplication,
                            ),
                        child: FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                // Conteúdo central: logo, controles, redes e texto
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

                        // Controles de volume + play/pause
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedButton(
                              onTap:
                                  () => widget.audioHandler.customAction(
                                    'volumeDown',
                                  ),
                              child: Icon(
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
                              child: Icon(
                                Icons.volume_up,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Botões de redes sociais
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(
                              FontAwesomeIcons.facebook,
                              'https://www.instagram.com/nativafmbdc',
                            ),
                            _socialButton(
                              FontAwesomeIcons.instagram,
                              'https://www.instagram.com/nativafmbdc/',
                            ),
                            _socialButton(
                              FontAwesomeIcons.youtube,
                              'https://www.youtube.com/@nativafmbarradocorda',
                            ),
                            _socialButton(
                              FontAwesomeIcons.twitter,
                              'https://www.instagram.com/nativafmbdc',
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Tocando diretamente de:\nBarra do Corda, Maranhão, Brasil',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botões inferiores (e-mail, site e webcam)
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 16),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedButton(
                          onTap: () async {
                            const emailUri =
                                'mailto:contato@nativafmbdc.com.br';
                            if (await canLaunchUrlString(emailUri)) {
                              await launchUrlString(
                                emailUri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Não foi possível abrir o app de e-mail.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 22,
                            child: FaIcon(
                              FontAwesomeIcons.envelope,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedButton(
                          onTap:
                              () => launchUrlString(
                                'https://nativafmbdc.com.br/',
                                mode: LaunchMode.externalApplication,
                              ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 22,
                            child: FaIcon(
                              FontAwesomeIcons.globe,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedButton(
                          onTap:
                              () => launchUrlString(
                                'https://nativafmbdc.com.br/',
                                mode: LaunchMode.externalApplication,
                              ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 22,
                            child: FaIcon(
                              FontAwesomeIcons.camera,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
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
}

/// Widget que adiciona animação de toque (escala)
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

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _onTapCancel() {
    _controller.forward();
  }

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
