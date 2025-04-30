class AppConfig {
  static const String nomeApp = 'Nativa BC';
  static const String tituloPlayer = 'Nativa FM 105.9';
  static const String cidade = 'Barra do Corda, Maranhão, Brasil';

  static const String streamApi =
      'https://ez1fm.com/aplicativos/links.php?stream=nativa_bc';

  static const String logoUrl = 'https://i.imgur.com/g9vWyXM.png';

  static const String whatsapp = 'https://wa.me/559981069341';

  static const String email = 'mailto:contato@nativafmbdc.com.br';
  static const String site = 'https://nativafmbdc.com.br/';
  static const String camera = 'https://nativafmbdc.com.br/';

  static const Map<String, String> redesSociais = {
    'facebook': 'https://www.instagram.com/nativafmbdc',
    'instagram': 'https://www.instagram.com/nativafmbdc/',
    'youtube': 'https://www.youtube.com/@nativafmbarradocorda',
    'twitter': 'https://www.instagram.com/nativafmbdc',
  };

  static String linkVersao(String plataforma) =>
      'https://ez1fm.com/aplicativos/links.php?loja=$plataforma&app=nativa_bc';

  static String linkVersaoApi() =>
      'https://ez1fm.com/aplicativos/version.php?ts=${DateTime.now().millisecondsSinceEpoch}&aplicativo=nativa_bc';
}