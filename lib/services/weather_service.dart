import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../config.dart'; // Single place where the backend URL lives

/// Fetches weather from our own Node.js backend.
/// The backend handles the OpenWeatherMap call and keeps the API key server-side.
class WeatherService {
  static final String _base = '${AppConfig.backendUrl}/api/weather';

  /// Returns current [WeatherData] for the device's GPS location.
  Future<WeatherData> getWeather() async {
    // 1. Ensure location services are enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    // 2. Check / request location permission.
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

    // 3. Get the device's current GPS position.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );

    // 4. Send lat/lon to the backend — it fetches weather and returns the result.
    final uri = Uri.parse(
      '$_base?lat=${position.latitude}&lon=${position.longitude}',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Weather backend error: ${response.statusCode}');
    }

    return WeatherData.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
