import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

/// Fetches current weather and forecast from OpenWeatherMap for the device's location.
class WeatherService {
  static const String _base = 'https://api.openweathermap.org/data/2.5';

  // ── Permission / location helper ─────────────────────────────────────────

  Future<Position> _getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns current [WeatherData] for the device's GPS location.
  Future<WeatherData> getWeather() async {
    final position = await _getPosition();
    final apiKey   = dotenv.env['WEATHER_API_KEY'] ?? '';

    final uri = Uri.parse(
      '$_base/weather'
      '?lat=${position.latitude}&lon=${position.longitude}'
      '&units=metric&appid=$apiKey',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Weather API error: ${response.statusCode} ${response.body}');
    }

    return WeatherData.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Returns 5-day / 3-hour [ForecastEntry] list for the device's location.
  Future<List<ForecastEntry>> getForecast() async {
    final position = await _getPosition();
    final apiKey   = dotenv.env['WEATHER_API_KEY'] ?? '';

    final uri = Uri.parse(
      '$_base/forecast'
      '?lat=${position.latitude}&lon=${position.longitude}'
      '&units=metric&appid=$apiKey',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Forecast API error: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final list = json['list'] as List;
    return list
        .map((e) => ForecastEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
