import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides real-time authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provides access to authentication service
final authServiceProvider = Provider((ref) => AuthService());

/// Handles Firebase authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create new user account and auto-login
  Future<void> signUp({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  /// Sign in existing user
  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign out current user
  Future<void> logout() async {
    await _auth.signOut();
  }
}
