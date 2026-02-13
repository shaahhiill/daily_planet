import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors device internet connection status
/// Returns true if connected (wifi/mobile/ethernet), false if offline
/// Used for showing offline banner on home screen
final isOnlineProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // Check if any connection type is active (not none)
    return results.any((result) => result != ConnectivityResult.none);
  });
});
