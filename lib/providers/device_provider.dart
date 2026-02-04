import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ============================================================================
// BATTERY STATUS PROVIDER
// ============================================================================
/// Provider that streams the current battery level (0-100%)
/// Uses battery_plus package to access device battery info
/// Updates automatically when battery level changes
final batteryLevelProvider = StreamProvider<int>((ref) {
  final battery = Battery();

  // Listen to battery state changes and map to battery level
  return battery.onBatteryStateChanged.asyncMap((_) async {
    return await battery.batteryLevel;
  });
});

/// Provider that streams the current battery charging state
/// Returns BatteryState enum: charging, discharging, full, etc.
final batteryStateProvider = StreamProvider<BatteryState>((ref) {
  final battery = Battery();
  return battery.onBatteryStateChanged;
});

// ============================================================================
// LOCATION/GEOLOCATION PROVIDER
// ============================================================================
/// Provider that fetches the current device location
/// Uses geolocator package to access GPS coordinates
/// Returns Position object with latitude, longitude, accuracy, etc.
final locationProvider = FutureProvider<Position?>((ref) async {
  // Check if location services are enabled on device
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are disabled, cannot get location
    return null;
  }

  // Check location permission status
  LocationPermission permission = await Geolocator.checkPermission();

  // If permission denied, request it
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // User denied permission
      return null;
    }
  }

  // If permission denied forever, cannot request again
  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  // Permission granted, get current position
  // Uses GPS with high accuracy
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
});

// ============================================================================
// NETWORK CONNECTIVITY PROVIDER
// ============================================================================
/// Provider that streams the current network connectivity status
/// Uses connectivity_plus package to detect wifi, mobile, ethernet, none
/// Updates automatically when connectivity changes
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider that checks if device is currently connected to internet
/// Returns true if connected via wifi, mobile, or ethernet
/// Returns false if no connection
final isOnlineProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // Check if any connection type is active (not none)
    return results.any((result) => result != ConnectivityResult.none);
  });
});
