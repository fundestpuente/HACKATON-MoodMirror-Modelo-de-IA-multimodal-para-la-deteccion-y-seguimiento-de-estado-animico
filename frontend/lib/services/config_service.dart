import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String keyServerIp = "server_ip";

  static Future<void> setServerIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyServerIp, ip);
  }

  static Future<String?> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyServerIp);
  }
}

void showInitialNotification(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aviso Importante'),
        content: Text('Esta aplicación no reemplaza atención psicológica profesional.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  });
}
