import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';

class ApiService {

  static Future<String> getBaseUrl() async {
    String? savedIp = await ConfigService.getServerIp();

    // Si no hay IP guardada, usar localhost por defecto (emulador)
    savedIp ??= "10.0.2.2";

    return "http://$savedIp:8000";
  }

  static Future<Map<String, dynamic>> sendFeeling(File image, String text) async {
    final baseUrl = await getBaseUrl();
    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/add_entry"));

    request.fields["text"] = text;
    request.files.add(await http.MultipartFile.fromPath("photo", image.path));

    final streamed = await request.send();
    final bytes = await streamed.stream.toBytes();
    final utf8Body = utf8.decode(bytes);

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      return json.decode(utf8Body);
    } else {
      throw Exception("Error ${streamed.statusCode}: $utf8Body");
    }
  }

  static Future<List<dynamic>> getEntries() async {
    final baseUrl = await getBaseUrl();
    final res = await http.get(Uri.parse("$baseUrl/entries"));

    final utf8Body = utf8.decode(res.bodyBytes);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(utf8Body);
    } else {
      throw Exception("Error ${res.statusCode}: $utf8Body");
    }
  }

  static Future<Map<String, dynamic>> deleteEntry(int id) async {
    final baseUrl = await getBaseUrl();
    final res = await http.delete(Uri.parse("$baseUrl/delete_entry/$id"));

    final utf8Body = utf8.decode(res.bodyBytes);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(utf8Body);
    } else {
      throw Exception("Error ${res.statusCode}: $utf8Body");
    }
  }
}
