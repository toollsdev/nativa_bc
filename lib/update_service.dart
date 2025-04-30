import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'config/app_config.dart';

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
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;

    final versionUrl = AppConfig.linkVersaoApi();
    final versionResponse = await http.get(Uri.parse(versionUrl));

    if (versionResponse.statusCode != 200) return;

    final data = json.decode(versionResponse.body) as Map<String, dynamic>;
    final latestVersion = data['latest_version'] as String;
    final mandatory = data['mandatory'] as bool? ?? false;

    if (_isNewerVersion(latestVersion, currentVersion)) {
      if (!context.mounted) return;

      final plataforma = Platform.isAndroid ? 'android' : 'ios';
      final lojaUrl = AppConfig.linkVersao(plataforma);
      final lojaResponse = await http.get(Uri.parse(lojaUrl));

      if (lojaResponse.statusCode != 200) return;

      final lojaData = json.decode(lojaResponse.body);
      final updateUrl = lojaData['url'] as String?;

      if (updateUrl == null || updateUrl.isEmpty) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: !mandatory,
        builder: (_) => AlertDialog(
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
              },
              child: const Text('Atualizar'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    debugPrint('Erro ao checar atualização: \$e');
  }
}