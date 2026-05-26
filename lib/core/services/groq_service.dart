import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class GroqService {
  static const String _apiKey = groqApiKey;
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> getChatResponse(
    List<Map<String, String>> messages, {
    String model = 'llama-3.1-8b-instant',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error: Gagal mendapatkan respon dari server. (${response.statusCode})';
      }
    } catch (e) {
      return 'Error: Terjadi kesalahan koneksi.';
    }
  }
}
