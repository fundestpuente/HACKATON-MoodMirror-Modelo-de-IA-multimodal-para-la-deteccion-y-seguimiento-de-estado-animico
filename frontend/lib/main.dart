import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/add_feeling_page.dart';
import 'pages/progress_page.dart';
import 'pages/about_page.dart';
import 'pages/config_page.dart';

import 'screens/analysis_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔔 Inicializar notificaciones
  await NotificationService.init();

  runApp(const MoodMirrorApp());
}

class MoodMirrorApp extends StatelessWidget {
  const MoodMirrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MoodMirror",
      debugShowCheckedModeBanner: false,

      // 🎨 TEMA PASTEL (el tuyo, intacto)
      theme: ThemeData(
        fontFamily: "Sans",
        scaffoldBackgroundColor: const Color(0xFFFFE7EE),
        primaryColor: const Color(0xFFF4A8C0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4A8C0),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          iconTheme: IconThemeData(color: Color(0xFF333333)),
        ),
      ),

      initialRoute: "/login",

      routes: {
        "/login": (_) => LoginPage(),
        "/home": (_) => HomePage(),
        "/add": (_) => AddFeelingPage(),
        "/progress": (_) => ProgressPage(),
        "/analysis": (_) => AnalysisScreen(), // 👈 ya no recibe mock
        "/about": (_) => AboutPage(),
        "/config": (_) => ConfigPage(),
      },
    );
  }
}
