import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import '../providers/weather_provider.dart';

// ─── Entry point ────────────────────────────────────────────────────────────

class WeatherDetailScreen extends ConsumerWidget {
  /// Pass the already-loaded [WeatherData] so the hero header renders
  /// instantly without waiting for a second network call.
  final WeatherData weather;

  const WeatherDetailScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final forecastAsync = ref.watch(forecastProvider);

    // Dynamic background gradient based on weather condition & theme
    final bgGradient = _buildBgGradient(weather.weatherCode, isDark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          // ── Background gradient blob at top ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 360,
            child: Container(decoration: BoxDecoration(gradient: bgGradient)),
          ),

          // ── Scrollable content ───────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Back button row
                SliverToBoxAdapter(child: _buildTopBar(context)),

                // Hero: city, temp, description, H/L
                SliverToBoxAdapter(
                    child: _buildHero(context, weather, isDark)),

                // Condition summary blurb
                SliverToBoxAdapter(
                    child: _buildSummaryPill(weather, isDark)),

                // Hourly forecast strip
                SliverToBoxAdapter(
                  child: forecastAsync.when(
                    loading: () => _buildHourlyShimmer(isDark),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (entries) =>
                        _buildHourlyStrip(context, entries, isDark),
                  ),
                ),

                // 10-day (5-day) forecast list
                SliverToBoxAdapter(
                  child: forecastAsync.when(
                    loading: () => _buildForecastShimmer(isDark),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (entries) =>
                        _buildDailyForecast(context, entries, isDark),
                  ),
                ),

                // Detail grid (humidity, wind, pressure, etc.)
                SliverToBoxAdapter(
                    child: _buildDetailGrid(context, weather, isDark)),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          // Last-updated chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Just updated',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ─── Hero ────────────────────────────────────────────────────────────────

