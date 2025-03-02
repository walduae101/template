import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Improved Apple Sign-In implementation using in-app WebView
class AppleAuthImplementation {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate a secure nonce (reduced to 8 chars for memory optimization)
  String _generateNonce([int length = 8]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Generate SHA256 hash (required for Apple Sign-In)
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Create a custom Apple Sign-In WebView dialog for Android
  Future<Map<String, dynamic>?> _showCustomAppleAuthDialog(
    BuildContext context,
    String authUrl,
  ) async {
    Map<String, dynamic>? result;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sign in with Apple',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Container(
                height: 450,
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(authUrl)),
                  initialSettings: InAppWebViewSettings(
                    useShouldOverrideUrlLoading: true,
                    useOnLoadResource: true,
                    javaScriptEnabled: true,
                  ),
                  shouldOverrideUrlLoading: (
                    controller,
                    navigationAction,
                  ) async {
                    final url = navigationAction.request.url?.toString() ?? '';

                    // Check for successful authentication
                    if (url.contains('__/auth/handler') ||
                        url.contains('apple-login-callback')) {
                      // Extract authorization code from URL if present
                      final uri = Uri.parse(url);
                      final code = uri.queryParameters['code'];
                      final idToken = uri.queryParameters['id_token'];

                      if (code != null || idToken != null) {
                        result = {'code': code, 'id_token': idToken};
                        Navigator.of(context).pop();
                      }
                      return NavigationActionPolicy.CANCEL;
                    }

                    // Let browser handle the URL
                    return NavigationActionPolicy.ALLOW;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    return result;
  }

  /// Sign in with Apple using platform-specific optimizations
  Future<User?> signInWithApple({BuildContext? context}) async {
    try {
      // Memory optimization: Check for existing auth first
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        for (var profile in currentUser.providerData) {
          if (profile.providerId == 'apple.com') {
            return currentUser;
          }
        }
      }

      // Platform-specific optimized approaches
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        // For iOS/macOS: Use native API (most efficient)
        final rawNonce = _generateNonce();
        final nonce = _sha256ofString(rawNonce);

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email],
          nonce: nonce,
        );

        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        final userCredential = await _auth.signInWithCredential(
          oauthCredential,
        );
        return userCredential.user;
      }

      // For Android: Use in-app WebView approach
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        if (context == null) {
          throw Exception(
            "Context is required for Android in-app authentication",
          );
        }

        // Store context safely
        final BuildContext currentContext = context;

        // Generate secure nonce
        final rawNonce = _generateNonce();
        final nonce = _sha256ofString(rawNonce);

        // Set up Firebase Apple auth provider
        final appleProvider =
            OAuthProvider('apple.com')
              ..addScope('email')
              ..setCustomParameters({'nonce': nonce});

        try {
          // First try the native provider approach
          final userCredential = await _auth.signInWithProvider(appleProvider);
          return userCredential.user;
        } catch (e) {
          debugPrint(
            'Native provider approach failed, trying in-app WebView: $e',
          );

          // Fallback to custom in-app WebView
          const redirectUrl =
              'https://sajaya-2c801.firebaseapp.com/__/auth/handler';
          const clientId = '3DD956ET5V.com.easylife.sajaya';

          final authUrl =
              'https://appleid.apple.com/auth/authorize'
              '?client_id=$clientId'
              '&redirect_uri=${Uri.encodeComponent(redirectUrl)}'
              '&response_type=code%20id_token'
              '&scope=email'
              '&response_mode=fragment'
              '&nonce=$nonce';

          // Check if context is still valid
          if (currentContext.mounted) {
            final result = await _showCustomAppleAuthDialog(
              currentContext,
              authUrl,
            );

            if (result != null && result['id_token'] != null) {
              final oauthCredential = OAuthProvider(
                'apple.com',
              ).credential(idToken: result['id_token'], rawNonce: rawNonce);

              final userCredential = await _auth.signInWithCredential(
                oauthCredential,
              );
              return userCredential.user;
            } else {
              throw Exception('Apple Sign-In was canceled or failed');
            }
          }
        }
      }

      // For Web: Use popup approach which is more contained than redirect
      if (kIsWeb) {
        final provider = OAuthProvider('apple.com');
        try {
          final userCredential = await _auth.signInWithPopup(provider);
          return userCredential.user;
        } catch (e) {
          // Try redirect only as a last resort
          await _auth.signInWithRedirect(provider);
          return null;
        }
      }

      // Generic fallback with minimal options
      final provider = OAuthProvider('apple.com');
      final userCredential = await _auth.signInWithProvider(provider);
      return userCredential.user;
    } catch (e) {
      // Check if already signed in despite error
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        for (var profile in currentUser.providerData) {
          if (profile.providerId == 'apple.com') {
            return currentUser;
          }
        }
      }
      rethrow;
    }
  }
}
