/// Holds the result from the OpenWeatherMap current-weather API.
class WeatherData {
  /// Current temperature in Celsius.
  final double temperature;

  /// OWM weather condition code (used to pick the right icon).
  /// See: https://openweathermap.org/weather-conditions
  final int weatherCode;

  /// Human-readable description, e.g. "light rain".
  final String description;

  const WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      weatherCode: weather['id'] as int,
      description: weather['description'] as String,
    );
  }
}