  Widget _buildHero(
      BuildContext context, WeatherData w, bool isDark) {
    final hemisphere = w.lat >= 0 ? 'Northern' : 'Southern';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City name
          Text(
            w.cityName.isNotEmpty ? w.cityName : 'Your Location',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          // Hemisphere sub-label
          Text(
            '$hemisphere Hemisphere • ${_windDir(w.windDeg)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Large temperature + icon row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Big temperature
              Text(
                '${w.temperature.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.w200,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 16),
              // Stack of status chips (rain chance placeholder + feels-like)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusChip(
                      Icons.thermostat,
                      'Feels ${w.feelsLike.round()}°',
                    ),
                    const SizedBox(height: 8),
                    _statusChip(
                      Icons.water_drop_outlined,
                      '${w.humidity}% humidity',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            _capitalize(w.description),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          // H / L row
          Row(
            children: [
              Icon(Icons.arrow_upward,
                  color: Colors.white.withValues(alpha: 0.85), size: 16),
              Text(
                '${w.tempMax.round()}°C',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_downward,
                  color: Colors.white.withValues(alpha: 0.85), size: 16),
              Text(
                '${w.tempMin.round()}°C',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statusChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Summary pill ────────────────────────────────────────────────────────

  Widget _buildSummaryPill(WeatherData w, bool isDark) {
    final windKmh = (w.windSpeed * 3.6).round();
    final blurb   = _conditionBlurb(w.weatherCode, windKmh);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          blurb,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // ─── Hourly strip ────────────────────────────────────────────────────────

  Widget _buildHourlyStrip(
      BuildContext context, List<ForecastEntry> entries, bool isDark) {
    // Take next 8 entries (24 hours) and prepend "Now" from current weather
    final hourly = entries.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Text(
            'HOURLY FORECAST',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // "Now" cell using current weather
                _hourlyCell(
                  label: 'Now',
                  icon: _weatherIcon(weather.weatherCode),
                  temp: '${weather.temperature.round()}°',
                  isDark: isDark,
                  isNow: true,
                ),
                ...hourly.map((e) => _hourlyCell(
                      label: _hourLabel(e.time),
                      icon: _weatherIcon(e.weatherCode),
                      temp: '${e.temperature.round()}°',
                      isDark: isDark,
                      isNow: false,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _hourlyCell({
    required String label,
    required IconData icon,
    required String temp,
    required bool isDark,
    required bool isNow,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isNow
                  ? const Color(0xFFE53935)
                  : (isDark ? Colors.white54 : Colors.black54),
              fontSize: 12,
              fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Icon(icon,
              color: isDark ? Colors.white70 : Colors.black54, size: 22),
          const SizedBox(height: 8),
          Text(
            temp,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Daily forecast ──────────────────────────────────────────────────────

  Widget _buildDailyForecast(
      BuildContext context, List<ForecastEntry> entries, bool isDark) {
    // Group by day, pick the noon-ish reading, compute min/max
    final days = _groupByDay(entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  color: isDark ? Colors.white38 : Colors.black38, size: 14),
              const SizedBox(width: 6),
              Text(
                '${days.length}-DAY FORECAST',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: days.asMap().entries.map((entry) {
              final idx  = entry.key;
              final day  = entry.value;
              final isLast = idx == days.length - 1;
              return _dailyRow(day, isDark, isLast);
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _dailyRow(_DaySummary day, bool isDark, bool isLast) {
    // Global min/max across all days so bar lengths are relative
    final globalMin = 0.0;
    final globalMax = 45.0;
    final range     = globalMax - globalMin;
    final lowFrac   = (day.minTemp - globalMin) / range;
    final highFrac  = (day.maxTemp - globalMin) / range;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Day name
              SizedBox(
                width: 44,
                child: Text(
                  day.label,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              // Icon
              Icon(_weatherIcon(day.weatherCode),
                  color: isDark ? Colors.white70 : Colors.black54, size: 20),
              const SizedBox(width: 12),
              // Low temp
              SizedBox(
                width: 36,
                child: Text(
                  '${day.minTemp.round()}°',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              // Gradient temperature bar
              Expanded(
                child: LayoutBuilder(builder: (ctx, constraints) {
                  final totalW = constraints.maxWidth;
                  return Stack(
                    children: [
                      // Background track
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white12
                              : Colors.black.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Active portion
                      Positioned(
                        left:  totalW * lowFrac,
                        width: totalW * (highFrac - lowFrac),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2196F3),
                                Color(0xFFE53935),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(width: 8),
              // High temp
              SizedBox(
                width: 36,
                child: Text(
                  '${day.maxTemp.round()}°',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
      ],
    );
  }

  // ─── Detail grid ─────────────────────────────────────────────────────────

  Widget _buildDetailGrid(
      BuildContext context, WeatherData w, bool isDark) {
    final windKmh = (w.windSpeed * 3.6).round();
    final visKm   = (w.visibility / 1000).toStringAsFixed(1);
    final sunriseStr = _epochToTime(w.sunrise);
    final sunsetStr  = _epochToTime(w.sunset);

    final items = [
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: '${w.humidity}%',
        sub: _humidityDesc(w.humidity),
      ),
      _DetailItem(
        icon: Icons.air,
        label: 'Wind',
        value: '$windKmh km/h',
        sub: _windDir(w.windDeg),
      ),
      _DetailItem(
        icon: Icons.compress,
        label: 'Pressure',
        value: '${w.pressure} hPa',
        sub: w.pressure > 1013 ? 'High pressure' : 'Low pressure',
      ),
      _DetailItem(
        icon: Icons.visibility_outlined,
        label: 'Visibility',
        value: '$visKm km',
        sub: w.visibility >= 10000 ? 'Crystal clear' : 'Reduced visibility',
      ),
      _DetailItem(
        icon: Icons.thermostat,
        label: 'Feels Like',
        value: '${w.feelsLike.round()}°C',
        sub: _feelsLikeDesc(w.temperature, w.feelsLike),
      ),
      _DetailItem(
        icon: Icons.wb_sunny_outlined,
        label: 'Sunrise',
        value: sunriseStr,
        sub: 'Sunset  $sunsetStr',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'WEATHER DETAILS',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, i) => _detailCard(items[i], isDark),
          ),
        ],
      ),
    );
  }

  Widget _detailCard(_DetailItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon,
                  color: isDark ? Colors.white38 : Colors.black38, size: 16),
              const SizedBox(width: 6),
              Text(
                item.label.toUpperCase(),
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.sub,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shimmer / skeleton loaders ──────────────────────────────────────────

  Widget _buildHourlyShimmer(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white54,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: const Color(0xFFE53935),
          ),
        ),
      ),
    );
  }

  Widget _buildForecastShimmer(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white54,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: const Color(0xFFE53935),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Maps OWM condition code to a background gradient.
  LinearGradient _buildBgGradient(int code, bool isDark) {
    if (!isDark) {
      // Light mode: always a soft sky blue
      if (code == 800) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        );
      }
      if (code > 800) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF546E7A), Color(0xFF90A4AE)],
        );
      }
      if (code >= 500 && code < 600) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF37474F), Color(0xFF78909C)],
        );
      }
      if (code >= 200 && code < 300) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF263238), Color(0xFF546E7A)],
        );
      }
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
      );
    }

    // Dark mode gradients
    if (code == 800) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A237E), Color(0xFF283593)],
      );
    }
    if (code > 800) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1C2631), Color(0xFF2C3E50)],
      );
    }
    if (code >= 500 && code < 600) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D1B2A), Color(0xFF1B2A40)],
      );
    }
    if (code >= 200 && code < 300) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D1B3E), Color(0xFF1A237E)],
    );
  }

  IconData _weatherIcon(int code) {
    if (code >= 200 && code < 300) return Icons.thunderstorm;
    if (code >= 300 && code < 400) return Icons.grain;
    if (code >= 500 && code < 600) return Icons.water_drop;
    if (code >= 600 && code < 700) return Icons.ac_unit;
    if (code >= 700 && code < 800) return Icons.foggy;
    if (code == 800) return Icons.wb_sunny;
    if (code > 800) return Icons.cloud;
    return Icons.wb_sunny;
  }

  String _hourLabel(DateTime time) {
    final h = time.hour;
    if (h == 0) return '12 AM';
    if (h < 12) return '$h AM';
    if (h == 12) return '12 PM';
    return '${h - 12} PM';
  }

  String _epochToTime(int epoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000).toLocal();
    return DateFormat('h:mm a').format(dt);
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _windDir(int deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((deg + 22.5) / 45).floor() % 8;
    return dirs[idx];
  }

  String _conditionBlurb(int code, int windKmh) {
    final windNote = windKmh > 20 ? ' Wind gusts up to $windKmh km/h.' : '';
    if (code == 800) return 'Clear skies ahead — enjoy the sunshine!$windNote';
    if (code > 800 && code <= 802) return 'Partly cloudy conditions.$windNote';
    if (code > 802) return 'Cloudy conditions will continue for the rest of the day.$windNote';
    if (code >= 500 && code < 600) return 'Rainy conditions — carry an umbrella.$windNote';
    if (code >= 200 && code < 300) return 'Thunderstorms in the area. Stay indoors if possible.$windNote';
    if (code >= 600 && code < 700) return 'Snowfall expected. Roads may be slippery.$windNote';
    return 'Current conditions: ${_weatherCodeLabel(code)}.$windNote';
  }

  String _weatherCodeLabel(int code) {
    if (code >= 700 && code < 800) return 'Misty / Foggy';
    return 'Mixed weather';
  }

  String _humidityDesc(int h) {
    if (h < 30) return 'Very dry';
    if (h < 50) return 'Comfortable';
    if (h < 70) return 'Slightly humid';
    return 'Very humid';
  }

  String _feelsLikeDesc(double actual, double feels) {
    final diff = (feels - actual).round();
    if (diff < -3) return 'Wind chill effect';
    if (diff > 3) return 'Humidity adds heat';
    return 'Similar to actual';
  }

  /// Groups forecast entries by calendar day and computes min/max temps + dominant code.
  List<_DaySummary> _groupByDay(List<ForecastEntry> entries) {
    final today = DateTime.now();
    final Map<String, List<ForecastEntry>> map = {};

    for (final e in entries) {
      final key = DateFormat('yyyy-MM-dd').format(e.time);
      map.putIfAbsent(key, () => []).add(e);
    }

    final summaries = <_DaySummary>[];
    for (final key in map.keys) {
      final group = map[key]!;
      final date  = group.first.time;

      // Skip today's remaining slots — already shown in hourly strip
      if (date.day == today.day &&
          date.month == today.month &&
          date.year == today.year) {
        continue;
      }

      final minT = group.map((e) => e.temperature).reduce(math.min);
      final maxT = group.map((e) => e.temperature).reduce(math.max);
      // Use noon entry for the representative weather code, or first available
      final noon = group.firstWhere(
        (e) => e.time.hour >= 11 && e.time.hour <= 13,
        orElse: () => group.first,
      );
      final label = _dayLabel(date, today);
      summaries.add(_DaySummary(
        label: label,
        minTemp: minT,
        maxTemp: maxT,
        weatherCode: noon.weatherCode,
      ));
    }
    return summaries;
  }

  String _dayLabel(DateTime date, DateTime today) {
    final diff = date.difference(DateTime(today.year, today.month, today.day)).inDays;
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEE').format(date); // Mon, Tue, …
  }
}

// ─── Data helpers ────────────────────────────────────────────────────────────

class _DaySummary {
  final String label;
  final double minTemp;
  final double maxTemp;
  final int weatherCode;

  const _DaySummary({
    required this.label,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherCode,
  });
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });
}
