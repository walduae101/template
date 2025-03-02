import 'package:firebase_auth/firebase_auth.dart';

/// Stub implementation for AppleSignInService
/// This is used on platforms that don't support Apple Sign-In
class AppleSignInService {
  Future<User?> signInWithApple() async {
    throw UnimplementedError('Apple Sign-In is not supported on this platform');
  }
}
