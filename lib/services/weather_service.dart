import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

/// Fetches current weather from OpenWeatherMap for the device's location.
class WeatherService {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// Returns current [WeatherData] for the device's GPS location.
  /// Throws an exception if location is denied or the API call fails.
  Future<WeatherData> getWeather() async {
    // 1. Ensure location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // 2. Check / request location permission
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

    // 3. Get the current position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low, // Low accuracy is enough for weather
      ),
    );

    // 4. Fetch weather from OpenWeatherMap
    final apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
    final uri = Uri.parse(
      '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}'
      '&units=metric&appid=$apiKey',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Weather API error: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherData.fromJson(json);
  }
}
