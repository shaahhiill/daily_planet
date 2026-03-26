import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

/// Provides the current [WeatherData] for the device's location.
/// Re-fetch by invalidating this provider (e.g., on pull-to-refresh).
final weatherProvider = FutureProvider<WeatherData>((ref) async {
  return WeatherService().getWeather();
});
