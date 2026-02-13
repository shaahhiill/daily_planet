import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for different platforms
/// This file contains API keys and project identifiers for Firebase services
abstract class DefaultFirebaseOptions {
  /// Get Firebase options for the current platform
  /// Currently only Android is configured
  static FirebaseOptions get currentPlatform {
    return android; // Return Android configuration
  }

  /// Firebase configuration for Android platform
  /// Contains API keys, app ID, and project identifiers
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyDfjeNxSZo0HK-UBxo9j0S0hiJ5fx2wIIM', // API key for Firebase services
    appId:
        '1:595813205305:android:c23ea48ee14a9609dc14e8', // Unique app identifier
    messagingSenderId: '595813205305', // For Firebase Cloud Messaging
    projectId: 'dailyplanet-72e33', // Firebase project ID
    storageBucket:
        'dailyplanet-72e33.firebasestorage.app', // Cloud Storage bucket
  );
}
