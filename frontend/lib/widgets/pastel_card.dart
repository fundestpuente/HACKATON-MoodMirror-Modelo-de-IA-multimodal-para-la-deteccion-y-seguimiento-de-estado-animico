import 'package:flutter/material.dart';

class PastelCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const PastelCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        leading: Icon(icon, size: 32, color: const Color(0xFFF4A8C0)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
