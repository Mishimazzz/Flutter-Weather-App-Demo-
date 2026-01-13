import 'dart:convert';
import 'package:http/http.dart' as http;

import '../city.dart';
import '../weather.dart';

class WeatherApi {
  Future<WeatherNow> fetchNow(double lat, double lon) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto',
    );
    final r = await http.get(uri);
    if (r.statusCode != 200) {
      throw Exception('Weather request failed: ${r.statusCode}');
    }
    return WeatherNow.fromJson(jsonDecode(r.body));
  }
}