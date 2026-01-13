class WeatherNow {
  final double temp;
  final double wind;
  final int code;

  WeatherNow({required this.temp, required this.wind, required this.code});

  factory WeatherNow.fromJson(Map<String, dynamic> j) {
    final cw = j['current_weather'];
    return WeatherNow(
      temp: (cw['temperature'] as num).toDouble(),
      wind: (cw['windspeed'] as num).toDouble(),
      code: (cw['weathercode'] as num).toInt(),
    );
  }
}
