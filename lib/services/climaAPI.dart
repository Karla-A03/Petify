import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = '3ed86af5324a0863565b884462c10bae';
const String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';

Future<Map<String, dynamic>?> obtenerClima(double lat, double lon) async {
  final url = Uri.parse('$apiUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
