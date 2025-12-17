import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nosotros")),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "MoodMirror es un demo de diario emocional que combina "
          "reconocimiento facial y análisis de texto para ofrecerte "
          "un pequeño mensaje de apoyo cada día.",
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
