import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpHelper {
  static String movieNightBaseUrl = 'https://movie-night-api.onrender.com';

  static Future<Map<String, dynamic>> startSession(String? deviceId) async {
    final response = await http.get(
      Uri.parse('$movieNightBaseUrl/start-session?device_id=$deviceId'),
    );
    return jsonDecode(response.body);
  }
}
