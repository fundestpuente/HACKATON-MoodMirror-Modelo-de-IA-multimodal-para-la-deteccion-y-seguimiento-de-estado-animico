import 'package:flutter/material.dart';
import '../widgets/pastel_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MoodMirror"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            PastelCard(
              title: "Añadir Feeling",
              icon: Icons.add_a_photo,
              onTap: () => Navigator.pushNamed(context, "/add"),
            ),
            PastelCard(
              title: "Revisar Diario",
              icon: Icons.menu_book,
              onTap: () => Navigator.pushNamed(context, "/progress"),
            ),
             PastelCard(
              title: "Análisis Semanal",
              icon: Icons.analytics,
              onTap: () => Navigator.pushNamed(context, "/analysis"),
            ),
            PastelCard(
              title: "Nosotros",
              icon: Icons.info_outline,
              onTap: () => Navigator.pushNamed(context, "/about"),
            ),
            PastelCard(
              title: "Configuración",
              icon: Icons.settings,
              onTap: () => Navigator.pushNamed(context, "/config"),
            ),
           
          ],
        ),
      ),
    );
  }
}
