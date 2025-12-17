import 'package:flutter/material.dart';
import '../services/config_service.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final controller = TextEditingController();
  String currentIp = "";

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  Future loadConfig() async {
    final saved = await ConfigService.getServerIp();
    setState(() {
      currentIp = saved ?? "10.0.2.2";
      controller.text = currentIp;
    });
  }

  Future saveIp() async {
    await ConfigService.setServerIp(controller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dirección del servidor guardada")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración de Servidor")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "IP del servidor FastAPI",
                hintText: "Ej: 192.168.1.34",
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveIp,
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
