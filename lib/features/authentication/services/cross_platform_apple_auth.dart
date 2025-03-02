import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Cross-platform implementation for Apple Sign-In
/// Avoids using the native implementation on Android
class CrossPlatformAppleAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a random nonce for PKCE authentication
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Generate a SHA256 hash of the input string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign in with Apple using Firebase Auth directly
  Future<User?> signInWithApple(BuildContext context) async {
    try {
      debugPrint('🍎 Starting Cross-Platform Apple Sign-In Process');

      // Generate a secure nonce for authentication
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Create an Apple auth provider
      final appleProvider =
          OAuthProvider('apple.com')
            ..addScope('email')
            ..addScope('name')
            ..setCustomParameters({'locale': 'en', 'nonce': nonce});

      // Optional: For Android, we'll use Firebase's built-in auth UI
      if (!kIsWeb && !defaultTargetPlatform.isIOS) {
        debugPrint('📱 Using Firebase Auth UI for Apple Sign-In on Android');

        // Show a dialog to inform the user
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Apple Sign-In'),
                content: const Text(
                  'You will be redirected to sign in with your Apple ID.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Continue'),
                  ),
                ],
              ),
        );

        // Use the signInWithPopup method which works on all platforms
        final result = await _auth.signInWithPopup(appleProvider);
        final user = result.user;

        // Store user data
        if (user != null) {
          await _storeUserData(user);
        }

        return user;
      } else {
        // On iOS/web, use signInWithProvider
        final credential = await _auth.signInWithProvider(appleProvider);
        final user = credential.user;

        // Store user data
        if (user != null) {
          await _storeUserData(user);
        }

        return user;
      }
    } catch (e) {
      debugPrint('❌ Apple Sign-In error: $e');
      return null;
    }
  }

  /// Store user data in Firestore
  Future<void> _storeUserData(User user) async {
    try {
      debugPrint('💾 Storing Apple user data in Firestore');

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'authProvider': 'apple.com',
      }, SetOptions(merge: true));

      debugPrint('✅ Apple user data stored successfully');
    } catch (e) {
      debugPrint('❌ Failed to store Apple user data: $e');
    }
  }
}

/// Extension to check if the platform is iOS
extension TargetPlatformExtension on TargetPlatform {
  bool get isIOS => this == TargetPlatform.iOS || this == TargetPlatform.macOS;
}
