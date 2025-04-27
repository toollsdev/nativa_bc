import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

/// verifica se a string `a` (ex: "1.4.0") é maior que `b` ("1.3.2") em SemVer
bool _isNewerVersion(String a, String b) {
  final av = a.split('.').map(int.parse).toList();
  final bv = b.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    if (av[i] > bv[i]) return true;
    if (av[i] < bv[i]) return false;
  }
  return false;
}

Future<void> checkForUpdate(BuildContext context) async {
  try {
    // 1) Versão instalada
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version; // ex: "1.3.0"

    // 2) Busca o JSON no seu servidor, adicionando um ts para evitar cache
    final ts = DateTime.now().millisecondsSinceEpoch;
    final url =
        'https://ez1fm.com/aplicativos/nativabc/version.php' +
        '?ts=$ts&aplicativo=nativa_bc';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return;

    // 3) Decodifica o JSON
    final data = json.decode(response.body) as Map<String, dynamic>;
    final latestVersion = data['latest_version'] as String;
    final mandatory = data['mandatory'] as bool? ?? false;
    final updateUrl = data['update_url'] as String;

    // 4) Compara versões
    if (_isNewerVersion(latestVersion, currentVersion)) {
      if (!context.mounted) return;

      // 5) Exibe diálogo, bloqueante se obrigatório
      await showDialog<void>(
        context: context,
        barrierDismissible: !mandatory,
        builder:
            (_) => AlertDialog(
              title: const Text('Nova versão disponível!'),
              content: Text('Atualize para a versão $latestVersion.'),
              actions: <Widget>[
                if (!mandatory)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Depois'),
                  ),
                TextButton(
                  onPressed: () {
                    launchUrlString(
                      updateUrl,
                      mode: LaunchMode.externalApplication,
                    );
                    if (mandatory) {
                      // fecha o app se você quiser forçar
                      //SystemNavigator.pop();
                    }
                  },
                  child: const Text('Atualizar'),
                ),
              ],
            ),
      );
    }
  } catch (e) {
    debugPrint('Erro ao checar atualização: $e');
  }
}
