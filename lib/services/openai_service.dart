// lib/services/openai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  // Récupération de la clé API depuis le fichier .env
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String endpoint = "https://api.openai.com/v1/chat/completions";

  static Future<String> getIaResponse(String message) async {
    // Vérification de la clé API
    if (apiKey.isEmpty) {
      throw Exception(
        'Clé API non configurée. Veuillez configurer votre clé OpenAI dans le fichier openai_service.dart',
      );
    }

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content":
                  "Vous êtes Aureus, l'assistant privé exclusif de l'application AureusGold, spécialisé dans l'investissement, le marché de l'or et l'économie mondiale. Soyez professionnel, luxueux, précis et toujours poli.",
            },
            {"role": "user", "content": message},
          ],
          "max_tokens": 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String iaResponse = data['choices'][0]['message']['content'];
        return iaResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Clé API invalide. Vérifiez votre clé OpenAI.');
      } else if (response.statusCode == 429) {
        throw Exception('Limite de requêtes dépassée. Réessayez plus tard.');
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception(
          'Erreur de connexion. Vérifiez votre connexion internet.',
        );
      }
      rethrow;
    }
  }
}
