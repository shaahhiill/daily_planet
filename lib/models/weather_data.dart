// Model for the data returned by the OpenWeatherMap API.
class WeatherData {
  final double temperature;  // Current temp in Celsius
  final int weatherCode;     // OWM condition code (e.g. 800 = clear sky, 500 = light rain)
  final String description;  // Short weather summary, e.g. "light rain"

  const WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.description,
  });

  // Parses the raw API JSON into a WeatherData object.
  // The 'weather' key holds a list — we grab the first item for the code & description.
  // 'temp' is cast via num first since the API can return it as int or double.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      weatherCode: weather['id'] as int,
      description: weather['description'] as String,
    );
  }
}
