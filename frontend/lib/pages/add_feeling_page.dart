import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddFeelingPage extends StatefulWidget {
  const AddFeelingPage({super.key});

  @override
  State<AddFeelingPage> createState() => _AddFeelingPageState();
}

class _AddFeelingPageState extends State<AddFeelingPage> {
  File? imageFile;
  final picker = ImagePicker();
  final textController = TextEditingController();
  String advice = "";
  String imageEmotion = "";
  String textEmotion = "";
  bool loading = false;

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> sendEntry() async {
    if (imageFile == null || textController.text.isEmpty) return;
    setState(() => loading = true);

    try {
      final response = await ApiService.sendFeeling(
        imageFile!,
        textController.text,
      );

      setState(() {
        advice = response["advice"] ?? "";
        imageEmotion = response["image"]?["emotion"] ?? "";
        textEmotion = response["text"]?["emotion"] ?? "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrada guardada")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final dateStr = "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/${date.year}";

    return Scaffold(
      appBar: AppBar(title: const Text("Anotar Feeling")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(imageFile!, height: 200, fit: BoxFit.cover),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 80, color: Colors.grey),
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4A8C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Tomar Selfie"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: textController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "¿Cómo te sientes hoy?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Fecha: $dateStr",
                style: const TextStyle(
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : sendEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4A8C0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Enviar"),
              ),
            ),
            const SizedBox(height: 20),
            if (advice.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (textEmotion.isNotEmpty || imageEmotion.isNotEmpty)
                      Text(
                        "Emoción por texto: $textEmotion\n"
                        "Emoción por imagen: $imageEmotion",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      advice,
                      style: const TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
