import 'package:flutter/material.dart';
import '../widgets/pastel_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- LOGO RECTANGULAR MÁS GRANDE ---
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9DDE7),  // pastel suave
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  "assets/icon/app_icon.png",
                  height: 150,          // ← AUMENTADO
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Demo de diario emocional",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF555555),
                ),
              ),

              const SizedBox(height: 40),

              PastelButton(
                text: "Entrar al Demo",
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, "/home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
