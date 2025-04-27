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
    // Inicializa o player de vídeo em loop
    _bgController = VideoPlayerController.asset('assets/bg.mp4')
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
          // Vídeo de fundo
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
            Container(color: Colors.black),

          SafeArea(
            child: Column(
              children: [
                // AppBar customizado
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => launchUrlString(
                        'https://wa.me/559981069341',
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ),

                // Conteúdo central: logo, controles, redes e texto
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/logo.png',
                          width: 240,
                          height: 240,
                        ),

                        const SizedBox(height: 24),

                        // Controles de volume + play/pause
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.volume_down,
                                  size: 36, color: Colors.white),
                              onPressed: () => widget.audioHandler
                                  .customAction('volumeDown'),
                            ),
                            StreamBuilder<PlaybackState>(
                              stream: widget.audioHandler.playbackState,
                              builder: (_, snap) {
                                final playing = snap.data?.playing ?? false;
                                return IconButton(
                                  icon: Icon(
                                    playing
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => playing
                                      ? widget.audioHandler.pause()
                                      : widget.audioHandler.play(),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.volume_up,
                                  size: 36, color: Colors.white),
                              onPressed: () => widget.audioHandler
                                  .customAction('volumeUp'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Botões de redes sociais
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(FontAwesomeIcons.facebook,
                                'https://www.instagram.com/nativafmbdc'),
                            _socialButton(FontAwesomeIcons.instagram,
                                'https://www.instagram.com/nativafmbdc/'),
                            _socialButton(FontAwesomeIcons.youtube,
                                'https://www.youtube.com/@nativafmbarradocorda'),
                            _socialButton(FontAwesomeIcons.twitter,
                                'https://www.instagram.com/nativafmbdc'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Texto de localização
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
                        // E-mail com mailto:
                        FloatingActionButton(
                          heroTag: 'email',
                          mini: true,
                          child: FaIcon(FontAwesomeIcons.envelope, size: 20),
                          onPressed: () async {
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
                                      'Não foi possível abrir o app de e-mail.'),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton(
                          heroTag: 'site',
                          mini: true,
                          child: FaIcon(FontAwesomeIcons.globe, size: 20),
                          onPressed: () => launchUrlString(
                            'https://nativafmbdc.com.br/',
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton(
                          heroTag: 'webcam',
                          mini: true,
                          child: FaIcon(FontAwesomeIcons.camera, size: 20),
                          onPressed: () => launchUrlString(
                            'https://nativafmbdc.com.br/',
                            mode: LaunchMode.externalApplication,
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
    return IconButton(
      icon: FaIcon(icon, color: Colors.white, size: 32),
      onPressed: () => launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      ),
    );
  }
}
