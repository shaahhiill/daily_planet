import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// NETWORK CONNECTIVITY PROVIDER
/// Provider that checks if device is currently connected to internet
/// Returns true if connected via wifi, mobile, or ethernet
/// Returns false if no connection
/// Used for offline detection banner on home screen
final isOnlineProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // Check if any connection type is active (not none)
    return results.any((result) => result != ConnectivityResult.none);
  });
});
