/// Model for the data returned by the OpenWeatherMap /weather endpoint.
class WeatherData {
  final double temperature;   // Current temp in °C
  final double feelsLike;     // Feels-like temp in °C
  final double tempMin;       // Day low in °C
  final double tempMax;       // Day high in °C
  final int humidity;         // Humidity %
  final int weatherCode;      // OWM condition code (e.g. 800 = clear, 500 = rain)
  final String description;   // Short description e.g. "light rain"
  final String cityName;      // City / area name from API
  final double windSpeed;     // Wind speed in m/s
  final int windDeg;          // Wind direction in degrees
  final int pressure;         // Atmospheric pressure hPa
  final int visibility;       // Visibility in metres (max 10 000)
  final double lat;           // Device latitude
  final double lon;           // Device longitude
  final int sunrise;          // Unix epoch (UTC)
  final int sunset;           // Unix epoch (UTC)

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.weatherCode,
    required this.description,
    required this.cityName,
    required this.windSpeed,
    required this.windDeg,
    required this.pressure,
    required this.visibility,
    required this.lat,
    required this.lon,
    required this.sunrise,
    required this.sunset,
  });

  /// Parses the raw /weather JSON into a [WeatherData] object.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final main    = json['main']    as Map<String, dynamic>;
    final wind    = json['wind']    as Map<String, dynamic>;
    final coord   = json['coord']   as Map<String, dynamic>;
    final sys     = json['sys']     as Map<String, dynamic>;

    return WeatherData(
      temperature:  (main['temp']       as num).toDouble(),
      feelsLike:    (main['feels_like'] as num).toDouble(),
      tempMin:      (main['temp_min']   as num).toDouble(),
      tempMax:      (main['temp_max']   as num).toDouble(),
      humidity:     (main['humidity']   as num).toInt(),
      weatherCode:  weather['id']        as int,
      description:  weather['description'] as String,
      cityName:     json['name']         as String? ?? '',
      windSpeed:    (wind['speed']       as num).toDouble(),
      windDeg:      (wind['deg']         as num? ?? 0).toInt(),
      pressure:     (main['pressure']   as num).toInt(),
      visibility:   (json['visibility'] as num? ?? 10000).toInt(),
      lat:          (coord['lat']        as num).toDouble(),
      lon:          (coord['lon']        as num).toDouble(),
      sunrise:      (sys['sunrise']      as num).toInt(),
      sunset:       (sys['sunset']       as num).toInt(),
    );
  }
}

/// A single entry from the /forecast endpoint (3-hour step).
class ForecastEntry {
  final DateTime time;        // Forecast time (local)
  final double temperature;   // Temp in °C
  final int weatherCode;      // OWM condition code
  final String description;   // Short description

  const ForecastEntry({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.description,
  });

  factory ForecastEntry.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    return ForecastEntry(
      time:         DateTime.fromMillisecondsSinceEpoch(
                      (json['dt'] as int) * 1000,
                    ).toLocal(),
      temperature:  (json['main']['temp'] as num).toDouble(),
      weatherCode:  weather['id'] as int,
      description:  weather['description'] as String,
    );
  }
}
