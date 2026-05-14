// File: lib/Data/services/weather_service.dart
// Purpose: Simple wrapper around OpenWeatherMap API for current weather.
// Notes: Returns a minimal map with `temp` and `condition`.

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey;
  WeatherService(this.apiKey);

  Future<Map<String, dynamic>> getCurrentWeatherByCoords(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Weather fetch failed');
    final data = json.decode(res.body) as Map<String, dynamic>;
    final temp = (data['main']?['temp'] ?? 0).toDouble();
    final condition =
        (data['weather'] as List).isNotEmpty
            ? (data['weather'][0]['main'] ?? 'Unknown').toString()
            : 'Unknown';
    return {'temp': temp, 'condition': condition};
  }
}
