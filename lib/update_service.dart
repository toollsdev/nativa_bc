import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import necessário para o LaunchMode
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> checkForUpdate(BuildContext context) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final response =
        await http.get(Uri.parse('https://seu_dominio/version.json'));
    if (response.statusCode != 200) return;

    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data['latest_version'] != info.version) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Nova versão disponível!'),
          content:
              Text('Atualize para a versão ${data['latest_version']}.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Depois'),
            ),
            TextButton(
              onPressed: () {
                // Agora o LaunchMode está em escopo
                launchUrlString(
                  data['update_url'] as String,
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
    debugPrint('Erro ao checar atualização: $e');
  }
}
